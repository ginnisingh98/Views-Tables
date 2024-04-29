--------------------------------------------------------
--  DDL for Package Body JTF_CAL_SHIFT_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_SHIFT_ASSIGN_PKG" as
/* $Header: jtfclsab.pls 115.19 2002/11/15 14:37:04 sukulkar ship $ */
procedure INSERT_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_SHIFT_ASSIGN_ID in out NOCOPY NUMBER,
  X_SHIFT_START_DATE in DATE,
  X_SHIFT_END_DATE in DATE,
  X_CALENDAR_ID in NUMBER,
  X_SHIFT_SEQUENCE_NUMBER in NUMBER,
  X_SHIFT_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
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
count_cal number;
temp_count number;
--  cursor C is select ROWID from JTF_CAL_SHIFT_ASSIGN
--    where CAL_SHIFT_ASSIGN_ID = X_CAL_SHIFT_ASSIGN_ID;

	v_error CHAR := 'N';
        v_jtf_cal_shift_assign_s NUMBER;
begin
		fnd_msg_pub.initialize;
     select count(*) into count_cal
     from jtf_cal_shift_assign
     where calendar_id = X_CALENDAR_ID;

IF count_cal > 0 THEN
         select count(*) into temp_count
	from jtf_cal_shift_assign
	where calendar_id = X_CALENDAR_ID
	and shift_id = X_SHIFT_ID
	and shift_start_date = TRUNC(X_SHIFT_START_DATE)
	and shift_end_date = TRUNC(X_SHIFT_END_DATE);

	If temp_count > 0 THEN

			fnd_message.set_name('JTF', 'JTF_CAL_DUPLICATE_ASSIGNMENT');
			--fnd_message.set_token('P_Name', 'Assignment');
			fnd_msg_pub.add;

			v_error := 'Y';
       END IF;

