--------------------------------------------------------
--  DDL for Package Body EAM_SAFETY_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SAFETY_STATUSES_PKG" as
/* $Header: EAMSFSTB.pls 120.0.12010000.4 2010/03/24 14:30:47 vboddapa noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMSFSTB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_SAFETY_STATUSES_PKG
--
--  NOTES
--
--  HISTORY
--
--  24-MAR-2010    vboddapa     Initial Creation
***************************************************************************/


--This procedure will insert new rows in EAM_SAFETY_USR_DEF_STATUSES_B and eam_safety_usr_def_statuses_tl tables
procedure INSERT_ROW (
                X_ROWID						 in out NOCOPY VARCHAR2,
                X_STATUS_ID					  in out NOCOPY NUMBER,
                P_SEEDED_FLAG				in VARCHAR2,
                P_SYSTEM_STATUS			in NUMBER,
                P_ENABLED_FLAG				in VARCHAR2,
                P_USER_DEFINED_STATUS		 in VARCHAR2,
                P_ENTITY_TYPE	        in NUMBER,
                P_CREATION_DATE				in DATE,
                P_CREATED_BY				in NUMBER,
                P_LAST_UPDATE_DATE			in DATE,
                P_LAST_UPDATED_BY			in NUMBER,
                P_LAST_UPDATE_LOGIN		in NUMBER
                ) is

                cursor C is select ROWID from eam_safety_usr_def_statuses_b
                where STATUS_ID = X_STATUS_ID and
                entity_type = P_ENTITY_TYPE;

                CURSOR C2 IS SELECT eam_wo_statuses_b_s.nextval FROM sys.dual;

begin
				if (X_Status_Id is NULL) then
						   OPEN C2;
						   FETCH C2 INTO X_Status_ID;
						   CLOSE C2;
				end if;


                insert into eam_safety_usr_def_statuses_b (
							    STATUS_ID,
							    SEEDED_FLAG,
                  ENTITY_TYPE,
							    SYSTEM_STATUS,
							    ENABLED_FLAG,
							    CREATION_DATE,
							    CREATED_BY,
							    LAST_UPDATE_DATE,
							    LAST_UPDATED_BY,
							    LAST_UPDATE_LOGIN
							  ) values (
							    X_STATUS_ID,
							    P_SEEDED_FLAG,
                  P_ENTITY_TYPE,
							    P_SYSTEM_STATUS,
							    P_ENABLED_FLAG,
							    P_CREATION_DATE,
							    P_CREATED_BY,
							    P_LAST_UPDATE_DATE,
							    P_LAST_UPDATED_BY,
							    P_LAST_UPDATE_LOGIN
							  );

                IF( P_USER_DEFINED_STATUS IS NOT NULL) THEN
                  -- user_defined_status will be Null for seeded WIP statuses

                    insert into eam_safety_usr_def_statuses_tl (
											    LAST_UPDATE_LOGIN,
											    CREATION_DATE,
											    STATUS_ID,
											    USER_DEFINED_STATUS,
                          ENTITY_TYPE,
											    LAST_UPDATE_DATE,
											    LAST_UPDATED_BY,
											    CREATED_BY,
											    LANGUAGE,
											    SOURCE_LANG
											  ) select
											    P_LAST_UPDATE_LOGIN,
											    P_CREATION_DATE,
											    X_STATUS_ID,
											    P_USER_DEFINED_STATUS,
                          P_ENTITY_TYPE,
											    P_LAST_UPDATE_DATE,
											    P_LAST_UPDATED_BY,
											    P_CREATED_BY,
											    L.LANGUAGE_CODE,
											    userenv('LANG')
                    from
											      FND_LANGUAGES L
                    where
                          L.INSTALLED_FLAG in ('I', 'B')
												  and not exists
												    (select NULL
												    from eam_safety_usr_def_statuses_tl T
												    where T.STATUS_ID = X_STATUS_ID
												    and T.LANGUAGE = L.LANGUAGE_CODE
                            and T.entity_type = P_ENTITY_TYPE);

											  open c;
											  fetch c into X_ROWID;
											  if (c%notfound) then
											    close c;
											    raise no_data_found;
											  end if;
											  close c;
					END IF;
end INSERT_ROW;

