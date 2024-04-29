--------------------------------------------------------
--  DDL for Package Body PA_PLAN_RES_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_RES_DEFAULTS_PVT" as
/* $Header: PARPRDVB.pls 120.1 2005/08/16 23:35:04 avaithia noship $ */
procedure INSERT_ROW (
  X_ROWID                           in OUT NOCOPY ROWID,
  X_PLAN_RES_DEFAULT_ID             in OUT NOCOPY NUMBER   ,
  P_RESOURCE_CLASS_ID               in NUMBER   ,
  P_OBJECT_TYPE                     in VARCHAR2 ,
  P_OBJECT_ID                       in NUMBER   ,
  P_SPREAD_CURVE_ID                 in NUMBER   ,
  P_ETC_METHOD_CODE                 in VARCHAR2 ,
  P_EXPENDITURE_TYPE                in VARCHAR2 ,
  P_ITEM_CATEGORY_SET_ID            in NUMBER   ,
  P_ITEM_MASTER_ID                  in NUMBER   ,
  P_MFC_COST_TYPE_ID                in NUMBER   ,
  P_ENABLED_FLAG                    in VARCHAR2 ,
  X_RECORD_VERSION_NUMBER           in OUT NOCOPY NUMBER   ,
  P_CREATION_DATE                   in DATE     ,
  P_CREATED_BY                      in NUMBER   ,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER
) is

  l_plan_res_default_id PA_PLAN_RES_DEFAULTS.PLAN_RES_DEFAULT_ID%type;


  cursor C is select ROWID from PA_PLAN_RES_DEFAULTS
    where plan_res_default_id = l_plan_res_default_id;
