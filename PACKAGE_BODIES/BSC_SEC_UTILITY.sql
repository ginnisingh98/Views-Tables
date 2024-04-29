--------------------------------------------------------
--  DDL for Package Body BSC_SEC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SEC_UTILITY" AS
/*$Header: BSCSECUB.pls 120.0 2005/06/01 14:30:55 appldev noship $*/
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.7=120.0):~PROD:~PATH:~FILE


 G_PKG_NAME                VARCHAR2(30) := 'BSC_SEC_UTILITY';
 g_current_user_id         NUMBER  :=  FND_GLOBAL.User_id;
 g_current_login_id        NUMBER  :=  FND_GLOBAL.Login_id;

 function get_item_value(p_level_view_name varchar2,p_level_value varchar2) return varchar2 is
  l_itemvalue varchar2(30);
  l_sql varchar2(2000);
  l_dummy varchar2(1);
  cursor c_view_exist is
  select '1'
  from dual
  where exists
  (select '1'
  from user_objects
  where object_name=p_level_view_name
  and object_type='VIEW');

  begin
   open c_view_exist;
   fetch c_view_exist into l_dummy;

   if c_view_exist%notfound then
     return 'No level view';
   else

    l_sql:='SELECT name FROM '||p_level_view_name||' WHERE code = :1';
    EXECUTE IMMEDIATE l_sql INTO l_itemvalue USING p_level_value;

    return l_itemvalue;
   end if;
   close c_view_exist;
  exception
    when no_data_found then
      return p_level_value||'(item value not found)';
    when others then
      raise;
  end;

/**
  the logic for this function is changed per bug 3172873
**/
 function get_lowest_dim_ind(p_tab_id varchar2,p_resp_id varchar2) return number is
  l_dim_ind number;

  cursor c_dim_values is
  select
  DIM_LEVEL_INDEX,
  DIM_LEVEL_VALUE
 from bsc_user_list_access
  where RESPONSIBILITY_ID=p_resp_id
  and TAB_ID=p_tab_id
  order by DIM_LEVEL_INDEX desc;

  l_dim_values_rec c_dim_values%rowtype;

 begin
   l_dim_ind:=null;
  for l_dim_values_rec in c_dim_values loop
     if l_dim_values_rec.DIM_LEVEL_VALUE<>to_char(0) then
       l_dim_ind:=l_dim_values_rec.DIM_LEVEL_INDEX;
       exit;
     end if;
  end loop;
  if l_dim_ind is null then
     l_dim_ind:=0;
  end if;

/**     select
     max(DIM_LEVEL_INDEX)
    into
     l_dim_ind
   from
    bsc_sys_com_dim_levels
   where tab_id=p_tab_id;
**/
   return l_dim_ind;
  exception
   when no_data_found then
       return null;
   when others then
       raise;

 end;

function get_parent_value(p_tab_id number,p_level_index number,p_level_value varchar2) return varchar2
is
cursor c_level_view is
select
b.LEVEL_VIEW_NAME
from
bsc_sys_com_dim_levels a,
bsc_sys_dim_levels_vl b
where
a.tab_id=p_tab_id
and a.DIM_LEVEL_INDEX=p_level_index
and a.DIM_LEVEL_ID=b.dim_level_id;

cursor c_parent_pk is
select
b.LEVEL_PK_COL
from
bsc_sys_com_dim_levels a,
bsc_sys_dim_levels_vl b
where a.tab_id=p_tab_id
and a.dim_level_index=p_level_index
and a.PARENT_DIM_LEVEL_ID=b.dim_level_id;

l_level_view varchar2(30);
l_parent_pk varchar2(30);
l_parent_value varchar2(400);
l_sql varchar2(2000);
begin
  if  p_level_index=0 then
    return p_level_value;
  else
    open c_level_view;
    fetch c_level_view into l_level_view;
    close c_level_view;
    open c_parent_pk;
    fetch c_parent_pk into l_parent_pk ;
    close c_parent_pk;

    l_sql:='SELECT  to_char('||l_parent_pk||') FROM '||l_level_view||' WHERE code= :1';
    EXECUTE IMMEDIATE l_sql INTO l_parent_value USING p_level_value;
    return l_parent_value;
 end if;
 exception
   when others then
     raise;
end;


 procedure Update_tab_access (
  P_ROWID		in ROWID       := null,
 P_RESP_ID		in number,
 P_TAB_ID		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is

l_sysdate               DATE         := sysdate;
l_api_name           CONSTANT VARCHAR2(30)   := 'Update_tab_access';
l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);


cursor tab_indicators is
select
 indicator
from
bsc_tab_indicators
where tab_id=p_tab_id;

