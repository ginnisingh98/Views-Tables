--------------------------------------------------------
--  DDL for Package Body AHL_WF_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_WF_MAPPING_PKG" as
/*$Header: AHLLWFMB.pls 115.6 2003/12/10 13:39:06 rroy noship $*/
procedure INSERT_ROW
(
  X_ROWID  		     IN out   NOCOPY VARCHAR2,
  X_WF_MAPPING_ID            IN        NUMBER,
  X_OBJECT_VERSION_NUMBER    IN        NUMBER,
  X_LAST_UPDATE_DATE         IN        DATE,
  X_LAST_UPDATED_BY          IN        NUMBER,
  X_CREATION_DATE            IN        DATE,
  X_CREATED_BY 		         IN        NUMBER,
  X_LAST_UPDATE_LOGIN        IN        NUMBER,
  X_ACTIVE_FLAG              IN        VARCHAR2,
  X_WF_PROCESS_NAME          IN        VARCHAR2,
  X_APPROVAL_OBJECT          IN        VARCHAR2,
  X_ITEM_TYPE                IN        VARCHAR2,
  X_APPLICATION_USG_CODE 	IN VARCHAR2
)
is
cursor C is select ROWID from AHL_WF_MAPPING where
            WF_MAPPING_ID = X_WF_MAPPING_ID ;
begin
insert into AHL_WF_MAPPING
(
  WF_MAPPING_ID           ,
  OBJECT_VERSION_NUMBER   ,
  LAST_UPDATE_DATE        ,
  LAST_UPDATED_BY         ,
  CREATION_DATE           ,
  CREATED_BY 		      ,
  LAST_UPDATE_LOGIN       ,
  ACTIVE_FLAG             ,
  WF_PROCESS_NAME         ,
  APPROVAL_OBJECT         ,
  ITEM_TYPE		  ,
  APPLICATION_USG_CODE
)
 values
(
  X_WF_MAPPING_ID            ,
  X_OBJECT_VERSION_NUMBER    ,
  X_LAST_UPDATE_DATE         ,
  X_LAST_UPDATED_BY          ,
  X_CREATION_DATE            ,
  X_CREATED_BY 		         ,
  X_LAST_UPDATE_LOGIN        ,
  X_ACTIVE_FLAG              ,
  X_WF_PROCESS_NAME          ,
  X_APPROVAL_OBJECT          ,
  X_ITEM_TYPE		     ,
  X_APPLICATION_USG_CODE
);

 open c;
 fetch c into X_ROWID;
 if (c%notfound) then
    close c;
 raise no_data_found;
 end if;
 close c;

end INSERT_ROW;

procedure UPDATE_ROW
(
  X_WF_MAPPING_ID            IN        NUMBER,
  X_OBJECT_VERSION_NUMBER    IN        NUMBER,
  X_LAST_UPDATE_DATE         IN        DATE,
  X_LAST_UPDATED_BY          IN        NUMBER,
  X_LAST_UPDATE_LOGIN        IN        NUMBER,
  X_ACTIVE_FLAG              IN        VARCHAR2,
  X_WF_PROCESS_NAME          IN        VARCHAR2,
  X_APPROVAL_OBJECT          IN        VARCHAR2,
  X_ITEM_TYPE     IN        VARCHAR2,
X_APPLICATION_USG_CODE 	IN VARCHAR2
) is
begin
  update AHL_WF_MAPPING set
  WF_MAPPING_ID         =  X_WF_MAPPING_ID,
  OBJECT_VERSION_NUMBER =  X_OBJECT_VERSION_NUMBER,
  LAST_UPDATE_DATE 	=  X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY 	=  X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN 	=  X_LAST_UPDATE_LOGIN,
  ACTIVE_FLAG           =  X_ACTIVE_FLAG ,
  WF_PROCESS_NAME       =  X_WF_PROCESS_NAME,
  APPROVAL_OBJECT       =  X_APPROVAL_OBJECT,
  ITEM_TYPE             =  X_ITEM_TYPE,
  APPLICATION_USG_CODE  = X_APPLICATION_USG_CODE
  where WF_MAPPING_ID   =  X_WF_MAPPING_ID;