begin

  select nvl(X_PLAN_RES_DEFAULT_ID,PA_PLAN_RES_DEFAULTS_S.nextval)
  into   l_plan_res_default_id
  from   dual;

  insert into PA_PLAN_RES_DEFAULTS (
    PLAN_RES_DEFAULT_ID           ,
    RESOURCE_CLASS_ID             ,
    OBJECT_TYPE                   ,
    OBJECT_ID                     ,
    SPREAD_CURVE_ID               ,
    ETC_METHOD_CODE               ,
    EXPENDITURE_TYPE              ,
    ITEM_CATEGORY_SET_ID          ,
    ITEM_MASTER_ID                ,
    MFC_COST_TYPE_ID              ,
    ENABLED_FLAG                  ,
    RECORD_VERSION_NUMBER         ,
    CREATION_DATE                 ,
    CREATED_BY                    ,
    LAST_UPDATE_DATE              ,
    LAST_UPDATED_BY               ,
    LAST_UPDATE_LOGIN
  ) values (
    L_PLAN_RES_DEFAULT_ID         ,
    P_RESOURCE_CLASS_ID           ,
    P_OBJECT_TYPE                 ,
    P_OBJECT_ID                   ,
    P_SPREAD_CURVE_ID             ,
    P_ETC_METHOD_CODE             ,
    P_EXPENDITURE_TYPE            ,
    P_ITEM_CATEGORY_SET_ID        ,
    P_ITEM_MASTER_ID              ,
    P_MFC_COST_TYPE_ID            ,
    P_ENABLED_FLAG                ,
    1                             ,
    P_CREATION_DATE               ,
    P_CREATED_BY                  ,
    P_LAST_UPDATE_DATE            ,
    P_LAST_UPDATED_BY             ,
    P_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

X_RECORD_VERSION_NUMBER := 1;
X_PLAN_RES_DEFAULT_ID := L_PLAN_RES_DEFAULT_ID;

-- 4537865
EXCEPTION

WHEN OTHERS THEN
	X_ROWID := NULL ;
	X_PLAN_RES_DEFAULT_ID := NULL ;
	X_RECORD_VERSION_NUMBER := NULL ;
	RAISE ;
end INSERT_ROW;

procedure LOCK_ROW (
  P_PLAN_RES_DEFAULT_ID             in NUMBER,
  P_RECORD_VERSION_NUMBER           in NUMBER
 ) is
  cursor c is select
      RESOURCE_CLASS_ID               ,
      OBJECT_TYPE                     ,
      OBJECT_ID                       ,
      SPREAD_CURVE_ID                 ,
      ETC_METHOD_CODE                 ,
      EXPENDITURE_TYPE                ,
      ITEM_CATEGORY_SET_ID            ,
      ITEM_MASTER_ID                  ,
      MFC_COST_TYPE_ID                ,
      ENABLED_FLAG                    ,
      RECORD_VERSION_NUMBER
    from PA_PLAN_RES_DEFAULTS
    where PLAN_RES_DEFAULT_ID = P_PLAN_RES_DEFAULT_ID
    for update of PLAN_RES_DEFAULT_ID nowait;
  recinfo c%rowtype;
begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if recinfo.RECORD_VERSION_NUMBER = P_RECORD_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;

end LOCK_ROW;

procedure UPDATE_ROW (
  P_PLAN_RES_DEFAULT_ID             in NUMBER   ,
  P_RESOURCE_CLASS_ID               in NUMBER   ,
  P_OBJECT_TYPE                     in VARCHAR2 ,
  P_OBJECT_ID                       in NUMBER   ,
  P_SPREAD_CURVE_ID                 in NUMBER   ,
  P_ETC_METHOD_CODE                 in VARCHAR2 ,
  P_EXPENDITURE_TYPE                in VARCHAR2 ,
  P_ITEM_CATEGORY_SET_ID            in NUMBER   ,
  P_ITEM_MASTER_ID                  in NUMBER   ,
  P_MFC_COST_TYPE_ID                in NUMBER   ,
  P_ENABLED_FLAG                    in VARCHAR2 ,
  X_RECORD_VERSION_NUMBER           in OUT NOCOPY NUMBER   ,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER   ,
  X_RETURN_STATUS                   OUT NOCOPY VARCHAR2, -- 4537865
  X_MSG_DATA			    OUT NOCOPY VARCHAR2, -- 4537865
  X_MSG_COUNT			    OUT NOCOPY VARCHAR2  -- 4537865
) is
begin
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 x_msg_count := 0;


  update PA_PLAN_RES_DEFAULTS set
    RESOURCE_CLASS_ID       = P_RESOURCE_CLASS_ID,
    OBJECT_TYPE             = P_OBJECT_TYPE,
    OBJECT_ID               = P_OBJECT_ID,
    SPREAD_CURVE_ID         = P_SPREAD_CURVE_ID,
    ETC_METHOD_CODE         = P_ETC_METHOD_CODE,
    EXPENDITURE_TYPE        = P_EXPENDITURE_TYPE,
    ITEM_CATEGORY_SET_ID    = P_ITEM_CATEGORY_SET_ID,
    ITEM_MASTER_ID          = P_ITEM_MASTER_ID,
    MFC_COST_TYPE_ID        = P_MFC_COST_TYPE_ID,
    ENABLED_FLAG            = P_ENABLED_FLAG,
    RECORD_VERSION_NUMBER   = nvl(RECORD_VERSION_NUMBER, 0) + 1,
    LAST_UPDATE_DATE        = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY         = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN       = P_LAST_UPDATE_LOGIN
  where PLAN_RES_DEFAULT_ID = P_PLAN_RES_DEFAULT_ID
    and nvl(RECORD_VERSION_NUMBER, 0) = nvl(X_RECORD_VERSION_NUMBER, RECORD_VERSION_NUMBER);

    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_RECORD_CHANGED_RESET'); --Bug 3771885
       x_msg_count := x_msg_count + 1;
       x_msg_data  := 'PA_RECORD_CHANGED_RESET'; --Bug 3771885
       x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

X_RECORD_VERSION_NUMBER := X_RECORD_VERSION_NUMBER +1;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'pa_plan_res_defaults_pvt.Update_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_msg_count := x_msg_count + 1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;

end UPDATE_ROW;

procedure DELETE_ROW (
  P_PLAN_RES_DEFAULT_ID in NUMBER
) is
begin

  delete from PA_PLAN_RES_DEFAULTS
  where PLAN_RES_DEFAULT_ID = P_PLAN_RES_DEFAULT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW(
  X_PLAN_RES_DEFAULT_ID             in OUT NOCOPY NUMBER   ,
  P_RESOURCE_CLASS_ID               in NUMBER   ,
  P_OBJECT_TYPE                     in VARCHAR2 ,
  P_OBJECT_ID                       in NUMBER   ,
  P_SPREAD_CURVE_ID                 in NUMBER   ,
  P_ETC_METHOD_CODE                 in VARCHAR2 ,
  P_EXPENDITURE_TYPE                in VARCHAR2 ,
  P_ITEM_CATEGORY_SET_ID            in NUMBER   ,
  P_ITEM_MASTER_ID                  in NUMBER   ,
  P_MFC_COST_TYPE_ID                in NUMBER   ,
  P_ENABLED_FLAG                    in VARCHAR2 ,
  X_RECORD_VERSION_NUMBER           in OUT NOCOPY NUMBER   ,
  P_OWNER                           in VARCHAR2
) is

  user_id NUMBER;
  l_rowid VARCHAR2(64);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_return_status VARCHAR2(30);
  l_dummy VARCHAR2(30);

begin
--hr_utility.trace_on(null,'RMUPLOAD');
--hr_utility.trace('start');

  if (P_OWNER = 'SEED')then
   user_id := 1;
  else
   user_id := 0;
  end if;

--hr_utility.trace('before UPDATE_ROW');
--hr_utility.trace('X_PLAN_RES_DEFAULT_ID ' || X_PLAN_RES_DEFAULT_ID);
--hr_utility.trace('P_RESOURCE_CLASS_ID ' || P_RESOURCE_CLASS_ID);
--hr_utility.trace('P_OBJECT_TYPE ' || P_OBJECT_TYPE);
--hr_utility.trace('P_OBJECT_ID ' || P_OBJECT_ID);
--hr_utility.trace('P_SPREAD_CURVE_ID ' || P_SPREAD_CURVE_ID);
--hr_utility.trace('P_ETC_METHOD_CODE ' || P_ETC_METHOD_CODE);
--hr_utility.trace('P_EXPENDITURE_TYPE ' || P_EXPENDITURE_TYPE);
--hr_utility.trace('P_ENABLED_FLAG ' || P_ENABLED_FLAG);
--hr_utility.trace('X_RECORD_VERSION_NUMBER ' || X_RECORD_VERSION_NUMBER);
--hr_utility.trace('P_MFC_COST_TYPE_ID ' || P_MFC_COST_TYPE_ID);
/*
  pa_plan_res_defaults_pvt.UPDATE_ROW (
    P_PLAN_RES_DEFAULT_ID       => X_PLAN_RES_DEFAULT_ID      ,
    P_RESOURCE_CLASS_ID         => P_RESOURCE_CLASS_ID        ,
    P_OBJECT_TYPE               => P_OBJECT_TYPE              ,
    P_OBJECT_ID                 => P_OBJECT_ID                ,
    P_SPREAD_CURVE_ID           => P_SPREAD_CURVE_ID          ,
    P_ETC_METHOD_CODE           => P_ETC_METHOD_CODE          ,
    P_EXPENDITURE_TYPE          => P_EXPENDITURE_TYPE         ,
    P_ITEM_CATEGORY_SET_ID      => P_ITEM_CATEGORY_SET_ID     ,
    P_ITEM_MASTER_ID            => P_ITEM_MASTER_ID           ,
    P_MFC_COST_TYPE_ID          => P_MFC_COST_TYPE_ID         ,
    P_ENABLED_FLAG              => P_ENABLED_FLAG             ,
    X_RECORD_VERSION_NUMBER     => X_RECORD_VERSION_NUMBER    ,
    P_LAST_UPDATE_DATE          => sysdate                    ,
    P_LAST_UPDATED_BY           => user_id                    ,
    P_LAST_UPDATE_LOGIN         => 0                          ,
    x_return_status             => l_return_status            ,
    x_msg_count                 => l_msg_count                ,
    x_msg_data                  => l_msg_data);

*/
-- Don't do anything if row exists - don't want to override customer
-- changes.
--hr_utility.trace('before AfterPDATE_ROW');
--hr_utility.trace('l_return_status is : ' || l_return_status);
--hr_utility.trace('sqlerrm is : ' || sqlerrm);
--hr_utility.trace('l_msg_data is : ' || l_msg_data);

BEGIN
select 'Y'
into l_dummy
from pa_plan_res_defaults
where PLAN_RES_DEFAULT_ID = X_PLAN_RES_DEFAULT_ID;

--hr_utility.trace('l_dummy is : ' || l_dummy);
EXCEPTION WHEN NO_DATA_FOUND THEN
--hr_utility.trace('before INSERT_ROW');
        pa_plan_res_defaults_pvt.INSERT_ROW (
    X_ROWID                     =>  l_rowid                   ,
    X_PLAN_RES_DEFAULT_ID       => X_PLAN_RES_DEFAULT_ID      ,
    P_RESOURCE_CLASS_ID         => P_RESOURCE_CLASS_ID        ,
    P_OBJECT_TYPE               => P_OBJECT_TYPE              ,
    P_OBJECT_ID                 => P_OBJECT_ID                ,
    P_SPREAD_CURVE_ID           => P_SPREAD_CURVE_ID          ,
    P_ETC_METHOD_CODE           => P_ETC_METHOD_CODE          ,
    P_EXPENDITURE_TYPE          => P_EXPENDITURE_TYPE         ,
    P_ITEM_CATEGORY_SET_ID      => P_ITEM_CATEGORY_SET_ID     ,
    P_ITEM_MASTER_ID            => P_ITEM_MASTER_ID           ,
    P_MFC_COST_TYPE_ID          => P_MFC_COST_TYPE_ID         ,
    P_ENABLED_FLAG              => P_ENABLED_FLAG             ,
    X_RECORD_VERSION_NUMBER     => X_RECORD_VERSION_NUMBER    ,
    P_CREATION_DATE             =>  sysdate                   ,
    P_CREATED_BY                =>  user_id                   ,
    P_LAST_UPDATE_DATE          =>  sysdate                   ,
    P_LAST_UPDATED_BY           =>  user_id                   ,
    P_LAST_UPDATE_LOGIN         =>  0                         );
END;
-- 4537865
EXCEPTION
	WHEN OTHERS THEN
		X_PLAN_RES_DEFAULT_ID := NULL ;
		X_RECORD_VERSION_NUMBER := NULL ;
      		FND_MSG_PUB.add_exc_msg( p_pkg_name  => 'pa_plan_res_defaults_pvt'
                                        ,p_procedure_name      => 'Load_Row') ;
		RAISE ;
end LOAD_ROW;

end pa_plan_res_defaults_pvt;

/