l_indicators_rec tab_indicators%rowtype;

begin

  -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    if (P_ROWID is not null) then
      update bsc_user_tab_access
      set responsibility_id       = P_RESP_ID,
          tab_id                  = P_TAB_ID,
          start_date              = P_START_DATE,
          end_date                = P_END_DATE,
          last_updated_by         = l_last_updated_by,
          last_update_login       = l_last_update_login,
          last_update_date        = l_last_update_date
      where rowid  = P_ROWID;
    else
      UPDATE bsc_user_tab_access
      SET
           start_date            = P_START_DATE,
           end_date              = P_END_DATE,
           LAST_UPDATE_DATE      = L_LAST_UPDATE_DATE,
           LAST_UPDATED_BY       = L_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN     = L_LAST_UPDATE_LOGIN
      WHERE responsibility_id    = P_RESP_ID
      AND tab_id                 = P_TAB_ID     ;
    END IF;


   -----if p_end_date is not null, and p_end_date<=sysdate, we need to
   ----- remove the indicators of the tab from bsc_user_kpi_access
   -----if p_end_date is null or p_end_date >sysdate need to reassign indicators to the resp
   if ((p_end_date is not null and p_end_date <=sysdate)
        or (p_start_date is not null and p_start_date >sysdate)) then
     for l_indicators_rec in tab_indicators loop
         remove_kpi_access(
         p_resp_id =>p_resp_id,
         p_indicator =>l_indicators_rec.indicator,
         x_return_status =>  x_return_status    ,
         x_errorcode     => x_errorcode      ,
         x_msg_count    =>  x_msg_count       ,
         x_msg_data     =>  x_msg_data    ) ;
     end loop;
   end if;
   commit;
   if ( p_start_date<=sysdate and (p_end_date is null or nvl(p_end_date,sysdate)>sysdate ))   then
      for l_indicators_rec in tab_indicators loop
       insert_kpi_access (
       P_RESP_ID		=>p_resp_id,
       P_INDICATOR	=>l_indicators_rec.indicator,
       P_START_DATE	=>p_start_date,
       P_END_DATE	    =>p_end_date,
       x_return_status  =>x_return_status,
       x_errorcode     => x_errorcode,
       x_msg_count     =>  x_msg_count,
       x_msg_data     =>  x_msg_data
       ) ;
    end loop;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

end Update_tab_access;


procedure Update_list_access (
 P_ROWID		in ROWID       := null,
 P_RESP_ID		in number,
 P_TAB_ID		in number,
 P_DIM_LEVEL_INDEX      in number,
 P_DIM_LEVEL_VALUE      in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is

l_sysdate               DATE         := sysdate;
l_api_name           CONSTANT VARCHAR2(30)   := 'Update_list_access';
l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);
begin

  -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    if (P_ROWID is not null) then
      update bsc_user_list_access
      set responsibility_id       = P_RESP_ID,
          tab_id                  = P_TAB_ID,
          DIM_LEVEL_INDEX         = P_DIM_LEVEL_INDEX,
          DIM_LEVEL_VALUE         = P_DIM_LEVEL_VALUE,
          last_updated_by         = l_last_updated_by,
          last_update_login       = l_last_update_login,
          last_update_date        = l_last_update_date
      where rowid  = P_ROWID;
    else
      UPDATE bsc_user_list_access
      SET
           DIM_LEVEL_VALUE        = P_DIM_LEVEL_VALUE,
           LAST_UPDATE_DATE      = L_LAST_UPDATE_DATE,
           LAST_UPDATED_BY       = L_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN     = L_LAST_UPDATE_LOGIN
      WHERE responsibility_id    = P_RESP_ID
      AND tab_id                 = P_TAB_ID
      and dim_level_index        = P_DIM_LEVEL_INDEX   ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

end update_list_access;


procedure insert_list_access (
 P_RESP_ID		in number,
 P_TAB_ID		in number,
 P_DIM_LEVEL_INDEX in number,
 P_DIM_LEVEL_VALUE in VARCHAR2,
 P_CREATION_DATE in date :=null,
 p_CREATED_BY in number :=null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is

l_sysdate               DATE         := sysdate;
l_api_name           CONSTANT VARCHAR2(30)   := 'Insert_list_access';
l_creation_date date :=nvl(p_creation_date,l_Sysdate);
l_created_by number :=nvl(p_created_by,g_current_user_id);
l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);
begin

  -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    insert into bsc_user_list_access
    (
     RESPONSIBILITY_ID ,
      TAB_ID            ,
      DIM_LEVEL_INDEX    ,
     DIM_LEVEL_VALUE      ,
     CREATION_DATE      ,
     CREATED_BY         ,
     LAST_UPDATE_DATE   ,
     LAST_UPDATED_BY    ,
     LAST_UPDATE_LOGIN
    )
    values
    (
    P_RESP_ID		 ,
    P_TAB_ID		 ,
     P_DIM_LEVEL_INDEX  ,
    P_DIM_LEVEL_VALUE  ,
    l_creation_date,
     l_created_by,
    l_last_update_date,
     l_last_updated_by,
    l_last_update_login
    );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

