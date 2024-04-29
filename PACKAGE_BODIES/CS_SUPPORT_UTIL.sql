--------------------------------------------------------
--  DDL for Package Body CS_SUPPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SUPPORT_UTIL" as
/* $Header: cssuutib.pls 115.6 2001/05/15 15:53:08 pkm ship       $ */

-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
       l_default_date_format     CONSTANT       VARCHAR2(30)   := 'MM/DD/YYYY';
/*

procedure Create_Support_Parties_Link (
	p_support_id	IN 	NUMBER,
	p_party_id 	IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2)

is
	l_support_party_link_id	NUMBER;
	l_number_support_party_link   NUMBER;
	l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_created_by                  NUMBER         :=FND_API.G_MISS_NUM;
        l_login                       NUMBER        :=FND_API.G_MISS_NUM;
	l_object_version	     NUMBER	   :=1.0;
	l_security_group_id	    NUMBER	   :=0;

	Cursor NumberExist (v_support_id Number, v_party_id Number) is
		select count(*) from ibu_oss_support_id_parties where support_id = v_support_id and party_id = v_party_id;
begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body
	--Validation
	if (p_support_id <=0 OR p_party_id <=0) then
	    X_Return_Status := FND_API.G_RET_STS_ERROR;
 	    raise FND_API.G_EXC_ERROR;
	end if;

	--Duplicate Validation
	open NumberExist (p_support_id, p_party_id);
	fetch NumberExist into l_number_support_party_link;
	if (l_number_support_party_link >=1 ) then
	    raise FND_API.G_EXC_ERROR;
	end if;

	l_current_date := sysdate;
        l_created_by := fnd_global.user_id;
        l_login := fnd_global.login_id;

	insert into IBU_OSS_SUPPORT_ID_PARTIES (
	 SUPPORT_ID,
 	PARTY_ID,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATE_LOGIN,
 	SECURITY_GROUP_ID
	) values (
	p_support_id,
	p_party_id,
	l_created_by,
	l_current_date,
	l_created_by,
	l_current_date,
	l_login,
	l_security_group_id);


end Create_Support_Parties_Link;

procedure Delete_Support_Parties_Link (
	p_support_id	IN 	NUMBER,
	p_party_id	IN	NUMBER,
	X_Return_Status	OUT	VARCHAR2
	)

is

begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;
	delete from IBU_OSS_SUPPORT_ID_PARTIES where
		SUPPORT_ID = p_support_id AND
		PARTY_ID = p_party_id;

	if (sql%notfound) then
		X_Return_Status := FND_API.G_RET_STS_ERROR;
		raise no_data_found;
	end if;

end Delete_Support_Parties_Link;
*/
/*
procedure Create_Support_SR_Link (
	p_support_id	IN 	NUMBER,
	p_incident_id 	IN	NUMBER,
	p_product_version IN    VARCHAR2,
	p_platform_version IN   VARCHAR2,
	p_rdbms_version	  IN    VARCHAR2,
	X_Return_Status		OUT	VARCHAR2)
is

	l_support_sr_link_id	NUMBER;
	l_number_support_sr_link      NUMBER;
	l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_created_by                  NUMBER         :=FND_API.G_MISS_NUM;
        l_login                       NUMBER        :=FND_API.G_MISS_NUM;
	l_object_version	     NUMBER	   :=1.0;
	l_security_group_id	    NUMBER	   :=0;
	Cursor NumberExist (v_support_id Number, v_incident_id Number) is
		select count(*) from cs_support_id_srs where support_id = v_support_id and incident_id = v_incident_id;
begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body

	--Validation
	if (p_support_id <=0 OR p_incident_id <=0) then
	    X_Return_Status := FND_API.G_RET_STS_ERROR;
	    raise FND_API.G_EXC_ERROR;
	end if;

	--Duplicate Validation
	open NumberExist (p_support_id, p_incident_id) ;
	fetch NumberExist into l_number_support_sr_link;
	if (l_number_support_sr_link >=1 ) then
	    X_Return_Status := FND_API.G_RET_STS_ERROR;
	    raise FND_API.G_EXC_ERROR;
	end if;

	l_current_date := sysdate;
        l_created_by := fnd_global.user_id;
        l_login := fnd_global.login_id;

	insert into CS_SUPPORT_ID_SRS (
	SUPPORT_ID,
	INCIDENT_ID,
	CREATED_BY,
	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATE_LOGIN,
 	OBJECT_VERSION_NUMBER,
 	SECURITY_GROUP_ID,
	PRODUCT_VERSION,
	PLATFORM_VERSION,
	DBMS_VERSION  ) values (
	p_support_id,
	p_incident_id,
	l_created_by,
	l_current_date,
	l_created_by,
	l_current_date,
	l_login,
	l_object_version,
	l_security_group_id,
	p_product_version,
	p_platform_version,
	p_rdbms_version);



end Create_Support_SR_Link;


procedure Delete_Support_SR_Link (
	p_support_id	IN 	NUMBER,
	p_incident_id	IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2
)

is

begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;
	delete from CS_SUPPORT_ID_SRS where
		SUPPORT_ID = p_support_id AND
		INCIDENT_ID = p_incident_id;

	if (sql%notfound) then
		X_Return_Status := FND_API.G_RET_STS_ERROR;
		raise no_data_found;
	end if;


end Delete_Support_SR_Link;

procedure Create_Support_ID_Level_Link (
	p_support_id	IN 	NUMBER,
	p_level_id 	IN	NUMBER,
	p_start_date		IN	VARCHAR2,
	p_end_date		IN 	VARCHAR2,
	X_support_level_link_id OUT NUMBER,
	X_Return_Status		OUT	VARCHAR2)
is
	l_support_level_link_id		NUMBER;
	l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_created_by                  NUMBER         :=FND_API.G_MISS_NUM;
        l_login                       NUMBER        :=FND_API.G_MISS_NUM;
	l_object_version	     NUMBER	   :=1.0;
	l_security_group_id	    NUMBER	   :=0;
	l_start_date			DATE;
	l_end_date			DATE;
	l_support_id_level_id		NUMBER;


begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body
	--Validation
	if (p_support_id <=0 OR p_level_id <=0) then
	    X_Return_Status := FND_API.G_RET_STS_ERROR;
 	    raise FND_API.G_EXC_ERROR;
	end if;

	l_start_date := TO_DATE(p_start_date, l_default_date_format);
	l_end_date := TO_DATE (p_end_date, l_default_date_format);

	l_current_date := sysdate;
        l_created_by := fnd_global.user_id;
        l_login := fnd_global.login_id;

	select CS_SUPPORT_ID_LVLS_S.NEXTVAL into l_support_id_level_id from dual;

	insert into CS_SUPPORT_ID_LVLS (
	SUP_ID_LVL_ID,
	 SUPPORT_ID,
 	SUPPORT_LVL_ID,
	START_DATE,
	END_DATE,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATE_LOGIN,
 	OBJECT_VERSION_NUMBER,
 	SECURITY_GROUP_ID
	) values (
	l_support_id_level_id,
	p_support_id,
	p_level_id,
	l_start_date,
	l_end_date,
	l_created_by,
	l_current_date,
	l_created_by,
	l_current_date,
	l_login,
	l_object_version,
	l_security_group_id);


	X_support_level_link_id := l_support_id_level_id;
end Create_Support_ID_Level_Link;

procedure Delete_Support_ID_Level_Link (
	p_support_level_link_id	IN    NUMBER,
	X_Return_Status		OUT	VARCHAR2)


is

begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;
	delete from CS_SUPPORT_ID_LVLS where
		sup_id_lvl_id = p_support_level_link_id;

	if (sql%notfound) then
		X_Return_Status := FND_API.G_RET_STS_ERROR;
		raise no_data_found;
	end if;


end Delete_Support_ID_Level_Link;

procedure Create_Support_Level_Item_Link (
	p_support_level_link_id	IN 	NUMBER,
	p_item_id		IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2)
is

	l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_created_by                  NUMBER         :=FND_API.G_MISS_NUM;
        l_login                       NUMBER        :=FND_API.G_MISS_NUM;
	l_object_version	     NUMBER	   :=1.0;
	l_security_group_id	    NUMBER	   :=0;
	l_inv_org_id			NUMBER;
	l_level_item_number		NUMBER;

	Cursor Number_Of_Level_Items (v_support_level_link_id NUMBER, v_inv_item_id NUMBER, v_inv_org_id NUMBER) is
	select count(*) from CS_SUPPORT_ID_LVL_ITEMS where sup_id_lvl_id = v_support_level_link_id and inv_item_id = v_inv_item_id and inv_organization_id = v_inv_org_id;

begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;
	l_inv_org_id := cs_std.get_item_valdn_orgzn_id ();

        -- Start API Body


	--Validation
	if (p_support_level_link_id <=0 OR p_item_id <=0) then
	    X_Return_Status := FND_API.G_RET_STS_ERROR;
 	    raise FND_API.G_EXC_ERROR;
	end if;
	--duplicate validation

	open Number_Of_Level_Items (p_support_level_link_id, p_item_id, l_inv_org_id );
	fetch Number_Of_Level_Items into l_level_item_number;

	if (l_level_item_number >=1) then
	    X_Return_Status := FND_API.G_RET_STS_ERROR;
 	    raise FND_API.G_EXC_ERROR;
	end if;


	l_current_date := sysdate;
        l_created_by := fnd_global.user_id;
        l_login := fnd_global.login_id;


	insert into CS_SUPPORT_ID_LVL_ITEMS  (
	SUP_ID_LVL_ID,
	INV_ITEM_ID ,
 	INV_ORGANIZATION_ID,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATE_LOGIN,
 	OBJECT_VERSION_NUMBER,
 	SECURITY_GROUP_ID
	) values (
	p_support_level_link_id,
	p_item_id,
	l_inv_org_id ,
	l_created_by,
	l_current_date,
	l_created_by,
	l_current_date,
	l_login,
	l_object_version,
	l_security_group_id);


end Create_Support_Level_Item_Link;



procedure Delete_Support_Level_Item_Link  (
	p_support_level_link_id	IN	NUMBER,
	p_item_id		IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2)
is


begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;
	delete from CS_SUPPORT_ID_LVL_ITEMS where
		 sup_id_lvl_id = p_support_leveL_link_id and
		 inv_item_id  = p_item_id and
		 inv_organization_id =  cs_std.get_item_valdn_orgzn_id ();

	if (sql%notfound) then
		X_Return_Status := FND_API.G_RET_STS_ERROR;
		raise no_data_found;
	end if;


end Delete_Support_Level_Item_Link;

procedure Delete_All_Level_Item_Link  (
	p_support_leveL_link_id	IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2)
is


begin
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;
	delete from CS_SUPPORT_ID_LVL_ITEMS where
		 sup_id_lvl_id = p_support_leveL_link_id and
		 inv_organization_id =  cs_std.get_item_valdn_orgzn_id ();



end Delete_All_Level_Item_Link;
*/
/*
   procedure get_current_support_id (
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_user_id                IN   NUMBER,
                     p_commit                 IN   VARCHAR,
                     x_support_id              OUT  NUMBER,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
   as
     l_profile_name    VARCHAR2(60);
     l_perz_data_name  VARCHAR2(360);
     l_perz_data_type  VARCHAR2(30);
     l_application_id  NUMBER;
     l_pd_attrib_tbl   JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;
     l_support_id       NUMBER(15);
     l_party_id        NUMBER(15);
     out_perz_data_id   NUMBER(15);
     out_perz_data_name VARCHAR2(360);
     out_perz_data_type VARCHAR2(30);
     out_perz_data_desc VARCHAR2(240);
   begin
     l_support_id         := -1;
     l_profile_name      := 'IBU_PERZ_' || to_char(p_user_id);
     l_perz_data_name    := 'IBU_PREFERENCES';
     l_perz_data_type    := 'IBU_PREFERENCES';
     l_application_id    := 672;

     JTF_PERZ_DATA_PUB.Get_Perz_Data
     (
          p_api_version_number     =>   1.0,
          p_init_msg_list          =>   p_init_msg_list,
          p_application_id         =>   l_application_id,
          p_profile_id             =>   null,
          p_profile_name           =>   l_profile_name,
          p_perz_data_id      =>   null,
          p_perz_data_name    =>   l_perz_data_name,
          p_perz_data_type    =>   null,
          x_perz_data_id      =>   out_perz_data_id,
          x_perz_data_name    =>   out_perz_data_name,
          x_perz_data_type    =>   out_perz_data_type,
          x_perz_data_desc    =>   out_perz_data_desc,
          x_data_attrib_tbl   =>   l_pd_attrib_tbl,
          x_return_status     =>   x_return_status,
          x_msg_count         =>   x_msg_count,
          x_msg_data          =>   x_msg_data
      );

     if (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        for l_curr_row in 1..l_pd_attrib_tbl.count
          loop
		  if l_pd_attrib_tbl(l_curr_row).ATTRIBUTE_NAME = 'support_id' then
              l_support_id := l_pd_attrib_tbl(l_curr_row).ATTRIBUTE_VALUE;
            end if;
          end loop;
	end if;

     x_support_id := l_support_id;

     exception
	   WHEN NO_DATA_FOUND THEN
		 x_support_id := -1;
		 x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
   end get_current_support_id;

   procedure is_csi_enabled(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
   is
	 l_user_id        NUMBER;
	 l_resp_id        NUMBER;
	 l_app_id         NUMBER;
	 l_enable_flag    VARCHAR2(1);
   begin
	 x_return_status := FND_PROFILE.VALUE ('CS_CSI_ENABLED');

       exception
         when others then
            x_return_status := FND_API.G_RET_STS_ERROR;
   end is_csi_enabled;
*/

end CS_SUPPORT_UTIL;

/
