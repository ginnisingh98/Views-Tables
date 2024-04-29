--------------------------------------------------------
--  DDL for Package Body AR_CONS_BILL_CYCLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CONS_BILL_CYCLE_PKG" as
/* $Header: ARCBILCB.pls 120.3 2006/05/23 16:18:52 jypandey noship $ */
procedure INSERT_ROW (
 X_ROWID IN OUT NOCOPY VARCHAR2,
 X_BILLING_CYCLE_ID IN NUMBER,
 X_BILL_CYCLE_TYPE IN VARCHAR2,
 X_CYCLE_NAME IN VARCHAR2,
 X_DESCRIPTION IN VARCHAR2,
 X_CYCLE_FREQUENCY IN VARCHAR2,
 X_START_DATE IN DATE,
 X_LAST_DAY IN VARCHAR2,
 X_DAY_1 IN VARCHAR2,
 X_DAY_2 IN VARCHAR2,
 X_DAY_3 IN VARCHAR2,
 X_DAY_4 IN VARCHAR2,
 X_DAY_5 IN VARCHAR2,
 X_DAY_6 IN VARCHAR2,
 X_DAY_7 IN VARCHAR2,
 X_DAY_8 IN VARCHAR2,
 X_DAY_9 IN VARCHAR2,
 X_DAY_10 IN VARCHAR2,
 X_DAY_11 IN VARCHAR2,
 X_DAY_12 IN VARCHAR2,
 X_DAY_13 IN VARCHAR2,
 X_DAY_14 IN VARCHAR2,
 X_DAY_15 IN VARCHAR2,
 X_DAY_16 IN VARCHAR2,
 X_DAY_17 IN VARCHAR2,
 X_DAY_18 IN VARCHAR2,
 X_DAY_19 IN VARCHAR2,
 X_DAY_20 IN VARCHAR2,
 X_DAY_21 IN VARCHAR2,
 X_DAY_22 IN VARCHAR2,
 X_DAY_23 IN VARCHAR2,
 X_DAY_24 IN VARCHAR2,
 X_DAY_25 IN VARCHAR2,
 X_DAY_26 IN VARCHAR2,
 X_DAY_27 IN VARCHAR2,
 X_DAY_28 IN VARCHAR2,
 X_DAY_29 IN VARCHAR2,
 X_DAY_30 IN VARCHAR2,
 X_DAY_31 IN VARCHAR2,
 X_DAY_MONDAY IN VARCHAR2,
 X_DAY_TUESDAY IN VARCHAR2,
 X_DAY_WEDNESDAY IN VARCHAR2,
 X_DAY_THURSDAY IN VARCHAR2,
 X_DAY_FRIDAY IN VARCHAR2,
 X_DAY_SATURDAY IN VARCHAR2,
 X_DAY_SUNDAY IN VARCHAR2,
 X_SKIP_WEEKENDS IN VARCHAR2,
 X_SKIP_HOLIDAYS IN VARCHAR2,
 X_REPEAT_DAILY IN NUMBER,
 X_REPEAT_WEEKLY IN NUMBER,
 X_REPEAT_MONTHLY IN NUMBER,
 X_DAY_TYPE   IN VARCHAR2,
 X_CREATED_BY IN NUMBER,
 X_CREATION_DATE IN DATE,
 X_LAST_UPDATE_LOGIN IN NUMBER,
 X_LAST_UPDATE_DATE IN DATE,
 X_LAST_UPDATED_BY IN NUMBER,
 X_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  cursor C is select ROWID from AR_CONS_BILL_CYCLES_B
    where BILLING_CYCLE_ID = X_BILLING_CYCLE_ID;

Begin

INSERT INTO AR_CONS_BILL_CYCLES_B(
 BILLING_CYCLE_ID,
 BILL_CYCLE_TYPE,
 CYCLE_FREQUENCY,
 START_DATE,
 LAST_DAY,
 DAY_1,
 DAY_2,
 DAY_3,
 DAY_4,
 DAY_5,
 DAY_6,
 DAY_7,
 DAY_8,
 DAY_9,
 DAY_10,
 DAY_11,
 DAY_12,
 DAY_13,
 DAY_14,
 DAY_15,
 DAY_16,
 DAY_17,
 DAY_18,
 DAY_19,
 DAY_20,
 DAY_21,
 DAY_22,
 DAY_23,
 DAY_24,
 DAY_25,
 DAY_26,
 DAY_27,
 DAY_28,
 DAY_29,
 DAY_30,
 DAY_31,
 DAY_MONDAY,
 DAY_TUESDAY,
 DAY_WEDNESDAY,
 DAY_THURSDAY,
 DAY_FRIDAY,
 DAY_SATURDAY ,
 DAY_SUNDAY ,
 SKIP_WEEKENDS,
 SKIP_HOLIDAYS,
 REPEAT_DAILY,
 REPEAT_WEEKLY,
 REPEAT_MONTHLY,
 DAY_TYPE  ,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATE_LOGIN,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 OBJECT_VERSION_NUMBER
) VALUES(
 X_BILLING_CYCLE_ID,
 X_BILL_CYCLE_TYPE,
 X_CYCLE_FREQUENCY,
 X_START_DATE,
 X_LAST_DAY,
 X_DAY_1,
 X_DAY_2,
 X_DAY_3,
 X_DAY_4,
 X_DAY_5,
 X_DAY_6,
 X_DAY_7,
 X_DAY_8,
 X_DAY_9,
 X_DAY_10,
 X_DAY_11,
 X_DAY_12,
 X_DAY_13,
 X_DAY_14,
 X_DAY_15,
 X_DAY_16,
 X_DAY_17,
 X_DAY_18,
 X_DAY_19,
 X_DAY_20,
 X_DAY_21,
 X_DAY_22,
 X_DAY_23,
 X_DAY_24,
 X_DAY_25,
 X_DAY_26,
 X_DAY_27,
 X_DAY_28,
 X_DAY_29,
 X_DAY_30,
 X_DAY_31,
 X_DAY_MONDAY,
 X_DAY_TUESDAY,
 X_DAY_WEDNESDAY,
 X_DAY_THURSDAY,
 X_DAY_FRIDAY,
 X_DAY_SATURDAY,
 X_DAY_SUNDAY,
 X_SKIP_WEEKENDS,
 X_SKIP_HOLIDAYS,
 X_REPEAT_DAILY,
 X_REPEAT_WEEKLY,
 X_REPEAT_MONTHLY,
 X_DAY_TYPE,
 X_CREATED_BY,
 X_CREATION_DATE,
 X_LAST_UPDATE_LOGIN,
 X_LAST_UPDATE_DATE,
 X_LAST_UPDATED_BY,
 X_OBJECT_VERSION_NUMBER
);

  insert into AR_CONS_BILL_CYCLES_TL (
    BILLING_CYCLE_ID,
    DESCRIPTION,
    CYCLE_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_BILLING_CYCLE_ID,
    X_DESCRIPTION,
    X_CYCLE_NAME,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AR_CONS_BILL_CYCLES_TL T
    where T.BILLING_CYCLE_ID = X_BILLING_CYCLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

 OPEN C;
 FETCH C INTO X_ROWId;
 IF (C%NOTFOUND) THEN
    CLOSE C;
    Raise NO_DATA_FOUND;
 END IF;
CLOSE C;

END Insert_Row;

procedure UPDATE_ROW (
 X_BILLING_CYCLE_ID IN NUMBER,
 X_BILL_CYCLE_TYPE IN VARCHAR2,
 X_CYCLE_NAME IN VARCHAR2,
 X_DESCRIPTION IN VARCHAR2,
 X_CYCLE_FREQUENCY IN VARCHAR2,
 X_START_DATE IN DATE,
 X_LAST_DAY IN VARCHAR2,
 X_DAY_1 IN VARCHAR2,
 X_DAY_2 IN VARCHAR2,
 X_DAY_3 IN VARCHAR2,
 X_DAY_4 IN VARCHAR2,
 X_DAY_5 IN VARCHAR2,
 X_DAY_6 IN VARCHAR2,
 X_DAY_7 IN VARCHAR2,
 X_DAY_8 IN VARCHAR2,
 X_DAY_9 IN VARCHAR2,
 X_DAY_10 IN VARCHAR2,
 X_DAY_11 IN VARCHAR2,
 X_DAY_12 IN VARCHAR2,
 X_DAY_13 IN VARCHAR2,
 X_DAY_14 IN VARCHAR2,
 X_DAY_15 IN VARCHAR2,
 X_DAY_16 IN VARCHAR2,
 X_DAY_17 IN VARCHAR2,
 X_DAY_18 IN VARCHAR2,
 X_DAY_19 IN VARCHAR2,
 X_DAY_20 IN VARCHAR2,
 X_DAY_21 IN VARCHAR2,
 X_DAY_22 IN VARCHAR2,
 X_DAY_23 IN VARCHAR2,
 X_DAY_24 IN VARCHAR2,
 X_DAY_25 IN VARCHAR2,
 X_DAY_26 IN VARCHAR2,
 X_DAY_27 IN VARCHAR2,
 X_DAY_28 IN VARCHAR2,
 X_DAY_29 IN VARCHAR2,
 X_DAY_30 IN VARCHAR2,
 X_DAY_31 IN VARCHAR2,
 X_DAY_MONDAY IN VARCHAR2,
 X_DAY_TUESDAY IN VARCHAR2,
 X_DAY_WEDNESDAY IN VARCHAR2,
 X_DAY_THURSDAY IN VARCHAR2,
 X_DAY_FRIDAY IN VARCHAR2,
 X_DAY_SATURDAY IN VARCHAR2,
 X_DAY_SUNDAY IN VARCHAR2,
 X_SKIP_WEEKENDS IN VARCHAR2,
 X_SKIP_HOLIDAYS IN VARCHAR2,
 X_REPEAT_DAILY IN NUMBER,
 X_REPEAT_WEEKLY IN NUMBER,
 X_REPEAT_MONTHLY IN NUMBER,
 X_DAY_TYPE   IN VARCHAR2,
 X_LAST_UPDATE_LOGIN IN NUMBER,
 X_LAST_UPDATE_DATE IN DATE,
 X_LAST_UPDATED_BY IN NUMBER,
 X_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER
) IS
Begin

UPDATE AR_CONS_BILL_CYCLES_B SET
 cycle_frequency = X_cycle_frequency,
 BILL_CYCLE_TYPE = X_BILL_CYCLE_TYPE,
 START_DATE = X_START_DATE,
 --CYCLE_FREQUENCY = X_cycle_frequency,
 LAST_DAY = X_LAST_DAY,
 DAY_1 = X_day_1,
 DAY_2 = X_day_2,
 DAY_3 = X_day_3,
 DAY_4 = X_day_4,
 DAY_5 = X_day_5,
 DAY_6 = X_day_6,
 DAY_7 = X_day_7,
 DAY_8 = X_day_8,
 DAY_9 = X_day_9,
 DAY_10 = X_day_10,
 DAY_11 = X_day_11,
 DAY_12 = X_day_12,
 DAY_13 = X_day_13,
 DAY_14 = X_day_14,
 DAY_15 = X_day_15,
 DAY_16 = X_day_16,
 DAY_17 = X_day_17,
 DAY_18 = X_day_18,
 DAY_19 = X_day_19,
 DAY_20 = X_day_20,
 DAY_21 = X_day_21,
 DAY_22 = X_day_22,
 DAY_23 = X_day_23,
 DAY_24 = X_day_24,
 DAY_25 = X_day_25,
 DAY_26 = X_day_26,
 DAY_27 = X_day_27,
 DAY_28 = X_day_28,
 DAY_29 = X_day_29,
 DAY_30 = X_day_30,
 DAY_31 = X_day_31,
 DAY_MONDAY = X_day_monday,
 DAY_TUESDAY = X_day_tuesday,
 DAY_WEDNESDAY = X_day_wednesday,
 DAY_THURSDAY = X_day_thursday,
 DAY_FRIDAY = X_day_friday,
 DAY_SATURDAY= X_DAY_SATURDAY ,
 DAY_SUNDAY  = X_DAY_SUNDAY   ,
 SKIP_WEEKENDS = X_SKIP_WEEKENDS,
 SKIP_HOLIDAYS = X_SKIP_HOLIDAYS,
 REPEAT_DAILY = X_REPEAT_DAILY,
 REPEAT_WEEKLY = X_REPEAT_WEEKLY,
 REPEAT_MONTHLY = X_REPEAT_MONTHLY,
 DAY_TYPE   = X_DAY_TYPE,
 LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
 LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
 LAST_UPDATED_BY = X_last_updated_by,
 OBJECT_VERSION_NUMBER = DECODE(X_object_version_number,0,OBJECT_VERSION_NUMBER+1,X_object_version_number)
WHERE BILLING_CYCLE_Id = X_billing_cycle_id;

IF sql%notfound THEN
 X_object_version_number:= X_object_version_number-1;
 Raise NO_DATA_FOUND;
END IF;

  UPDATE AR_CONS_BILL_CYCLES_TL SET
    DESCRIPTION = X_DESCRIPTION,
    CYCLE_NAME = X_CYCLE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where BILLING_CYCLE_ID = X_billing_cycle_id
  and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
IF sql%notfound THEN
 Raise NO_DATA_FOUND;
END IF;

END Update_Row;

procedure DELETE_ROW (
 X_BILLING_CYCLE_ID IN NUMBER
) IS
BEGIN
  delete from AR_CONS_BILL_CYCLES_TL
  where BILLING_CYCLE_ID = X_billing_cycle_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_CONS_BILL_CYCLES_B
  where BILLING_CYCLE_ID = X_billing_cycle_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Delete_Row;


procedure LOCK_ROW (
 X_BILLING_CYCLE_ID IN NUMBER,
 X_CYCLE_NAME IN VARCHAR2,
 X_DESCRIPTION IN VARCHAR2,
 X_CYCLE_FREQUENCY IN VARCHAR2,
 X_START_DATE IN DATE,
 X_LAST_DAY IN VARCHAR2,
 X_DAY_1 IN VARCHAR2,
 X_DAY_2 IN VARCHAR2,
 X_DAY_3 IN VARCHAR2,
 X_DAY_4 IN VARCHAR2,
 X_DAY_5 IN VARCHAR2,
 X_DAY_6 IN VARCHAR2,
 X_DAY_7 IN VARCHAR2,
 X_DAY_8 IN VARCHAR2,
 X_DAY_9 IN VARCHAR2,
 X_DAY_10 IN VARCHAR2,
 X_DAY_11 IN VARCHAR2,
 X_DAY_12 IN VARCHAR2,
 X_DAY_13 IN VARCHAR2,
 X_DAY_14 IN VARCHAR2,
 X_DAY_15 IN VARCHAR2,
 X_DAY_16 IN VARCHAR2,
 X_DAY_17 IN VARCHAR2,
 X_DAY_18 IN VARCHAR2,
 X_DAY_19 IN VARCHAR2,
 X_DAY_20 IN VARCHAR2,
 X_DAY_21 IN VARCHAR2,
 X_DAY_22 IN VARCHAR2,
 X_DAY_23 IN VARCHAR2,
 X_DAY_24 IN VARCHAR2,
 X_DAY_25 IN VARCHAR2,
 X_DAY_26 IN VARCHAR2,
 X_DAY_27 IN VARCHAR2,
 X_DAY_28 IN VARCHAR2,
 X_DAY_29 IN VARCHAR2,
 X_DAY_30 IN VARCHAR2,
 X_DAY_31 IN VARCHAR2,
 X_DAY_MONDAY IN VARCHAR2,
 X_DAY_TUESDAY IN VARCHAR2,
 X_DAY_WEDNESDAY IN VARCHAR2,
 X_DAY_THURSDAY IN VARCHAR2,
 X_DAY_FRIDAY IN VARCHAR2,
 X_DAY_SATURDAY IN VARCHAR2 ,
 X_DAY_SUNDAY   IN VARCHAR2,
 X_SKIP_WEEKENDS IN VARCHAR2,
 X_SKIP_HOLIDAYS IN VARCHAR2,
 X_REPEAT_DAILY IN NUMBER,
 X_REPEAT_WEEKLY IN NUMBER,
 X_REPEAT_MONTHLY IN NUMBER,
 X_DAY_TYPE   IN VARCHAR2
) IS
CURSOR c is select
 BILLING_CYCLE_ID, cycle_frequency, START_DATE, LAST_DAY, DAY_1, DAY_2, DAY_3, DAY_4, DAY_5, DAY_6, DAY_7,
 DAY_8, DAY_9, DAY_10, DAY_11, DAY_12, DAY_13, DAY_14, DAY_15, DAY_16, DAY_17, DAY_18, DAY_19, DAY_20,
 DAY_21, DAY_22, DAY_23, DAY_24, DAY_25, DAY_26, DAY_27, DAY_28, DAY_29, DAY_30, DAY_31, DAY_MONDAY, DAY_TUESDAY,
 DAY_WEDNESDAY, DAY_THURSDAY, DAY_FRIDAY, DAY_SATURDAY, DAY_SUNDAY,
 SKIP_WEEKENDS, SKIP_HOLIDAYS, REPEAT_DAILY, REPEAT_WEEKLY,
 REPEAT_MONTHLY, DAY_TYPE
 FROM AR_CONS_BILL_CYCLES_B
WHERE BILLING_CYCLE_ID = X_billing_cycle_id
FOR update of BILLING_CYCLE_ID nowait;


Recinfo c%rowtype;
CURSOR c1 is select
 DESCRIPTION, CYCLE_NAME,
 decode(LANGUAGE,userenv('LANG'),'Y','N') BASELANG
FROM AR_CONS_BILL_CYCLES_TL
WHERE BILLING_CYCLE_ID = X_billing_cycle_id
FOR UPDATE Of BILLING_CYCLE_ID nowait;

BEGIN
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
 close c;

IF( ((recinfo.cycle_frequency = X_cycle_frequency)
          OR ((recinfo.cycle_frequency is NULL) AND (X_cycle_frequency is null)))
AND ((recinfo.START_DATE = X_START_DATE)
          OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
AND ((recinfo.LAST_DAY = X_LAST_DAY)
          OR ((recinfo.LAST_DAY is null ) AND (X_LAST_DAY is null)))
AND ((recinfo.DAY_1 = X_day_1)
          OR ((recinfo.DAY_1 is null) AND ( X_day_1 is null)))
AND ((recinfo.DAY_2 = X_day_2)
          OR ((recinfo.DAY_2 is null) AND ( X_day_2 is null)))
AND ((recinfo.DAY_3 = X_day_3)
          OR ((recinfo.DAY_3 is null) AND ( X_day_3 is null)))
AND ((recinfo.DAY_4 = X_day_4)
          OR ((recinfo.DAY_4 is null) AND ( X_day_4 is null)))
AND ((recinfo.DAY_5 = X_day_5)
          OR ((recinfo.DAY_5 is null) AND ( X_day_5 is null)))

AND ((recinfo.DAY_6 = X_day_6)
          OR ((recinfo.DAY_6 is null) AND ( X_day_6 is null)))
AND ((recinfo.DAY_7 = X_day_7)
          OR ((recinfo.DAY_7 is null) AND ( X_day_7 is null)))
AND ((recinfo.DAY_8 = X_day_8)
          OR ((recinfo.DAY_8 is null) AND ( X_day_8 is null)))
AND ((recinfo.DAY_9 = X_day_9)
          OR ((recinfo.DAY_9 is null) AND ( X_day_9 is null)))
AND ((recinfo.DAY_10 = X_day_10)
          OR ((recinfo.DAY_10 is null) AND ( X_day_10 is null)))

AND ((recinfo.DAY_11 = X_day_11)
          OR ((recinfo.DAY_11 is null) AND ( X_day_11 is null)))
AND ((recinfo.DAY_12 = X_day_12)
          OR ((recinfo.DAY_12 is null) AND ( X_day_12 is null)))
AND ((recinfo.DAY_13 = X_day_13)
          OR ((recinfo.DAY_13 is null) AND ( X_day_13 is null)))
AND ((recinfo.DAY_14 = X_day_14)
          OR ((recinfo.DAY_14 is null) AND ( X_day_14 is null)))
AND ((recinfo.DAY_15 = X_day_15)
          OR ((recinfo.DAY_15 is null) AND ( X_day_15 is null)))

AND ((recinfo.DAY_16 = X_day_16)
          OR ((recinfo.DAY_16 is null) AND ( X_day_16 is null)))
AND ((recinfo.DAY_17 = X_day_17)
          OR ((recinfo.DAY_17 is null) AND ( X_day_17 is null)))
AND ((recinfo.DAY_18 = X_day_18)
          OR ((recinfo.DAY_18 is null) AND ( X_day_18 is null)))
AND ((recinfo.DAY_19 = X_day_19)
          OR ((recinfo.DAY_19 is null) AND ( X_day_19 is null)))
AND ((recinfo.DAY_20 = X_day_20)
          OR ((recinfo.DAY_20 is null) AND ( X_day_20 is null)))

AND ((recinfo.DAY_21 = X_day_21)
          OR ((recinfo.DAY_21 is null) AND ( X_day_21 is null)))
AND ((recinfo.DAY_22 = X_day_22)
          OR ((recinfo.DAY_22 is null) AND ( X_day_22 is null)))
AND ((recinfo.DAY_23 = X_day_23)
          OR ((recinfo.DAY_23 is null) AND ( X_day_23 is null)))
AND ((recinfo.DAY_24 = X_day_24)
          OR ((recinfo.DAY_24 is null) AND ( X_day_24 is null)))
AND ((recinfo.DAY_25 = X_day_25)
          OR ((recinfo.DAY_25 is null) AND ( X_day_25 is null)))

AND ((recinfo.DAY_26 = X_day_26)
          OR ((recinfo.DAY_26 is null) AND ( X_day_26 is null)))
AND ((recinfo.DAY_27 = X_day_27)
          OR ((recinfo.DAY_27 is null) AND ( X_day_27 is null)))
AND ((recinfo.DAY_28 = X_day_28)
          OR ((recinfo.DAY_28 is null) AND ( X_day_28 is null)))
AND ((recinfo.DAY_29 = X_day_29)
          OR ((recinfo.DAY_29 is null) AND ( X_day_29 is null)))
AND ((recinfo.DAY_30 = X_day_30)
          OR ((recinfo.DAY_30 is null) AND ( X_day_30 is null)))

AND ((recinfo.DAY_31 = X_day_31)
          OR ((recinfo.DAY_31 is null) AND ( X_day_31 is null)))

AND ((recinfo.DAY_MONDAY = X_day_monday)
          OR ((recinfo.DAY_MONDAY is null) AND ( X_day_monday is null)))
AND ((recinfo.DAY_TUESDAY = X_day_tuesday)
          OR ((recinfo.DAY_TUESDAY is null) AND ( X_day_tuesday is null)))
AND ((recinfo.DAY_WEDNESDAY =X_day_wednesday)
          OR ((recinfo.DAY_WEDNESDAY is null) AND (  X_day_wednesday is null)))
AND ((recinfo.DAY_thursday =X_day_thursday)
          OR ((recinfo.DAY_thursday is null) AND (  X_day_thursday is null)))
AND ((recinfo.DAY_FRIDAY =X_day_friday)
          OR ((recinfo.DAY_friday is null) AND (  X_day_friday is null)))
AND ((recinfo.DAY_SATURDAY =X_day_saturday)
          OR ((recinfo.DAY_saturday is null) AND (  X_day_saturday is null)))
AND ((recinfo.DAY_SUNDAY =X_day_sunday)
          OR ((recinfo.DAY_sunday is null) AND (  X_day_sunday is null)))
AND ((recinfo.SKIP_WEEKENDS =X_SKIP_WEEKENDS)
          OR ((recinfo.SKIP_WEEKENDS is null) AND (  X_SKIP_WEEKENDS is null)))
AND ((recinfo.SKIP_HOLIDAYS =X_SKIP_HOLIDAYS)
          OR ((recinfo.SKIP_HOLIDAYS is null) AND (  X_SKIP_HOLIDAYS is null)))

AND ((recinfo.REPEAT_DAILY =X_REPEAT_DAILY)
          OR ((recinfo.REPEAT_DAILY is null) AND (  X_REPEAT_DAILY is null)))
AND ((recinfo.REPEAT_WEEKLY =X_REPEAT_WEEKLY)
          OR ((recinfo.REPEAT_WEEKLY is null) AND (  X_REPEAT_WEEKLY is null)))
AND ((recinfo.REPEAT_MONTHLY =X_REPEAT_MONTHLY)
          OR ((recinfo.REPEAT_MONTHLY is null) AND (  X_REPEAT_MONTHLY is null)))
AND ((recinfo.DAY_TYPE =X_DAY_TYPE)
          OR ((recinfo.DAY_TYPE is null) AND (  X_DAY_TYPE is null)))

  )
THEN
    null;
ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
END IF;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CYCLE_NAME = X_cycle_name)
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
END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from AR_CONS_BILL_CYCLES_TL T
  where not exists
    (select NULL
    from AR_CONS_BILL_CYCLES_B B
    where B.BILLING_CYCLE_ID = T.BILLING_CYCLE_ID
    );

  update AR_CONS_BILL_CYCLES_TL T set (
      CYCLE_NAME,DESCRIPTION
    ) = (select
      B.CYCLE_NAME,B.DESCRIPTION
    from AR_CONS_BILL_CYCLES_TL B
    where B.BILLING_CYCLE_ID = T.BILLING_CYCLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BILLING_CYCLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BILLING_CYCLE_ID,
      SUBT.LANGUAGE
    from AR_CONS_BILL_CYCLES_TL SUBB, AR_CONS_BILL_CYCLES_TL SUBT
    where SUBB.BILLING_CYCLE_ID = SUBT.BILLING_CYCLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CYCLE_NAME <> SUBT.CYCLE_NAME
  ));
  insert into AR_CONS_BILL_CYCLES_TL (
    BILLING_CYCLE_ID,
    CYCLE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BILLING_CYCLE_ID,
    B.CYCLE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_CONS_BILL_CYCLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_CONS_BILL_CYCLES_TL T
    where T.BILLING_CYCLE_ID = B.BILLING_CYCLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_BILLING_CYCLE_ID in NUMBER,
  X_CYCLE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) IS
Begin
    update AR_CONS_BILL_CYCLES_TL
      set CYCLE_NAME = X_CYCLE_NAME,
          DESCRIPTION = X_DESCRIPTION,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where BILLING_CYCLE_ID = X_BILLING_CYCLE_ID
    and   userenv('LANG') in (language, source_lang);
END TRANSLATE_ROW;

procedure LOAD_ROW (
 X_BILLING_CYCLE_ID in NUMBER,
 X_BILL_CYCLE_TYPE IN VARCHAR2,
 X_CYCLE_NAME IN VARCHAR2,
 X_DESCRIPTION IN VARCHAR2,
 X_CYCLE_FREQUENCY IN VARCHAR2,
 X_START_DATE IN DATE,
 X_LAST_DAY IN VARCHAR2,
 X_DAY_1 IN VARCHAR2,
 X_DAY_2 IN VARCHAR2,
 X_DAY_3 IN VARCHAR2,
 X_DAY_4 IN VARCHAR2,
 X_DAY_5 IN VARCHAR2,
 X_DAY_6 IN VARCHAR2,
 X_DAY_7 IN VARCHAR2,
 X_DAY_8 IN VARCHAR2,
 X_DAY_9 IN VARCHAR2,
 X_DAY_10 IN VARCHAR2,
 X_DAY_11 IN VARCHAR2,
 X_DAY_12 IN VARCHAR2,
 X_DAY_13 IN VARCHAR2,
 X_DAY_14 IN VARCHAR2,
 X_DAY_15 IN VARCHAR2,
 X_DAY_16 IN VARCHAR2,
 X_DAY_17 IN VARCHAR2,
 X_DAY_18 IN VARCHAR2,
 X_DAY_19 IN VARCHAR2,
 X_DAY_20 IN VARCHAR2,
 X_DAY_21 IN VARCHAR2,
 X_DAY_22 IN VARCHAR2,
 X_DAY_23 IN VARCHAR2,
 X_DAY_24 IN VARCHAR2,
 X_DAY_25 IN VARCHAR2,
 X_DAY_26 IN VARCHAR2,
 X_DAY_27 IN VARCHAR2,
 X_DAY_28 IN VARCHAR2,
 X_DAY_29 IN VARCHAR2,
 X_DAY_30 IN VARCHAR2,
 X_DAY_31 IN VARCHAR2,
 X_DAY_MONDAY IN VARCHAR2,
 X_DAY_TUESDAY IN VARCHAR2,
 X_DAY_WEDNESDAY IN VARCHAR2,
 X_DAY_THURSDAY IN VARCHAR2,
 X_DAY_FRIDAY IN VARCHAR2,
 X_DAY_SATURDAY IN VARCHAR2,
 X_DAY_SUNDAY IN VARCHAR2,
 X_SKIP_WEEKENDS IN VARCHAR2,
 X_SKIP_HOLIDAYS IN VARCHAR2,
 X_REPEAT_DAILY IN NUMBER,
 X_REPEAT_WEEKLY IN NUMBER,
 X_REPEAT_MONTHLY IN NUMBER,
 X_DAY_TYPE   IN VARCHAR2,
 X_OWNER IN VARCHAR2
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
     ob_version         number:= 0;
   begin
     if (X_OWNER = 'SEED') then
        user_id := 1;
    end if;

    AR_CONS_BILL_CYCLE_PKG.UPDATE_ROW (
        X_BILLING_CYCLE_ID => X_BILLING_CYCLE_ID,
        X_BILL_CYCLE_TYPE => X_BILL_CYCLE_TYPE,
        X_CYCLE_NAME => X_CYCLE_NAME,
        X_DESCRIPTION => X_DESCRIPTION,
        X_CYCLE_FREQUENCY => X_CYCLE_FREQUENCY,
        X_START_DATE => X_START_DATE,
        X_LAST_DAY => X_LAST_DAY,
        X_DAY_1 => X_DAY_1,
        X_DAY_2 => X_DAY_2,
        X_DAY_3 => X_DAY_3,
        X_DAY_4 => X_DAY_4,
        X_DAY_5 => X_DAY_5,
        X_DAY_6 => X_DAY_6,
        X_DAY_7 => X_DAY_7,
        X_DAY_8 => X_DAY_8,
        X_DAY_9 => X_DAY_9,
        X_DAY_10 => X_DAY_10,
        X_DAY_11 => X_DAY_11,
        X_DAY_12 => X_DAY_12,
        X_DAY_13 => X_DAY_13,
        X_DAY_14 => X_DAY_14,
        X_DAY_15 => X_DAY_15,
        X_DAY_16 => X_DAY_16,
        X_DAY_17 => X_DAY_17,
        X_DAY_18 => X_DAY_18,
        X_DAY_19 => X_DAY_19,
        X_DAY_20 => X_DAY_20,
        X_DAY_21 => X_DAY_21,
        X_DAY_22 => X_DAY_22,
        X_DAY_23 => X_DAY_23,
        X_DAY_24 => X_DAY_24,
        X_DAY_25 => X_DAY_25,
        X_DAY_26 => X_DAY_26,
        X_DAY_27 => X_DAY_27,
        X_DAY_28 => X_DAY_28,
        X_DAY_29 => X_DAY_29,
        X_DAY_30 => X_DAY_30,
        X_DAY_31 => X_DAY_31,
        X_DAY_MONDAY => X_DAY_MONDAY,
        X_DAY_TUESDAY => X_DAY_TUESDAY,
        X_DAY_WEDNESDAY => X_DAY_WEDNESDAY,
        X_DAY_THURSDAY => X_DAY_THURSDAY,
        X_DAY_FRIDAY => X_DAY_FRIDAY,
        X_DAY_SATURDAY => X_DAY_SATURDAY,
        X_DAY_SUNDAY   => X_DAY_SUNDAY,
        X_SKIP_WEEKENDS => X_SKIP_WEEKENDS,
        X_SKIP_HOLIDAYS => X_SKIP_HOLIDAYS,
        X_REPEAT_DAILY => X_REPEAT_DAILY,
        X_REPEAT_WEEKLY => X_REPEAT_WEEKLY,
        X_REPEAT_MONTHLY => X_REPEAT_MONTHLY,
        X_DAY_TYPE => X_DAY_TYPE,
        X_OBJECT_VERSION_NUMBER => ob_version,
        X_LAST_UPDATE_DATE               => sysdate,
        X_LAST_UPDATED_BY                => user_id,
        X_LAST_UPDATE_LOGIN      => 0);
    exception
       when NO_DATA_FOUND then
           AR_CONS_BILL_CYCLE_PKG.INSERT_ROW (
                 X_ROWID                                 => row_id,
        X_BILLING_CYCLE_ID => X_BILLING_CYCLE_ID,
        X_BILL_CYCLE_TYPE => X_BILL_CYCLE_TYPE,
        X_CYCLE_NAME => X_CYCLE_NAME,
        X_DESCRIPTION => X_DESCRIPTION,
        X_CYCLE_FREQUENCY => X_CYCLE_FREQUENCY,
        X_START_DATE => X_START_DATE,
        X_LAST_DAY => X_LAST_DAY,
        X_DAY_1 => X_DAY_1,
        X_DAY_2 => X_DAY_2,
        X_DAY_3 => X_DAY_3,
        X_DAY_4 => X_DAY_4,
        X_DAY_5 => X_DAY_5,
        X_DAY_6 => X_DAY_6,
        X_DAY_7 => X_DAY_7,
        X_DAY_8 => X_DAY_8,
        X_DAY_9 => X_DAY_9,
        X_DAY_10 => X_DAY_10,
        X_DAY_11 => X_DAY_11,
        X_DAY_12 => X_DAY_12,
        X_DAY_13 => X_DAY_13,
        X_DAY_14 => X_DAY_14,
        X_DAY_15 => X_DAY_15,
        X_DAY_16 => X_DAY_16,
        X_DAY_17 => X_DAY_17,
        X_DAY_18 => X_DAY_18,
        X_DAY_19 => X_DAY_19,
        X_DAY_20 => X_DAY_20,
        X_DAY_21 => X_DAY_21,
        X_DAY_22 => X_DAY_22,
        X_DAY_23 => X_DAY_23,
        X_DAY_24 => X_DAY_24,
        X_DAY_25 => X_DAY_25,
        X_DAY_26 => X_DAY_26,
        X_DAY_27 => X_DAY_27,
        X_DAY_28 => X_DAY_28,
        X_DAY_29 => X_DAY_29,
        X_DAY_30 => X_DAY_30,
        X_DAY_31 => X_DAY_31,
        X_DAY_MONDAY => X_DAY_MONDAY,
        X_DAY_TUESDAY => X_DAY_TUESDAY,
        X_DAY_WEDNESDAY => X_DAY_WEDNESDAY,
        X_DAY_THURSDAY => X_DAY_THURSDAY,
        X_DAY_FRIDAY => X_DAY_FRIDAY,
        X_DAY_SATURDAY => X_DAY_SATURDAY,
        X_DAY_SUNDAY   => X_DAY_SUNDAY,
        X_SKIP_WEEKENDS => X_SKIP_WEEKENDS,
        X_SKIP_HOLIDAYS => X_SKIP_HOLIDAYS,
        X_REPEAT_DAILY => X_REPEAT_DAILY,
        X_REPEAT_WEEKLY => X_REPEAT_WEEKLY,
        X_REPEAT_MONTHLY => X_REPEAT_MONTHLY,
        X_DAY_TYPE => X_DAY_TYPE,
                                X_CREATION_DATE              => sysdate,
                X_CREATED_BY                     => user_id,
                X_LAST_UPDATE_DATE               => sysdate,
                X_LAST_UPDATED_BY                => user_id,
                X_LAST_UPDATE_LOGIN      => 0,
        X_OBJECT_VERSION_NUMBER => 1);
    end;
end LOAD_ROW;



END AR_CONS_BILL_CYCLE_PKG;

/