end insert_list_access;



function has_access_level(p_tab_id in varchar2) return varchar2 is
 cursor c_exist is
 select 'Y'
 from dual
 where exists (select TAB_ID from bsc_sys_com_dim_levels where tab_id=p_tab_id);
 l_dummy varchar2(1);
begin
  l_dummy:=null;
  open c_exist;
  fetch c_exist into l_dummy;
  if c_exist%notfound then
     l_dummy:='N';
  end if;
  close c_exist;
  return l_dummy;
 exception
   when others then
    raise;
end;

function exist_user_list_access(p_resp_id in number,p_tab_id in number) return varchar2 is
cursor exist_user_list_access is
select 'Y'
from dual
where exists
(select 'Y' from bsc_user_list_access
 where RESPONSIBILITY_ID=p_resp_id
 and TAB_ID=p_tab_id);
l_dummy varchar2(1);
begin
 l_dummy:=null;
 open exist_user_list_access;
 fetch exist_user_list_access into l_dummy;
 if exist_user_list_access%notfound then
   l_dummy:='N';
 end if;
 close exist_user_list_access;
 return l_dummy;
exception
  when others then
    raise;
end;




-----This api will be called when the user check the check box at UI
-----We need to grant the access to this scorecard
--- Before insert, we need to check if this scorecard had been granted before
----if so, we just need to reset the end date to null
procedure insert_tab_access (
 P_RESP_ID		in number,
 P_TAB_ID		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is

  l_sysdate               DATE         := sysdate;
  l_api_name           CONSTANT VARCHAR2(30)   := 'insert_tab_access';
  l_created_by         NUMBER := nvl(P_CREATED_BY,g_current_user_id);
  l_creation_date      DATE   := nvl(P_CREATION_DATE, l_Sysdate);
  l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
  l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
  l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);

cursor row_exists is
select 'Y'
 from dual
 where exists
 (select 'Y'
 from bsc_user_tab_access
  where responsibility_id=p_resp_id
  and tab_id=p_tab_id);

l_dummy varchar2(1);

cursor tab_indicators is
select
 indicator
from
bsc_tab_indicators
where tab_id=p_tab_id;

l_indicators_rec tab_indicators%rowtype;

cursor comm_dim_value is
select distinct
 DIM_LEVEL_INDEX DIM_LEVEL_INDEX,
 '0' DIM_LEVEL_VALUE ---default value 'ALL'
from
bsc_sys_com_dim_levels
where tab_id=p_tab_id;

l_comm_dim_value_rec comm_dim_value%rowtype;


begin
l_dummy:=null;
-- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

open row_exists;
fetch row_exists into l_dummy;
if row_exists%notfound then
   l_dummy:='N';
end if;
close row_exists;

if   l_dummy='Y' then
   ---update the end_date to null
   ----the start date (sysdate) and end_date (null) values will be set at middle tier
  Update_tab_access (
 P_RESP_ID		=>p_resp_id,
 P_TAB_ID		=>p_tab_id,
 P_START_DATE	=>p_start_date,
 P_END_DATE	    =>p_end_date,
 x_return_status =>x_return_status,
 x_errorcode     =>x_errorcode,
 x_msg_count     =>x_msg_count,
 x_msg_data      =>x_msg_data
) ;