--This procedure will update rows in EAM_SAFETY_USR_DEF_STATUSES_B and eam_safety_usr_def_statuses_tl tables
procedure UPDATE_ROW (
  P_STATUS_ID					  in NUMBER,
  P_SEEDED_FLAG				in VARCHAR2,
  P_SYSTEM_STATUS			in NUMBER,
  P_ENABLED_FLAG				in VARCHAR2,
  P_USER_DEFINED_STATUS		 in VARCHAR2,
  P_ENTITY_TYPE	        in NUMBER,
  P_LAST_UPDATE_DATE			in DATE,
  P_LAST_UPDATED_BY			in NUMBER,
  P_LAST_UPDATE_LOGIN		in NUMBER,
  P_MODE                                              in VARCHAR2 DEFAULT 'FORMS'
) is

    l_user_id    NUMBER;
    l_resp_id     NUMBER;
    l_request_id    NUMBER;
begin

  update eam_safety_usr_def_statuses_b set
    SEEDED_FLAG = P_SEEDED_FLAG,
    SYSTEM_STATUS = P_SYSTEM_STATUS,
    ENABLED_FLAG  = P_ENABLED_FLAG,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where STATUS_ID = P_STATUS_ID and
  ENTITY_TYPE  = P_ENTITY_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

    IF (P_USER_DEFINED_STATUS IS NOT NULL) THEN
           -- user_defined_status will be Null for seeded WIP statuses

						  update eam_safety_usr_def_statuses_tl set
						    USER_DEFINED_STATUS = P_USER_DEFINED_STATUS,
						    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
						    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
						    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
						    SOURCE_LANG = userenv('LANG')
						  where STATUS_ID = P_STATUS_ID
						  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
              and ENTITY_TYPE  = P_ENTITY_TYPE;

						  if (sql%notfound) then
							raise no_data_found;
						  end if;

			     IF(p_mode = 'FORMS') THEN
							--Launch concurrent program to update work order intermedia index only when update_row is called from forms not during upgrade
							l_user_id       := fnd_global.user_id;
							l_resp_id      :=  fnd_global.resp_id;

							IF (l_user_id IS NOT NULL AND l_resp_id IS NOT NULL) THEN
								 FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id,426,0);
							  END IF;

							   l_request_id := fnd_request.submit_request('EAM', 'EAMVTCIS', '',
											 to_char(sysdate, 'YYYY/MM/DD HH24:MI'),
											 FALSE,
											 '2',
											 '5',
											 TO_CHAR(p_status_id)
											 );
			     END IF;
   END IF;

end UPDATE_ROW;



--This procedure will delete rows in EAM_SAFETY_USR_DEF_STATUSES_B and eam_safety_usr_def_statuses_tl tables
procedure DELETE_ROW (
  P_STATUS_ID in NUMBER,
  P_ENTITY_TYPE in NUMBER
) is
begin

  delete from eam_safety_usr_def_statuses_tl
  where STATUS_ID = P_STATUS_ID
  and ENTITY_TYPE = P_ENTITY_TYPE;

  delete from eam_safety_usr_def_statuses_b
  where STATUS_ID = P_STATUS_ID
  and ENTITY_TYPE = P_ENTITY_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

--This procedure will be called when a new langauge is installed. This will insert rows
-- in Eam_Wo_Statuses_TL table for the new langauge
procedure ADD_LANGUAGE
is
begin

  delete from eam_safety_usr_def_statuses_tl T
  where not exists
    (select NULL
    from eam_safety_usr_def_statuses_b B
    where B.STATUS_ID = T.STATUS_ID
    and  B.ENTITY_TYPE = T.ENTITY_TYPE
    );

  update eam_safety_usr_def_statuses_tl T set (
      USER_DEFINED_STATUS
    ) = (select
      B.USER_DEFINED_STATUS
    from
          eam_safety_usr_def_statuses_tl B
    where
         B.STATUS_ID = T.STATUS_ID
    and B.LANGUAGE = T.SOURCE_LANG
    and  B.ENTITY_TYPE = T.ENTITY_TYPE
    )
  where (
      T.STATUS_ID,
      T.LANGUAGE,
      T.ENTITY_TYPE
  ) in (select
      SUBT.STATUS_ID,
      SUBT.LANGUAGE,
      SUBT.ENTITY_TYPE
    from eam_safety_usr_def_statuses_tl SUBB, eam_safety_usr_def_statuses_tl SUBT
    where SUBB.STATUS_ID = SUBT.STATUS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and  SUBB.ENTITY_TYPE = SUBT.ENTITY_TYPE
    and (SUBB.USER_DEFINED_STATUS <> SUBT.USER_DEFINED_STATUS
    ));

  insert into eam_safety_usr_def_statuses_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    STATUS_ID,
    USER_DEFINED_STATUS,
    ENTITY_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.STATUS_ID,
    B.USER_DEFINED_STATUS,
    B.ENTITY_TYPE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from eam_safety_usr_def_statuses_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from eam_safety_usr_def_statuses_tl T
    where T.STATUS_ID = B.STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE
    and T.ENTITY_TYPE = B.ENTITY_TYPE);

