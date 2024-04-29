--------------------------------------------------------
--  DDL for Package Body JTF_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CALENDARS_PKG" as
/* $Header: jtfcldcb.pls 120.4.12010000.2 2008/09/08 09:17:29 anangupt ship $ */
procedure INSERT_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_ROWID in out NOCOPY VARCHAR2,
  X_CALENDAR_ID in out NOCOPY NUMBER,
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
  X_CALENDAR_TYPE in VARCHAR2,
  X_CALENDAR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_CALENDARS_B
    where CALENDAR_ID = X_CALENDAR_ID;

	v_error CHAR := 'N';
	v_calendar_id NUMBER;

  temp_count number := 0;
begin
		fnd_msg_pub.initialize;

IF  JTF_CALENDARS_PKG.NOT_NULL(X_CALENDAR_NAME) = FALSE THEN
           fnd_message.set_name('JTF', 'JTF_CAL_CALENDAR_NAME');
			--fnd_message.set_token('P_NAME', nvl(X_CALENDAR_NAME,'Calendar Name '));
			fnd_msg_pub.add;
			v_error := 'Y';
        END IF;

IF  JTF_CALENDARS_PKG.NOT_NULL(X_CALENDAR_TYPE) = FALSE THEN
           fnd_message.set_name('JTF', 'JTF_CAL_CALENDAR_TYPE');
			--fnd_message.set_token('P_NAME', nvl(X_CALENDAR_TYPE,'Calendar Type '));
			fnd_msg_pub.add;
			v_error := 'Y';
        END IF;


        select count(*) into temp_count
          FROM JTF_CALENDARS_VL
          WHERE upper(calendar_name) = upper(X_CALENDAR_NAME)
          AND UPPER(calendar_type) = upper(X_CALENDAR_TYPE)
	  --- Added for bug 5123027 by abraina
          and (
               start_date_active <= nvl(X_END_DATE_ACTIVE,to_date('12/31/9999','mm/dd/yyyy'))
          and
               nvl(end_date_active,to_date('12/31/9999','mm/dd/yyyy')) >= X_START_DATE_ACTIVE
               ) ;

	  IF temp_count > 0 THEN
           	 fnd_message.set_name('JTF', 'JTF_CAL_DUP_NAME');
			 fnd_message.set_token('P_NAME', X_CALENDAR_NAME);
			 fnd_msg_pub.add;
			v_error := 'Y';
          END IF;


		IF JTF_CALENDARS_PKG.NOT_NULL(X_START_DATE_ACTIVE) = FALSE THEN

			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;

			v_error := 'Y';
		END IF;


		IF JTF_CALENDARS_PKG.END_GREATER_THAN_BEGIN(X_START_DATE_ACTIVE, X_END_DATE_ACTIVE) = FALSE 													THEN
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
			SELECT 	JTF_CALENDARS_S.nextval
			INTO	v_calendar_id
			FROM	dual;

                        X_CALENDAR_ID := v_calendar_id;

		   insert into JTF_CALENDARS_B (
		    OBJECT_VERSION_NUMBER,
		    CALENDAR_ID,
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
		    CALENDAR_TYPE,
		    CREATION_DATE,
		    CREATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_LOGIN
		  ) values (
		    nvl(X_OBJECT_VERSION_NUMBER,1),
		    v_calendar_id,
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
		    X_CALENDAR_TYPE,
		    sysdate,
		    FND_GLOBAL.USER_ID,
		    sysdate,
		    FND_GLOBAL.USER_ID,
		    NULL
		  );

		  insert into JTF_CALENDARS_TL (
		    CALENDAR_ID,
		    CALENDAR_NAME,
		    DESCRIPTION,
		    CREATED_BY,
		    CREATION_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
		    LANGUAGE,
		    SOURCE_LANG
		  ) select
		    v_calendar_id,
		    X_CALENDAR_NAME,
		    X_DESCRIPTION,
		    FND_GLOBAL.USER_ID,
		    sysdate,
		    FND_GLOBAL.USER_ID,
		    sysdate,
		    NULL,
		    L.LANGUAGE_CODE,
		    userenv('LANG')
		  from FND_LANGUAGES L
		  where L.INSTALLED_FLAG in ('I', 'B')
		  and not exists
		    (select NULL
		    from JTF_CALENDARS_TL T
		    where T.CALENDAR_ID = X_CALENDAR_ID
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
  X_CALENDAR_ID in NUMBER,
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
  X_CALENDAR_TYPE in VARCHAR2,
  X_CALENDAR_NAME in VARCHAR2,
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
      ATTRIBUTE_CATEGORY,
      CALENDAR_TYPE
    from JTF_CALENDARS_B
    where CALENDAR_ID = X_CALENDAR_ID
    for update of CALENDAR_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CALENDAR_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_CALENDARS_TL
    where CALENDAR_ID = X_CALENDAR_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CALENDAR_ID nowait;
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
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
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
      AND ((recinfo.CALENDAR_TYPE = X_CALENDAR_TYPE)
           OR ((recinfo.CALENDAR_TYPE is null) AND (X_CALENDAR_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('JTF', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.CALENDAR_NAME = X_CALENDAR_NAME)
               OR ((tlinfo.CALENDAR_NAME is null) AND (X_CALENDAR_NAME is null)))
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
  X_CALENDAR_ID in NUMBER,
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
  X_CALENDAR_TYPE in VARCHAR2,
  X_CALENDAR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
		v_error CHAR := 'N';
 -- changed var length from 100 to 240 for bug 2863718 by A.Raina
    v_desc varchar2(240);
    v_start_date DATE;
 temp_count NUMBER := 0;

begin
		fnd_msg_pub.initialize;

        IF  JTF_CALENDARS_PKG.NOT_NULL(X_CALENDAR_NAME) = FALSE THEN
           fnd_message.set_name('JTF', 'JTF_CAL_CALENDAR_NAME');
			--fnd_message.set_token('P_NAME', nvl(X_CALENDAR_NAME,'Calendar Name '));
			fnd_msg_pub.add;
			v_error := 'Y';
        END IF;

IF  JTF_CALENDARS_PKG.NOT_NULL(X_CALENDAR_TYPE) = FALSE THEN
           fnd_message.set_name('JTF', 'JTF_CAL_CALENDAR_TYPE');
			--fnd_message.set_token('P_NAME', nvl(X_CALENDAR_TYPE,'Calendar Type '));
			fnd_msg_pub.add;
			v_error := 'Y';
        END IF;

      IF v_error <> 'Y' THEN

      select count(*) into temp_count
      FROM jtf_calendars_vl
      WHERE upper(calendar_name) = upper(X_CALENDAR_NAME)
      AND UPPER(calendar_type) = upper(X_CALENDAR_TYPE)
      --- Added for bug 5123027 by abraina
          and (
               start_date_active <= nvl(X_END_DATE_ACTIVE,to_date('12/31/9999','mm/dd/yyyy'))
          and
               nvl(end_date_active,to_date('12/31/9999','mm/dd/yyyy')) >= X_START_DATE_ACTIVE
               )
      AND calendar_id <> X_CALENDAR_ID;


      IF temp_count > 0 THEN
	    fnd_message.set_name('JTF', 'JTF_CAL_DUP_NAME');
		fnd_message.set_token('P_NAME', X_CALENDAR_NAME);
		fnd_msg_pub.add;
		v_error := 'Y';
      END IF;
      END IF;
		IF JTF_CALENDARS_PKG.NOT_NULL(X_START_DATE_ACTIVE) = FALSE THEN

			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;

			v_error := 'Y';
		END IF;


		IF JTF_CALENDARS_PKG.END_GREATER_THAN_BEGIN(X_START_DATE_ACTIVE, X_END_DATE_ACTIVE) = FALSE 													THEN
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

		  update JTF_CALENDARS_B set
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
		    CALENDAR_TYPE = X_CALENDAR_TYPE,
		    LAST_UPDATE_DATE = sysdate,
		    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		  where CALENDAR_ID = X_CALENDAR_ID;

		  if (sql%notfound) then
		    raise no_data_found;
		  end if;

		  update JTF_CALENDARS_TL set
		    CALENDAR_NAME = X_CALENDAR_NAME,
		    DESCRIPTION = X_DESCRIPTION,
		    LAST_UPDATE_DATE = sysdate,
		    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
		    SOURCE_LANG = userenv('LANG')
		  where CALENDAR_ID = X_CALENDAR_ID
		  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

		  if (sql%notfound) then
		    raise no_data_found;
		  end if;
		END IF;
end UPDATE_ROW;

Procedure TRANSLATE_ROW
(X_CALENDAR_ID  in number,
 X_CALENDAR_NAME in varchar2,
 X_DESCRIPTION in varchar2,
 X_LAST_UPDATE_DATE in date,
 X_LAST_UPDATED_BY in number,
 X_LAST_UPDATE_LOGIN in number)
is
begin

Update JTF_CALENDARS_TL set
calendar_name		= nvl(X_CALENDAR_NAME,calendar_name),
description		= nvl(X_DESCRIPTION,description),
last_update_date	= nvl(x_last_update_date,sysdate),
last_updated_by		= x_last_updated_by,
last_update_login	= 0,
source_lang		= userenv('LANG')
where calendar_id		= X_CALENDAR_ID
and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

procedure DELETE_ROW (
  X_CALENDAR_ID in NUMBER
) is
begin
  delete from JTF_CALENDARS_TL
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_CALENDARS_B
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_CALENDARS_TL T
  where not exists
    (select NULL
    from JTF_CALENDARS_B B
    where B.CALENDAR_ID = T.CALENDAR_ID
    );

  update JTF_CALENDARS_TL T set (
      CALENDAR_NAME,
      DESCRIPTION
    ) = (select
      B.CALENDAR_NAME,
      B.DESCRIPTION
    from JTF_CALENDARS_TL B
    where B.CALENDAR_ID = T.CALENDAR_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CALENDAR_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CALENDAR_ID,
      SUBT.LANGUAGE
    from JTF_CALENDARS_TL SUBB, JTF_CALENDARS_TL SUBT
    where SUBB.CALENDAR_ID = SUBT.CALENDAR_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CALENDAR_NAME <> SUBT.CALENDAR_NAME
      or (SUBB.CALENDAR_NAME is null and SUBT.CALENDAR_NAME is not null)
      or (SUBB.CALENDAR_NAME is not null and SUBT.CALENDAR_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTF_CALENDARS_TL (
    CALENDAR_ID,
    CALENDAR_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CALENDAR_ID,
    B.CALENDAR_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_CALENDARS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_CALENDARS_TL T
    where T.CALENDAR_ID = B.CALENDAR_ID
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
/*************************************************************************/
	procedure UPDATE_TASK(task_id IN NUMBER, task_name IN CHAR, description IN CHAR, priority IN NUMBER, planned_start_date IN DATE,
				planned_end_date IN DATE, task_status_id IN NUMBER) IS
		l_rs varchar2(1) ;
		x number := 3;
		l_msg_count number  ;
		l_msg_data varchar2(2000) ;
		v_task_id number := task_id;
		v_task_assignment_id number;

	BEGIN

		select jtf_tasks_b.object_version_number
		into x
		from jtf_tasks_b
		where task_id = v_task_id;

		jtf_tasks_pub.update_task(
				P_API_VERSION  		=> 1.0 ,
				P_INIT_MSG_LIST 	=> fnd_api.g_false ,
				P_COMMIT   		=> fnd_api.g_false ,
				P_TASK_ID   		=> v_task_id ,
				P_TASK_NAME   		=> task_name  ,
				P_TASK_STATUS_ID	=> task_status_id,
				P_DESCRIPTION		=> 'Hard Coded',
				P_TASK_PRIORITY_ID	=> priority,
				p_object_version_number => x ,
				p_planned_start_date 	=> planned_start_date ,
				p_planned_end_date 	=> planned_end_date ,
				p_bound_mode_code 	=> 'y',
				X_RETURN_STATUS   	=> l_rs,
				X_MSG_COUNT   		=> l_msg_count,
				X_MSG_DATA   		=> l_msg_data);


			select	task_assignment_id
			into	v_task_assignment_id
			from 	jtf_task_assignments
			where	task_id = v_task_id;

			select 	object_version_number
			into 	x
			from	jtf_task_assignments
			where 	task_assignment_id = v_task_assignment_id;

		jtf_task_assignments_pub.update_task_assignment(
				P_API_VERSION           => 1 ,
				p_init_msg_list 	=>  fnd_api.g_true ,
				p_commit 		=>  fnd_api.g_true ,
				p_task_assignment_id 	=> v_task_assignment_id,
				p_object_version_number => x ,
				P_ACTUAL_EFFORT 	=> NULL,
				P_ACTUAL_EFFORT_UOM 	=> NULL,
				P_ALARM_TYPE_CODE 	=> NULL ,
				P_ALARM_CONTACT 	=> NULL ,
				P_SCHED_TRAVEL_DURATION => NULL,
				P_SCHED_TRAVEL_DURATION_UOM => NULL ,
				p_shift_construct_id 	=> null ,
				P_ASSIGNMENT_STATUS_ID 	=>	task_status_id,
				X_RETURN_STATUS   	=>   l_rs ,
				X_MSG_COUNT   		=>  l_msg_count ,
				X_MSG_DATA   		=>   l_msg_data  ) ;


	END;
/*************************************************************************/
	procedure CREATE_TASK(task_name IN CHAR, description IN CHAR, priority IN NUMBER, planned_start_date IN DATE,
					planned_end_date IN DATE, resource_type IN CHAR, resource_id IN NUMBER,
					task_status_id IN NUMBER) IS





		l_rs varchar2(1) ;
		x number ;
		v_task_assignment_id NUMBER;
		l_msg_count number  ;
		l_msg_data varchar2(2000) ;
		recurs jtf_tasks_pub.task_recur_rec ;
		rsc jtf_tasks_pub.task_rsrc_req_tbl ;
		ass  jtf_tasks_pub.task_assign_tbl ;
		notes jtf_tasks_pub.task_notes_tbl ;
	begin
		recurs.OCCURS_WHICH                 	:= 2 ;
		recurs.DAY_OF_WEEK                 	:= 2 ;
		recurs.DATE_OF_MONTH              	:= NULL ;
		recurs.OCCURS_MONTH              	:= 1 ;
		recurs.OCCURS_UOM               	:= 'YR' ;
		recurs.OCCURS_EVERY            		:= 1 ;
		recurs.OCCURS_NUMBER            	:= 50 ;
		recurs.START_DATE_ACTIVE      		:= sysdate ;
		recurs.end_DATE_ACTIVE          	:= NULL ;
		rsc(1).resource_type_code 		:= 'SO' ;
		rsc(1).required_units 			:= 100 ;
		rsc(1).enabled_flag 			:= 'Y' ;
		ass(1).resource_type_code 		:= 'SO' ;
		ass(1).resource_id 			:= 100 ;
		notes(1).parent_note_id			:= null;
		notes(1).org_id				:=  173 ;
		notes(1).notes				:= 'Notes' ;
		notes(1).notes_detail 			:= null ;
		notes(1).note_status			:= null ;
		notes(1).entered_by			:=  -1 ;
		notes(1).entered_date			:= sysdate ;
		notes(1).note_type   			:= null ;
				jtf_tasks_pub.create_task(
						P_API_VERSION   	=>   1.0 ,
						P_INIT_MSG_LIST   	=>   fnd_api.g_true ,
						P_COMMIT   		=>   fnd_api.g_true  ,
						p_task_id 		=>   null ,
						P_TASK_NAME   		=>  task_name ,
						P_TASK_TYPE_NAME   	=>   null ,
						P_TASK_TYPE_ID  	=>   3 ,
						P_DESCRIPTION   	=>   description ,
						P_TASK_STATUS_NAME   	=>  null,
						P_TASK_STATUS_ID   	=>   task_status_id,
						P_TASK_PRIORITY_NAME   	=>   'Low',
						P_TASK_PRIORITY_ID   	=>   priority,
						P_OWNER_TYPE_NAME   	=>   NULL,
						P_OWNER_TYPE_CODE   	=>   'RS_EMPLOYEE',
						P_OWNER_ID   		=>   101 ,
						P_OWNER_TERRITORY_ID 	=>   NULL ,
						P_ASSIGNED_BY_NAME   	=>   NULL ,
						P_ASSIGNED_BY_ID   	=>   NULL ,
						P_CUSTOMER_NUMBER   	=>   NULL ,
						P_CUSTOMER_ID   	=>   NULL ,
						P_CUST_ACCOUNT_NUMBER   =>   NULL ,
						P_CUST_ACCOUNT_ID   	=>   NULL ,
						P_ADDRESS_ID   		=>   NULL ,
						P_ADDRESS_NUMBER   	=>   NULL ,
						P_PLANNED_START_DATE   	=>   planned_start_date,
						P_PLANNED_END_DATE   	=>   planned_end_date,
						P_SCHEDULED_START_DATE 	=>   planned_start_date,
						P_SCHEDULED_END_DATE   	=>   planned_end_date,
						P_ACTUAL_START_DATE   	=>   NULL ,
						P_ACTUAL_END_DATE   	=>   NULL ,
						P_TIMEZONE_ID   	=>   NULL ,
						P_TIMEZONE_NAME   	=>   NULL ,
						P_SOURCE_OBJECT_TYPE_CODE   => 'SR' ,
						P_SOURCE_OBJECT_ID 	=>  16515,
						P_SOURCE_OBJECT_NAME   	=>  3753,
						--P_SOURCE_OBJECT_ID 	=>  21653 ,
						--P_SOURCE_OBJECT_NAME  =>  21191 ,
						--P_DURATION   		=>   10 ,
						p_escalation_level 	=>  null,
						--P_DURATION_UOM   	=>   'DAY' ,
						P_PLANNED_EFFORT   	=>   NULL ,
						P_PLANNED_EFFORT_UOM   	=>   NULL ,
						P_ACTUAL_EFFORT   	=>   NULL ,
						P_ACTUAL_EFFORT_UOM   	=>   NULL ,
						P_PERCENTAGE_COMPLETE   =>   NULL ,
						P_REASON_CODE   	=>   NULL ,
						P_PRIVATE_FLAG   	=>   'Y' ,
						P_PUBLISH_FLAG   	=>   NULL ,
						P_RESTRICT_CLOSURE_FLAG =>   NULL ,
						P_MULTI_BOOKED_FLAG   	=>   NULL ,
						P_MILESTONE_FLAG   	=>   NULL ,
						P_HOLIDAY_FLAG   	=>   NULL ,
						P_BILLABLE_FLAG   	=>   NULL ,
						P_BOUND_MODE_CODE   	=>   'x' ,
						P_SOFT_BOUND_FLAG   	=>   NULL ,
						P_NOTIFICATION_FLAG   	=>   NULL ,
						P_NOTIFICATION_PERIOD   =>   NULL ,
						P_NOTIFICATION_PERIOD_UOM   =>   NULL ,
						P_PARENT_TASK_NUMBER   	=>   NULL ,
						P_PARENT_TASK_ID   	=>   NULL ,
						P_ALARM_START   	=>   NULL ,
						P_ALARM_START_UOM   	=>   NULL ,
						P_ALARM_ON   		=>   NULL ,
						P_ALARM_COUNT   	=>   NULL ,
						P_ALARM_INTERVAL   	=>   NULL ,
						P_ALARM_INTERVAL_UOM   	=>   NULL ,
						P_PALM_FLAG   		=>   NULL ,
						P_WINCE_FLAG   		=>   NULL ,
						P_LAPTOP_FLAG   	=>   NULL ,
						P_DEVICE1_FLAG   	=>   NULL ,
						P_DEVICE2_FLAG   	=>   NULL ,
						P_DEVICE3_FLAG   	=>   NULL ,
						P_COSTS   		=>   NULL ,
						P_CURRENCY_CODE   	=>   NULL ,
						--P_TASK_RECUR_REC 	=> recurs ,
						--p_task_rsrc_req_tbl 	=> rsc ,
						--p_task_assign_tbl 	=> ass ,
						--p_task_notes_tbl 	=> notes ,
						X_RETURN_STATUS   	=>   l_rs ,
						X_MSG_COUNT   		=>   l_msg_count ,
						X_MSG_DATA   		=>   l_msg_data  ,
						X_TASK_ID   		=>   x  ) ;


			jtf_task_assignments_pub.create_task_assignment(
						P_API_VERSION		=>	1.0,
					 	p_init_msg_list 	=> 	fnd_api.g_false,
						p_commit 		=> 	fnd_api.g_false,
						P_TASK_ID		=>	x,
						P_RESOURCE_TYPE_CODE	=>	resource_type,
						P_RESOURCE_ID		=>	resource_id,
						P_ASSIGNMENT_STATUS_ID	=>	task_status_id,
						X_TASK_ASSIGNMENT_ID	=>	v_task_assignment_id,
						X_RETURN_STATUS		=>	l_rs,
						X_MSG_COUNT		=>	l_msg_count,
						X_MSG_DATA		=>	l_msg_data);


	end;
end JTF_CALENDARS_PKG;

/