else
   ---insert a new row
       insert into bsc_user_tab_access (
        responsibility_id,
        tab_id,
        start_date,
        end_date,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
    values(
        P_resp_id,
        P_tab_id,
        P_start_date,
        P_end_date,
        L_CREATED_BY,
        L_CREATION_DATE,
        L_LAST_UPDATED_BY,
        L_LAST_UPDATE_LOGIN,
        L_LAST_UPDATE_DATE);

 ----Need to assign all indicators in this tab to the responsibility
---
for l_indicators_rec in tab_indicators loop
 insert_kpi_access (
 P_RESP_ID		=>p_resp_id,
 P_INDICATOR	=>l_indicators_rec.indicator,
 P_START_DATE	=>p_start_date,
 P_END_DATE	    =>p_end_date,
 x_return_status  =>x_return_status,
 x_errorcode     => x_errorcode,
 x_msg_count     =>  x_msg_count,
 x_msg_data     =>  x_msg_data
) ;
end loop;

end if;

-----insert into bsc_user_List_access
if has_access_level(p_tab_id) ='Y' then
  if exist_user_list_access(p_resp_id,p_tab_id)='N' then
    for l_comm_dim_value_rec in comm_dim_value loop
        insert_list_access (
        P_RESP_ID=>p_resp_id,
        P_TAB_ID=>p_tab_id	,
        P_DIM_LEVEL_INDEX=>l_comm_dim_value_rec.DIM_LEVEL_INDEX,
        P_DIM_LEVEL_VALUE=>l_comm_dim_value_rec.DIM_LEVEL_value,
        x_return_status  => x_return_status     ,
        x_errorcode =>    x_errorcode     ,
        x_msg_count =>   x_msg_count         ,
        x_msg_data  =>    x_msg_data     );
    end loop;
  end if;

end if;


    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;


end insert_tab_access;


procedure insert_kpi_access (
 P_RESP_ID		in number,
 P_INDICATOR		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is

  l_sysdate               DATE         := sysdate;
  l_api_name           CONSTANT VARCHAR2(30)   := 'insert_kpi_access';
  l_created_by         NUMBER := nvl(P_CREATED_BY,g_current_user_id);
  l_creation_date      DATE   := nvl(P_CREATION_DATE, l_Sysdate);
  l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
  l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
  l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);

cursor row_exists is
select 'Y'
 from dual
 where exists
 (select 'Y'
 from bsc_user_kpi_access
  where responsibility_id=p_resp_id
 and  indicator=p_indicator);

l_dummy varchar2(1);

begin
l_dummy:=null;
-- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

open row_exists;
fetch row_exists into l_dummy;
if row_exists%notfound then
   l_dummy:='N';
end if;
close row_exists;

if   l_dummy='Y' then
   ----update dates for the existing row
  Update_kpi_access (
 P_RESP_ID		=>p_resp_id,
 P_INDICATOR		=>p_indicator,
 P_START_DATE	=>p_start_date,
 P_END_DATE	    =>p_end_date,
 x_return_status =>x_return_status,
 x_errorcode     =>x_errorcode,
 x_msg_count     =>x_msg_count,
 x_msg_data      =>x_msg_data
) ;

else
   ---insert a new row
       insert into bsc_user_kpi_access (
        responsibility_id,
        indicator,
        start_date,
        end_date,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
    values(
        P_resp_id,
        P_indicator,
        P_start_date,
        P_end_date,
        L_CREATED_BY,
        L_CREATION_DATE,
        L_LAST_UPDATED_BY,
        L_LAST_UPDATE_LOGIN,
        L_LAST_UPDATE_DATE);
end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

end insert_kpi_access;



procedure Update_kpi_access (
  P_ROWID		in ROWID       := null,
 P_RESP_ID		in number,
 P_INDICATOR		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is

l_sysdate               DATE         := sysdate;
l_api_name           CONSTANT VARCHAR2(30)   := 'Update_kpi_access';
l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);
begin

  -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    if (P_ROWID is not null) then
      update bsc_user_kpi_access
      set responsibility_id       = P_RESP_ID,
          indicator               = P_INDICATOR,
          start_date              = P_START_DATE,
          end_date                = P_END_DATE,
          last_updated_by         = l_last_updated_by,
          last_update_login       = l_last_update_login,
          last_update_date        = l_last_update_date
      where rowid  = P_ROWID;
    else
      UPDATE bsc_user_kpi_access
      SET
           start_date            = P_START_DATE,
           end_date              = P_END_DATE,
           LAST_UPDATE_DATE      = L_LAST_UPDATE_DATE,
           LAST_UPDATED_BY       = L_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN     = L_LAST_UPDATE_LOGIN
      WHERE responsibility_id    = P_RESP_ID
      AND  indicator                 = P_INDICATOR    ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

end Update_kpi_access;


procedure remove_kpi_access(
p_resp_id in number,
p_indicator in number,
p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
x_return_status        OUT NOCOPY  VARCHAR2,
x_errorcode            OUT NOCOPY  NUMBER,
x_msg_count            OUT NOCOPY  NUMBER,
x_msg_data             OUT NOCOPY  VARCHAR2
) is
l_api_name           CONSTANT VARCHAR2(30)   := 'remove_kpi_access';
begin
  -- Initialize API message list if necessary.
  -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

  delete from  bsc_user_kpi_access
  where responsibility_id=p_resp_id
  and indicator=p_indicator;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

 end remove_kpi_access;


END bsc_sec_utility;

/