if (sql%notfound) then
  raise no_data_found;
end if;

end UPDATE_ROW;

procedure LOAD_ROW
(
  X_WF_MAPPING_ID            IN        NUMBER,
  X_ACTIVE_FLAG              IN        VARCHAR2,
  X_APPLICATION_USG_CODE 	IN VARCHAR2,
  X_ITEM_TYPE			IN VARCHAR2,
  X_WF_PROCESS_NAME		IN VARCHAR2,
  X_APPROVAL_OBJECT IN VARCHAR2,
  X_OWNER in VARCHAR2

)
is
  l_user_id     number := 0;
  l_obj_verno   number;
  l_dummy_char  varchar2(1);
  l_row_id      varchar2(100);
  l_wfm_id      number;


		cursor  c_obj_verno is
  select  object_version_number
  from    AHL_WF_MAPPING
  where   WF_MAPPING_ID =  X_WF_MAPPING_ID;

cursor c_chk_wfm_exists is
  select 'x'
  from   AHL_WF_MAPPING
  where  WF_MAPPING_ID =  X_WF_MAPPING_ID;

cursor c_get_wfm_id is
   select Ahl_Wf_Mapping_S.NEXTVAL
   from dual;
begin
if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_wfm_exists;
 fetch c_chk_wfm_exists into l_dummy_char;
 if c_chk_wfm_exists%notfound
 then
    close c_chk_wfm_exists;

    if X_WF_MAPPING_ID is null then
        open c_get_wfm_id;
        fetch c_get_wfm_id into l_wfm_id;
        close c_get_wfm_id;
    else
       l_wfm_id := X_WF_MAPPING_ID;
    end if ;

    l_obj_verno := 1;

AHL_WF_MAPPING_PKG.INSERT_ROW
(
  X_ROWID  		     => l_row_id,
  X_WF_MAPPING_ID     => l_wfm_id,
  X_OBJECT_VERSION_NUMBER   => l_obj_verno,
  X_LAST_UPDATE_DATE        => SYSDATE,
  X_LAST_UPDATED_BY          => l_user_id,
  X_CREATION_DATE            => SYSDATE,
  X_CREATED_BY 		        =>l_user_id,
  X_LAST_UPDATE_LOGIN       =>0,
  X_ACTIVE_FLAG              => X_ACTIVE_FLAG,
  X_WF_PROCESS_NAME          => X_WF_PROCESS_NAME,
  X_APPROVAL_OBJECT          =>  X_APPROVAL_OBJECT,
  X_ITEM_TYPE                => X_ITEM_TYPE,
  X_APPLICATION_USG_CODE 	=> X_APPLICATION_USG_CODE
);

else
close c_chk_wfm_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;

  AHL_WF_MAPPING_PKG.UPDATE_ROW
  (
  X_WF_MAPPING_ID            => X_WF_MAPPING_ID,
  X_OBJECT_VERSION_NUMBER    => l_obj_verno + 1,
  X_LAST_UPDATE_DATE         => SYSDATE,
  X_LAST_UPDATED_BY          => l_user_id,
  X_LAST_UPDATE_LOGIN        => 0,
  X_ACTIVE_FLAG              => X_ACTIVE_FLAG,
  X_WF_PROCESS_NAME          => X_WF_PROCESS_NAME,
  X_APPROVAL_OBJECT         =>  X_APPROVAL_OBJECT,
  X_ITEM_TYPE     => X_ITEM_TYPE        ,
  X_APPLICATION_USG_CODE 	=> X_APPLICATION_USG_CODE
  );

end if;
end LOAD_ROW;

procedure DELETE_ROW(
  X_WF_MAPPING_ID in NUMBER
)
is
begin
  delete from AHL_WF_MAPPING
  where WF_MAPPING_ID = X_WF_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end AHL_WF_MAPPING_PKG;

/