/*	IF JTF_CAL_SHIFT_ASSIGN_PKG.duplicate_assign(X_CALENDAR_ID,X_SHIFT_ID, X_SHIFT_START_DATE, X_SHIFT_END_DATE)
									= FALSE THEN
			--fnd_message.set_name('JTF', 'DUPLICATE RECORD ENTERED');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_DUPLICATE_ASSIGNMENT');
			--fnd_message.set_token('P_Name', 'Assignment');
			fnd_msg_pub.add;

			v_error := 'Y';

		END IF;

		IF JTF_CAL_SHIFT_ASSIGN_PKG.duplicate_seq(X_SHIFT_ID, X_SHIFT_SEQUENCE_NUMBER) = 			FALSE THEN
			fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_SEQ_NUM');
			fnd_message.set_token('P_Shift_Seq_Num', X_SHIFT_SEQUENCE_NUMBER);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;
*/
END IF;

		IF JTF_CAL_SHIFT_ASSIGN_PKG.NOT_NULL(X_SHIFT_ID) = FALSE THEN
			--fnd_message.set_name('JTF', 'SHIFT_ID CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_NAME');
			--fnd_message.set_token('P_Name', 'SHIFT');
			fnd_msg_pub.add;

			v_error := 'Y';
		END IF;

		IF JTF_CAL_SHIFT_ASSIGN_PKG.NOT_NULL(X_SHIFT_START_DATE) = FALSE THEN
			--fnd_message.set_name('JTF', 'SHIFT_START_DATE CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		IF JTF_CAL_SHIFT_ASSIGN_PKG.END_GREATER_THAN_BEGIN(X_SHIFT_START_DATE, X_SHIFT_END_DATE) = FALSE THEN
			--fnd_message.set_name('JTF', 'END_DATE IS INCORRECT');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_END_DATE');
			fnd_message.set_token('P_Start_Date', X_SHIFT_START_DATE);
			fnd_message.set_token('P_End_Date', X_SHIFT_END_DATE);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

/*
		IF JTF_CAL_SHIFT_ASSIGN_PKG.duplicate_seq(X_SHIFT_ID, X_SHIFT_SEQUENCE_NUMBER) = 			FALSE THEN
			fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_SEQ_NUM');
			fnd_message.set_token('P_Shift_Seq_Num', X_SHIFT_SEQUENCE_NUMBER);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;
*/

		IF v_error = 'Y' THEN
			X_ERROR := 'Y';
			return;
		ELSE

                     SELECT jtf_cal_shift_assign_s.nextval
                     INTO   v_jtf_cal_shift_assign_s
                     FROM dual;

                     X_CAL_SHIFT_ASSIGN_ID := v_jtf_cal_shift_assign_s;

	  insert into JTF_CAL_SHIFT_ASSIGN (
		    OBJECT_VERSION_NUMBER,
		    SHIFT_START_DATE,
		    SHIFT_END_DATE,
		    CAL_SHIFT_ASSIGN_ID,
		    CALENDAR_ID,
		    SHIFT_SEQUENCE_NUMBER,
		    SHIFT_ID,
		    CREATED_BY,
		    CREATION_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
		    ATTRIBUTE1,
		    ATTRIBUTE2,
		    ATTRIBUTE4,
		    ATTRIBUTE5,
		    ATTRIBUTE3,
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
	       	 X_SHIFT_START_DATE,
		    X_SHIFT_END_DATE,
		    v_jtf_cal_shift_assign_s,
		    X_CALENDAR_ID,
		    X_SHIFT_SEQUENCE_NUMBER,
		    X_SHIFT_ID,
		    FND_GLOBAL.USER_ID,
		    sysdate,
		    FND_GLOBAL.USER_ID,
		    sysdate,
		    FND_GLOBAL.LOGIN_ID,
		    X_ATTRIBUTE1,
		    X_ATTRIBUTE2,
		    X_ATTRIBUTE4,
		    X_ATTRIBUTE5,
		    X_ATTRIBUTE3,
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
/*************************************************************************/
procedure LOCK_ROW (
  X_CAL_SHIFT_ASSIGN_ID in NUMBER,
  X_SHIFT_START_DATE in DATE,
  X_SHIFT_END_DATE in DATE,
  X_CALENDAR_ID in NUMBER,
  X_SHIFT_SEQUENCE_NUMBER in NUMBER,
  X_SHIFT_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
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
      SHIFT_START_DATE,
      SHIFT_END_DATE,
      CALENDAR_ID,
      SHIFT_SEQUENCE_NUMBER,
      SHIFT_ID,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE3,
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
      CAL_SHIFT_ASSIGN_ID
    from JTF_CAL_SHIFT_ASSIGN
    where CAL_SHIFT_ASSIGN_ID = X_CAL_SHIFT_ASSIGN_ID
    for update of CAL_SHIFT_ASSIGN_ID nowait;
begin
  for tlinfo in c1 loop
--    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CAL_SHIFT_ASSIGN_ID = X_CAL_SHIFT_ASSIGN_ID)
          AND (tlinfo.SHIFT_START_DATE = X_SHIFT_START_DATE)
          AND (tlinfo.SHIFT_END_DATE = X_SHIFT_END_DATE)
          AND (tlinfo.CALENDAR_ID = X_CALENDAR_ID)
          AND (tlinfo.SHIFT_SEQUENCE_NUMBER = X_SHIFT_SEQUENCE_NUMBER)
          AND (tlinfo.SHIFT_ID = X_SHIFT_ID)
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
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
/*************************************************************************/
procedure UPDATE_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_CAL_SHIFT_ASSIGN_ID in NUMBER,
  X_SHIFT_START_DATE in DATE,
  X_SHIFT_END_DATE in DATE,
  X_CALENDAR_ID in NUMBER,
  X_SHIFT_SEQUENCE_NUMBER in NUMBER,
  X_SHIFT_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
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
	temp_count number;
	v_error CHAR := 'N';

begin
		fnd_msg_pub.initialize;

         select count(*) into temp_count
	from jtf_cal_shift_assign
	where calendar_id = X_CALENDAR_ID
	and shift_id = X_SHIFT_ID
	and shift_start_date = TRUNC(X_SHIFT_START_DATE)
	and shift_end_date = TRUNC(X_SHIFT_END_DATE);

	If temp_count > 1 THEN

			fnd_message.set_name('JTF', 'JTF_CAL_DUPLICATE_ASSIGNMENT');
			--fnd_message.set_token('P_Name', 'Assignment');
			fnd_msg_pub.add;
             v_error := 'Y';
	END IF;

	/*	IF JTF_CAL_SHIFT_ASSIGN_PKG.duplicate_assign(X_CALENDAR_ID,X_SHIFT_ID, X_SHIFT_START_DATE, X_SHIFT_END_DATE)
									= FALSE THEN
			--fnd_message.set_name('JTF', 'DUPLICATE RECORD ENTERED');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_DUPLICATE_ASSIGNMENT');
			--fnd_message.set_token('P_Name', 'Assignment');
			fnd_msg_pub.add;

			v_error := 'Y';

		END IF;
	*/
		IF JTF_CAL_SHIFT_ASSIGN_PKG.NOT_NULL(X_SHIFT_ID) = FALSE THEN
			--fnd_message.set_name('JTF', 'SHIFT_ID CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_NAME');
			--fnd_message.set_token('P_Name', 'SHIFT');
			fnd_msg_pub.add;

			v_error := 'Y';
		END IF;

		IF JTF_CAL_SHIFT_ASSIGN_PKG.NOT_NULL(X_SHIFT_START_DATE) = FALSE THEN
			--fnd_message.set_name('JTF', 'SHIFT_START_DATE CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		IF JTF_CAL_SHIFT_ASSIGN_PKG.END_GREATER_THAN_BEGIN(X_SHIFT_START_DATE, X_SHIFT_END_DATE) = FALSE THEN
			--fnd_message.set_name('JTF', 'END_DATE IS INCORRECT');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_END_DATE');
			fnd_message.set_token('P_Start_Date', X_SHIFT_START_DATE);
			fnd_message.set_token('P_End_Date', X_SHIFT_END_DATE);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		IF v_error = 'Y' THEN
			X_ERROR := 'Y';
			return;
		ELSE

		  update JTF_CAL_SHIFT_ASSIGN set
                    object_version_number = object_version_number + 1,
		    SHIFT_START_DATE = X_SHIFT_START_DATE,
		    SHIFT_END_DATE = X_SHIFT_END_DATE,
		    CALENDAR_ID = X_CALENDAR_ID,
		    SHIFT_SEQUENCE_NUMBER = X_SHIFT_SEQUENCE_NUMBER,
		    SHIFT_ID = X_SHIFT_ID,
		    ATTRIBUTE1 = X_ATTRIBUTE1,
		    ATTRIBUTE2 = X_ATTRIBUTE2,
		    ATTRIBUTE4 = X_ATTRIBUTE4,
		    ATTRIBUTE5 = X_ATTRIBUTE5,
		    ATTRIBUTE3 = X_ATTRIBUTE3,
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
		    CAL_SHIFT_ASSIGN_ID = X_CAL_SHIFT_ASSIGN_ID,
		    LAST_UPDATE_DATE = SYSDATE,
		    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		  where CAL_SHIFT_ASSIGN_ID = X_CAL_SHIFT_ASSIGN_ID;

--		  if (sql%notfound) then
--		    raise no_data_found;
--		  end if;
		END IF;
	end UPDATE_ROW;
/*************************************************************************/
procedure DELETE_ROW (
  X_CAL_SHIFT_ASSIGN_ID in NUMBER
) is
begin
  delete from JTF_CAL_SHIFT_ASSIGN
  where CAL_SHIFT_ASSIGN_ID = X_CAL_SHIFT_ASSIGN_ID;

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
	FUNCTION duplicate_assign(X_CALENDAR_ID IN NUMBER, X_SHIFT_ID IN NUMBER, X_SHIFT_START_DATE IN DATE, X_SHIFT_END_DATE IN DATE) RETURN boolean IS

	X_FOUND CHAR := 'N';
	cursor dup is
		select 'x'
		from   jtf_cal_shift_assign
		where  shift_id = X_SHIFT_ID
		and    shift_start_date = TRUNC(X_SHIFT_START_DATE)
		AND    shift_end_date = TRUNC(X_SHIFT_END_DATE)
		AND rownum < 2;

	BEGIN
	-- Shift is unique


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
/*************************************************************************/
FUNCTION duplicate_seq(X_SHIFT_ID IN NUMBER, X_SHIFT_SEQUENCE_NUMBER IN NUMBER) RETURN boolean IS

	X_FOUND CHAR := 'N';
	  cursor dup is
		select 'x'
		from   jtf_cal_shift_assign
		where  shift_id = X_SHIFT_ID
		and    shift_sequence_number = X_SHIFT_SEQUENCE_NUMBER
		AND rownum < 2;

	BEGIN
	-- Shift is unique
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


end JTF_CAL_SHIFT_ASSIGN_PKG;

/
