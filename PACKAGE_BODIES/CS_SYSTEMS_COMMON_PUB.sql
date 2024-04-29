--------------------------------------------------------
--  DDL for Package Body CS_SYSTEMS_COMMON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SYSTEMS_COMMON_PUB" as
 /* $Header: cscommnb.pls 115.7 2001/06/26 18:07:36 pkm ship      $ */
    function get_party_id (p_user_id          IN NUMBER)  return NUMBER
    is
       l_cust_id  NUMBER;
    begin
       SELECT customer_id INTO l_cust_id FROM FND_USER WHERE user_id =
       p_user_id;
       return l_cust_id;
    end get_party_id;

    function get_system_id (p_system_name     IN VARCHAR2)  return NUMBER
    is
       l_system_id  NUMBER(15);
    begin
       SELECT system_id INTO l_system_id FROM CS_SYSTEMS_ALL_VL WHERE name=p_system_name;
       return l_system_id;
    end get_system_id;

   procedure is_system_enabled(
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
	 l_user_id := FND_GLOBAL.USER_ID;
	 l_resp_id := FND_GLOBAL.RESP_ID;
	 l_app_id  := FND_GLOBAL.RESP_APPL_ID;
	 x_return_status := FND_PROFILE.VALUE_SPECIFIC ('CS_CSI_ENABLED', l_user_id, l_resp_id, l_app_id);

       exception
         when others then
            x_return_status := FND_API.G_RET_STS_ERROR;
   end is_system_enabled;

   procedure is_system_valid(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
   is
      l_system_id   NUMBER(15);
      l_result      NUMBER(15);
	 l_curr_date   DATE;
   begin
      l_system_id := -1;
	 l_curr_date := sysdate;

      if (p_system_name is not null) then
         l_system_id := get_system_id (p_system_name);
	    -- dbms_output.put_line ('system_id=' || l_system_id);
         SELECT system_id INTO l_result FROM cs_systems_all_vl WHERE system_id=l_system_id AND (end_date_active IS null OR (end_date_active > l_curr_date));
	    -- dbms_output.put_line ('result=' || l_result);

      elsif (p_system_id > 0 ) then
         SELECT system_id INTO l_result FROM cs_systems_all_vl WHERE system_id=p_system_id AND (end_date_active IS null OR (end_date_active > l_curr_date));

      else
         l_result := -1;
     end if;

	if (l_result < 0) then
        x_return_status := FND_API.G_RET_STS_ERROR;
	else
        x_return_status := FND_API.G_RET_STS_SUCCESS;
     end if;

     exception
        WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
		 -- dbms_output.put_line ('No data found');

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		 -- dbms_output.put_line ('Unexpected error');
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
   end is_system_valid;

   procedure get_current_system (
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_user_id                IN   NUMBER,
                     p_commit                 IN   VARCHAR,
                     x_system_id              OUT  NUMBER,
                     x_system_name            OUT  VARCHAR2,
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
     l_system_id       NUMBER(15);
     l_system_name     VARCHAR2(50);
     l_party_id        NUMBER(15);
     out_perz_data_id   NUMBER(15);
     out_perz_data_name VARCHAR2(360);
     out_perz_data_type VARCHAR2(30);
     out_perz_data_desc VARCHAR2(240);
   begin
     l_system_id         := -1;
     l_system_name       := null;
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
            if l_pd_attrib_tbl(l_curr_row).ATTRIBUTE_NAME = 'system_name' then
              l_system_name := l_pd_attrib_tbl(l_curr_row).ATTRIBUTE_VALUE;
		  elsif l_pd_attrib_tbl(l_curr_row).ATTRIBUTE_NAME = 'system_id' then
              l_system_id := l_pd_attrib_tbl(l_curr_row).ATTRIBUTE_VALUE;
            end if;
          end loop;
	end if;

     x_system_id := l_system_id;
	x_system_name := l_system_name;

     exception
	   WHEN NO_DATA_FOUND THEN
		 x_system_id := -1;
		 x_system_name := null;
		 x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
   end get_current_system;

   procedure get_all_systems_for_user(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_user_id                IN   NUMBER,
                     p_commit                 IN   VARCHAR,
                     x_system_data            OUT  Sys_Info_Cursor,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
  as
    l_party_id   NUMBER(15);
    l_curr_date  DATE;
   begin
      l_party_id := get_party_id (p_user_id);
	 l_curr_date := sysdate;
      open x_system_data for SELECT DISTINCT system_id, name FROM cs_system_party_links_v WHERE party_id = l_party_id AND (end_date_active IS null OR (end_date_active > l_curr_date)) ORDER BY system_id;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
    exception
        WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
   end get_all_systems_for_user;

   procedure get_all_child_systems(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_system_data            OUT  Sys_Info_Cursor,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
   as
      l_system_id   NUMBER(15);
   begin
	 if (p_system_name is not null) then
	    l_system_id  := get_system_id (p_system_name);
         open x_system_data for SELECT distinct system_id, name FROM cs_systems_all_vl WHERE parent_system_id = l_system_id ORDER BY system_id;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

     elsif (p_system_id > 0) then
        open x_system_data for SELECT distinct system_id, name FROM cs_systems_all_vl WHERE parent_system_id = p_system_id ORDER BY system_id;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

     else
         x_return_status := FND_API.G_RET_STS_ERROR;
     end if;
    exception
        WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
   end get_all_child_systems;

   procedure is_user_associated_to_system(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_user_id                IN   NUMBER,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
   as
     l_party_id      NUMBER(15);
     l_system_id     NUMBER(15);
     l_system_count  NUMBER;
     l_curr_date     DATE;
   begin
      l_party_id := get_party_id (p_user_id);
      l_system_id := -1;
	 l_system_count := -1;
      l_curr_date := sysdate;

	 if (p_system_name is not null) then
        l_system_id := get_system_id (p_system_name);
        SELECT count(*) INTO l_system_count FROM cs_system_party_links_v WHERE system_id = l_system_id AND party_id = l_party_id and (end_date is null or end_date < l_curr_date);
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	 elsif (p_system_id > 0) then
        SELECT count(*) INTO l_system_count FROM cs_system_party_links_v WHERE system_id = p_system_id AND party_id = l_party_id and (end_date is null or end_date < l_curr_date);
       x_return_status := FND_API.G_RET_STS_SUCCESS;
	 else
	     x_return_status := FND_API.G_RET_STS_ERROR;
	 end if;
      exception
        WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );

   end is_user_associated_to_system;

   procedure association_exists(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
   as
     l_system_id     NUMBER(15);
     l_system_count  NUMBER;
     l_curr_date     DATE;
   begin
      l_system_id := -1;
	 l_system_count := -1;
      l_curr_date := sysdate;

	 if (p_system_name is not null) then
        l_system_id := get_system_id (p_system_name);
        SELECT count(*) INTO l_system_count FROM cs_system_party_links_v WHERE system_id = l_system_id  and (end_date is null or end_date < l_curr_date);
	   if (l_system_count > 0) then
           x_return_status := FND_API.G_RET_STS_SUCCESS;
	  else
		 x_return_status := FND_API.G_RET_STS_ERROR;
	 end if;

	 elsif (p_system_id > 0) then
        SELECT count(*) INTO l_system_count FROM cs_system_party_links_v WHERE system_id = p_system_id and (end_date is null or end_date < l_curr_date);
	  if (l_system_count > 0) then
          x_return_status := FND_API.G_RET_STS_SUCCESS;
	  else
	     x_return_status := FND_API.G_RET_STS_ERROR;
	 end if;
	 end if;
      exception
        WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
    end association_exists;

   procedure user_exists(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    )
   as
     l_system_id     NUMBER(15);
     l_system_count  NUMBER;
     l_curr_date     DATE;
   begin
      l_system_id := -1;
	 l_system_count := -1;
      l_curr_date := sysdate;

	 if (p_system_name is not null) then
        l_system_id := get_system_id (p_system_name);
        SELECT count(*) INTO l_system_count FROM
	   cs_systems_all_b a, hz_cust_accounts b,
	   hz_parties c, fnd_user d
        WHERE a.system_id=l_system_id AND
        a.customer_id=b.cust_account_id AND
        b.party_id=c.party_id AND
        c.party_type='PERSON' AND
        c.party_id=d.customer_id;

	   if (l_system_count > 0) then
           x_return_status := FND_API.G_RET_STS_SUCCESS;
	  else
		 x_return_status := FND_API.G_RET_STS_ERROR;
	 end if;

	 elsif (p_system_id > 0) then
        SELECT count(*) INTO l_system_count FROM
        cs_systems_all_b a, hz_cust_accounts b,
        hz_parties c, fnd_user d
        WHERE a.system_id=p_system_id AND
        a.customer_id=b.cust_account_id AND
        b.party_id=c.party_id AND
        c.party_type='PERSON' AND
        c.party_id=d.customer_id;

	  if (l_system_count > 0) then
          x_return_status := FND_API.G_RET_STS_SUCCESS;
	  else
	     x_return_status := FND_API.G_RET_STS_ERROR;
	  end if;
	 end if;
      exception
        WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
    end user_exists;

end CS_SYSTEMS_COMMON_PUB;

/