end ADD_LANGUAGE;

--This procedure will be called for all the langauges to translate the User_Defined_Status value
procedure TRANSLATE_ROW
(			P_STATUS_ID						in NUMBER,
                         P_USER_DEFINED_STATUS			in VARCHAR2,
                         P_ENTITY_TYPE in NUMBER,
                         P_OWNER							in VARCHAR2,
                         P_LAST_UPDATE_DATE				in VARCHAR2,
                         P_CUSTOM_MODE					in VARCHAR2
) IS

f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db

begin

      IF (P_USER_DEFINED_STATUS IS NOT NULL) THEN
           -- user_defined_status will be Null for seeded WIP statuses
											  f_luby := fnd_load_util.owner_id(P_OWNER);
											  f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

											  select LAST_UPDATED_BY, LAST_UPDATE_DATE
											  into  db_luby, db_ludate
											  from eam_safety_usr_def_statuses_tl
											  where STATUS_ID = P_STATUS_ID
											  and  language = userenv('LANG')
                        and ENTITY_TYPE = P_ENTITY_TYPE;

											  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
															db_ludate, P_CUSTOM_MODE)) then

														    update eam_safety_usr_def_statuses_tl set
														      user_defined_status = P_USER_DEFINED_STATUS,
														      last_update_date  = f_ludate ,
														      last_updated_by   = f_luby,
														      last_update_login = 0,
														      source_lang       = userenv('LANG')
														    where STATUS_ID = P_STATUS_ID
														    and  userenv('LANG') in (language, source_lang)
                                and ENTITY_TYPE = P_ENTITY_TYPE;

											  end if;
	END IF;

exception
 when no_data_found then
    -- Do not insert missing translations, skip this row
    null;
end TRANSLATE_ROW;

--This procedure will be called during upgarde of seeded statuses
procedure LOAD_ROW
(
   X_STATUS_ID					  in out nocopy NUMBER,
   P_SEEDED_FLAG				in VARCHAR2,
   P_SYSTEM_STATUS			in NUMBER,
   P_ENABLED_FLAG				in VARCHAR2,
   P_USER_DEFINED_STATUS			 in VARCHAR2,
   P_ENTITY_TYPE	        in NUMBER,
   P_OWNER							in VARCHAR2,
   P_LAST_UPDATE_DATE			in VARCHAR2,
   P_CUSTOM_MODE					in VARCHAR2
) IS

l_row_id	  varchar2(64);
f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db

begin

  f_luby := fnd_load_util.owner_id(P_OWNER);
  f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into  db_luby, db_ludate
  from eam_safety_usr_def_statuses_b
  where status_id = X_STATUS_ID
  and ENTITY_TYPE = P_ENTITY_TYPE;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate,P_CUSTOM_MODE)) then

     UPDATE_ROW (X_STATUS_ID ,
                 P_SEEDED_FLAG ,
                 P_SYSTEM_STATUS ,
                 P_ENABLED_FLAG ,
                 P_USER_DEFINED_STATUS ,
                 P_ENTITY_TYPE,
                 f_ludate ,
                 f_luby ,
                 0,
		 'UPGRADE');

     end if;

  exception
     when NO_DATA_FOUND then

	 INSERT_ROW (l_row_id ,
			 X_STATUS_ID ,
			 P_SEEDED_FLAG ,
			 P_SYSTEM_STATUS ,
			 P_ENABLED_FLAG ,
			 P_USER_DEFINED_STATUS ,
       P_ENTITY_TYPE,
			  f_ludate ,
			  f_luby ,
			  f_ludate ,
			  f_luby ,
			  0 );

end LOAD_ROW;


end EAM_SAFETY_STATUSES_PKG;

/
