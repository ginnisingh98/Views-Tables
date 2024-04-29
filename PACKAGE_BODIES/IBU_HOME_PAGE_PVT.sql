--------------------------------------------------------
--  DDL for Package Body IBU_HOME_PAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_HOME_PAGE_PVT" 
/* $Header: ibuhvhpb.pls 120.0 2005/10/06 09:43:08 ktma noship $ */
	as
      G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBU_HOME_PAGE_PVT';
      G_USER_PROFILE_NAME CONSTANT VARCHAR2(30) := 'IBU_PERZ_';
      G_BIN_DATA_NAME CONSTANT VARCHAR2(30) := 'IBU_BIN';

	 G_FILTER_DATA_NAME CONSTANT VARCHAR2(30) := 'IBU_BIN_FILTER_';
	 G_FILTER_DATA_TYPE CONSTANT VARCHAR2(30) := 'IBU_FILTER';
	 G_PREF_DATA_NAME CONSTANT VARCHAR2(30) := 'IBU_PREFERENCES';
	 G_PREF_DATA_TYPE CONSTANT VARCHAR2(30) := 'IBU_PREFERENCES';
	 G_PREF_ACCOUNT_ATTR_NAME CONSTANT VARCHAR2(30) := 'account_id';
	 G_PREF_DATE_ATTR_NAME CONSTANT VARCHAR2(30) := 'date_format';

	 G_BIN_PACKAGE_ATTR_NAME CONSTANT VARCHAR2(30) := 'plsql_package';
	 G_BIN_MANDATORY_ATTR_NAME CONSTANT VARCHAR2(30) := 'bin_mandatory_flag';
	 G_BIN_DISABLED_ATTR_NAME CONSTANT VARCHAR2(30) := 'bin_disabled_flag';
	 G_BIN_MES_ID_ATTR_NAME CONSTANT VARCHAR2(30) := 'MES_cat_ID';
	 G_BIN_ROW_NUMBER_ATTR_NAME CONSTANT VARCHAR2(30) := 'row_number';

      G_HOME_REGION_CODE CONSTANT VARCHAR2(30) := 'IBU_HOM_CATEGORY';

      -- Changes for Contracts
      function is_rollout_enabled return VARCHAR
        as
            l_user_id        NUMBER;
            l_resp_id        NUMBER;
            l_app_id         NUMBER;
            l_return_value   VARCHAR(10);
            x_return_status  VARCHAR2(1);
         begin
            l_user_id       := FND_GLOBAL.USER_ID;
            l_resp_id       := FND_GLOBAL.RESP_ID;
            l_app_id        := FND_GLOBAL.RESP_APPL_ID;
            l_return_value := FND_PROFILE.VALUE_SPECIFIC ('IBU_INTERNAL_ROLLOUT', l_user_id, l_resp_id, l_app_id);
            if l_return_value = 'Y' then
               x_return_status := FND_API.G_TRUE;
            else
               x_return_status := FND_API.G_FALSE;
            end if;
            return x_return_status;
      end;

      function is_country_contract_enabled return VARCHAR
      as
             type Info_Cursor IS REF CURSOR;
             l_info_cursor Info_Cursor;
             l_count NUMBER;
             l_cust_id NUMBER;
		   stmt VARCHAR(200);
             x_return_status  VARCHAR2(1) := FND_API.G_FALSE;
          begin
		   l_cust_id := get_customer_id();
             if (l_cust_id > 0) then
                stmt := 'select count(*) ';
                stmt := stmt || ' from ibu_party_contracts ' ;
                stmt := stmt || ' where party_id= :custid ';
                OPEN l_info_cursor for stmt using l_cust_id;
                LOOP
                    FETCH l_info_cursor into l_count;
                    EXIT WHEN l_info_cursor%NOTFOUND;
                END LOOP;
                CLOSE l_info_cursor;

                if l_count > 0 then
                   x_return_status := FND_API.G_TRUE;
                else
                   x_return_status := FND_API.G_FALSE;
			 end if;
	       end if;
            return x_return_status;
      end;


      -- common context info
      function get_user_id return NUMBER
      as
      begin
        return FND_GLOBAL.USER_ID;
      end get_user_id;

      function get_user_name return VARCHAR2
      as
      begin
        return FND_GLOBAL.USER_NAME;
      end get_user_name;

      function get_app_id return NUMBER
      as
      begin
        return 672;
      end get_app_id;

      function get_resp_id return NUMBER
      as
      begin
        -- get the default resp id for this user
        -- seems fnd_global may not return the right responsibility
	   return get_resp_id_from_user(get_user_id);
      end get_resp_id;

      function get_customer_id return NUMBER
      as
      begin
        return get_customer_id_from_user(get_user_id);
      end;

      function get_employee_id return NUMBER
      as
      begin
        return get_employee_id_from_user(get_user_id);
      end;

      function get_company_id return NUMBER
      as
      begin
        return get_company_id_from_user(get_user_id);
      end;

      function get_company_name return VARCHAR2
      as
      begin
        return get_company_name_from_user(get_user_id);
      end;

      function get_account_id return NUMBER
      as
      begin
        return get_account_id_from_user(get_user_id);
      end get_account_id;

      function get_lang_code return VARCHAR2
      as
      begin
        return userenv('LANG');
      end get_lang_code;

      function get_date_format return VARCHAR2
      as
      begin
          return get_date_format_from_user(get_user_id);
      end get_date_format;

      function get_resp_id_from_user(p_user_id IN NUMBER) return NUMBER
      as
      begin
        -- get the default resp id for this user
        -- seems fnd_global may not return the right responsibility
        return FND_PROFILE.VALUE_SPECIFIC(
                  'JTF_PROFILE_DEFAULT_RESPONSIBILITY',
                  p_user_id,
                  null,
                  null);
      end get_resp_id_from_user;

      function get_customer_id_from_user(p_user_id IN NUMBER) return NUMBER
      as
        l_customer_id NUMBER;
      begin
        SELECT customer_id
        INTO l_customer_id
        FROM fnd_user
        WHERE user_id = p_user_id;

        return l_customer_id;
      exception
        when others then
          return null;
      end get_customer_id_from_user;

    function get_employee_id_from_user(p_user_id IN NUMBER) return NUMBER
    as
        l_employee_id NUMBER;
    begin
        SELECT employee_id
        INTO l_employee_id
        FROM fnd_user
        WHERE user_id = p_user_id;

        return l_employee_id;
    exception
        when others then
            return null;
    end get_employee_id_from_user;

    function get_party_type_from_user(p_user_id IN NUMBER,
	x_party_id OUT NOCOPY NUMBER) return VARCHAR2
    as
        l_party_type VARCHAR2(30);
    begin
        SELECT p.party_type, party_id
        INTO l_party_type, x_party_id
        FROM hz_parties p, fnd_user u
        WHERE u.user_id = p_user_id
        AND p.party_id = u.customer_id;
        return l_party_type;
        exception
            when NO_DATA_FOUND then
                return null;
	        when others then
	           raise FND_API.G_EXC_ERROR;
    end get_party_type_from_user;

    function get_company_id_from_user(p_user_id IN NUMBER) return NUMBER
    as
        l_company_id NUMBER;
        l_party_type VARCHAR2(30) := null;
        l_party_id NUMBER := null;
    begin
        l_party_type := get_party_type_from_user(p_user_id, l_party_id);
        if (l_party_type = NULL OR l_party_id = NULL) then
            return null;
        end if;
        if (l_party_type = 'PARTY_RELATIONSHIP') then
            SELECT object_id
            INTO l_company_id
            FROM hz_relationships
            WHERE party_id = l_party_id
        	AND relationship_code in ('EMPLOYEE_OF', 'CONTACT_OF')
            AND content_source_type = 'USER_ENTERED'
            AND status = 'A';
        elsif (l_party_type = 'PERSON') then
            SELECT p.object_id
            INTO l_company_id
            FROM hz_relationships p
            WHERE p.subject_id = l_party_id
        	AND p.relationship_code in ('EMPLOYEE_OF', 'CONTACT_OF')
            AND content_source_type = 'USER_ENTERED'
            AND status = 'A';
        else
            return null;
        end if;

        return l_company_id;
    exception
        when NO_DATA_FOUND then
            return null;
        when others then
            raise FND_API.G_EXC_ERROR;
    end get_company_id_from_user;

    function get_company_name_from_user(p_user_id IN NUMBER) return VARCHAR2
    as
        l_company_id NUMBER;
        l_company_name VARCHAR2(360);
    begin
        l_company_id := get_company_id_from_user(p_user_id);
        SELECT party_name
        INTO l_company_name
        FROM hz_parties
        WHERE party_id = l_company_id;

        return l_company_name;
        exception
            when others then
                return null;
    end get_company_name_from_user;

      function get_account_id_from_user(p_user_id IN NUMBER) return NUMBER
      as
        l_return_status VARCHAR2(240);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(2000);
        l_attrib_val  VARCHAR2(300);
        l_pd_attrib_tbl JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;

        l_acct_id NUMBER := 0;
        l_acct_list Account_List_Type;
      begin

        -- Get the account id from perz data framework (should validate?)
        -- BUGBUG : if none found, need to randomly pick one from valid acct
        --          list. Also it will be good to verify acct valid.
        get_perz_data_attrib(p_api_version_number => 1.0,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_user_id   => p_user_id,
          p_pd_id     => null,
          p_pd_name   => G_PREF_DATA_NAME,
          p_pd_type   => null,
          p_pd_attrib_name => G_PREF_ACCOUNT_ATTR_NAME,
          x_pd_attrib_value => l_attrib_val,
          x_pd_attrib_tbl => l_pd_attrib_tbl
        );

        if NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) OR l_attrib_val is null THEN
          -- default accout does not exist
          l_acct_list := get_accounts_from_user(p_user_id);
          if l_acct_list is not null and l_acct_list.count() >0 then
             l_acct_id := l_acct_list(1).account_id;
          end if;
          return l_acct_id;
        else
          return to_number(l_attrib_val);
        end if;

      exception
        when others then
          return null;
      end get_account_id_from_user;

    function get_accounts_from_user(p_user_id IN NUMBER)
        return Account_List_Type
    as
        l_acct_list Account_List_Type;
        l_acct Account_Data_Type;
        l_customer_id NUMBER := NULL;
        l_company_id NUMBER := NULL;
        l_cind NUMBER := 1;

        CURSOR acct_info_b2c(p_customer_id IN NUMBER) IS
        select cust_account_id, account_number
        from HZ_CUST_ACCOUNTS
        where status = 'A'
        and cust_account_id in
        (select cust_account_id
         from HZ_CUST_ACCOUNT_ROLES
         where party_id = p_customer_id
         and current_role_state = 'A')
        order by account_number;

/*
        select r.cust_account_id, r.account_number
        from hz_cust_accounts r, hz_cust_account_roles s
        where r.cust_account_id = s.cust_account_id
        and s.current_role_state = 'A'
        and s.party_id = p_customer_id
        order by r.account_number;
*/

        CURSOR acct_info_b2b(p_customer_id IN NUMBER, p_company_id IN NUMBER) IS
        select cust_account_id, account_number
        from HZ_CUST_ACCOUNTS
        where status = 'A'
        and party_id = p_company_id
        and cust_account_id in
        (select cust_account_id
         from HZ_CUST_ACCOUNT_ROLES
         where party_id = p_customer_id
         and current_role_state = 'A');

/*
        select r.cust_account_id, r.account_number
        from hz_cust_accounts r, hz_cust_account_roles s
        where r.cust_account_id = s.cust_account_id
        and s.current_role_state = 'A'
        and s.party_id = p_customer_id
        and r.party_id = p_company_id
        order by r.account_number;
*/

    begin
        l_acct_list := Account_List_Type();
        l_company_id := get_company_id_from_user(p_user_id);
        l_customer_id := get_customer_id_from_user(p_user_id);

        IF l_customer_id is not null THEN
            IF (l_company_id = NULL) THEN
                FOR acct_info_rec IN acct_info_b2c(l_customer_id)
                LOOP
                    l_acct_list.extend();
                    l_acct.account_id := acct_info_rec.cust_account_id;
                    l_acct.account_number := acct_info_rec.account_number;
                    l_acct_list(l_cind) := l_acct;
                    l_cind := l_cind + 1;
                END LOOP;
            ELSE
                FOR acct_info_rec IN acct_info_b2b(l_customer_id, l_company_id)
                LOOP
                    l_acct_list.extend();
                    l_acct.account_id := acct_info_rec.cust_account_id;
                    l_acct.account_number := acct_info_rec.account_number;
                    l_acct_list(l_cind) := l_acct;
                    l_cind := l_cind + 1;
                END LOOP;
            END IF;
        END IF;

        return l_acct_list;
        exception
            when others then
                return null;
    end get_accounts_from_user;


      function get_date_format_from_user(p_user_id IN NUMBER) return VARCHAR2
      as
      begin

        -- get the default date format for this user
        return FND_PROFILE.VALUE_SPECIFIC(
                  'ICX_DATE_FORMAT_MASK',
                  p_user_id,
                  null,
                  null);
      exception
        when others then
          return 'MON-DD-YYYY';         -- use this one as default
      end get_date_format_from_user;

      function get_long_language_from_user(p_user_id IN NUMBER) return VARCHAR2
      as
      begin

        -- get the default long language preference for this user
        return FND_PROFILE.VALUE_SPECIFIC(
                  'ICX_LANGUAGE',
                  p_user_id,
                  null,
                  null);
      exception
        when others then
          return 'AMERICAN';         -- use this one as default
      end get_long_language_from_user;

      -- other util functions

      function get_close_bin_url(p_bin_id IN NUMBER, p_cookie_url IN VARCHAR2)
        return VARCHAR2
	 as
        l_close_url  VARCHAR2(5000);
      begin
        l_close_url := 'ibuhpage.jsp?action=close' || fnd_global.local_chr(38)
				   || 'binId=' || to_char(p_bin_id);
        if p_cookie_url is not null then
           l_close_url := l_close_url || fnd_global.local_chr(38) || p_cookie_url;
        end if;
	   return l_close_url;
      end get_close_bin_url;

      function get_edit_bin_url(p_bin_id IN NUMBER,
                                p_jsp_file_name IN VARCHAR2,
						  p_filter_string IN VARCHAR2,
                                p_cookie_url IN VARCHAR2)
	   return VARCHAR2
	 as
        l_edit_url  VARCHAR2(5000);
      begin
        l_edit_url := 'ibuhedtf.jsp?binId=' || to_char(p_bin_id)
                       || fnd_global.local_chr(38) || 'filterFile=' || p_jsp_file_name;

        if p_filter_string is not null then
           l_edit_url := l_edit_url || fnd_global.local_chr(38) || p_filter_string;
        end if;

        if p_cookie_url is not null then
           l_edit_url := l_edit_url || fnd_global.local_chr(38) || p_cookie_url;
        end if;
	   return l_edit_url;
      end get_edit_bin_url;

      function get_bin_header_html(p_bin_name IN VARCHAR2,
                                   p_bin_link_url IN VARCHAR2,
                                   p_edit_url IN VARCHAR2,
                                   p_close_url IN VARCHAR2)
        return VARCHAR2
      as
        l_html  VARCHAR2(18000);
        l_tmp_str VARCHAR2(10000);
        newln     VARCHAR2(2) := fnd_global.newline ();
	   l_prompts IBU_Home_Page_PVT.IBU_STR_ARR;
        l_edit_name VARCHAR2(80);
        l_close_name VARCHAR2(80);
      begin
        l_html := newln || ' <table border=0 cellspacing=0 cellpadding=0 width="100%">'
                  || newln
				  || '  <tr><th id=h1><th id=h2><th id=h3><th id=h4><th id=h5></tr>' ||newln
			      || '  <tr>' || newln
                  || '    <td headers=h1><img height=21 src="/OA_MEDIA/jtfutl02.gif" width="7" alt=""></td>'
                  || newln
                  || '    <td headers=h2 nowrap width="100%" class="binHeaderCell">';

        if (p_edit_url is not null OR p_close_url is not null) then
           IBU_Home_Page_PVT.get_ak_region_items('IBU_HOM_PAGE', l_prompts);

           if l_prompts.count() = 0 then
              l_edit_name := 'Edit';
              l_close_name := 'Close';
           else
              l_edit_name := l_prompts(4);
              l_close_name := l_prompts(5);
           end if;
        end if;

        if p_bin_link_url is not null AND  p_bin_link_url <> '' then
           l_tmp_str := '<a href="' || p_bin_link_url
					|| '"><font color="#FFFFFF">'
                         || p_bin_name  || '</font></a>';
           else
              l_tmp_str := p_bin_name;
           end if;

        l_html := l_html || l_tmp_str || '</td>' || newln;

        l_tmp_str := '';

	   if p_edit_url is not null then
		l_tmp_str := '  <td headers=h3 nowrap class="binHeaderCell"><a href="' || p_edit_url
				   || '"><font size="-1" color="#FFFFFF">' || l_edit_name
				   || '</font></a>' || fnd_global.local_chr(38) || 'nbsp;</td>' || newln;
        end if;

	   if p_close_url is not null then
		l_tmp_str := l_tmp_str
				   || '  <td headers=h4 nowrap class="binHeaderCell"><a href="' || p_close_url
				   || '"><font size="-1" color="#FFFFFF">' || l_close_name
				   || '</font></a></td>' || newln;
        end if;

        l_html := l_html || l_tmp_str
			   || '  <td  headers=h5><img height=21 src="/OA_MEDIA/jtfutr02.gif" width="7" alt=""></td>'
                  || newln || '  </tr>' || newln || ' </table>' || newln;

        return l_html;
      end get_bin_header_html;

      procedure get_bin_info(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
                     x_return_status          OUT NOCOPY  VARCHAR2,
                     x_msg_count        OUT NOCOPY  NUMBER,
                     x_msg_data         OUT NOCOPY  VARCHAR2,
                     p_bin_id           IN NUMBER,
                     x_bin_info     OUT NOCOPY Bin_Data_Type)
      as
        l_attrib_name  VARCHAR2(60);
        l_attrib_val  VARCHAR2(300);
        l_pd_attrib_tbl JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;
        l_bin_info    Bin_Data_Type;
	 begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	   l_bin_info.bin_id := p_bin_id;

        get_perz_data_attrib(p_api_version_number => 1.0,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_prof_name   => G_ADMIN_PROFILE_NAME,
          p_pd_id     => p_bin_id,
          p_pd_name   => null,
          p_pd_type   => null,
          p_one_attrib => FND_API.G_FALSE,
          x_pd_attrib_value => l_attrib_val,
          x_pd_attrib_tbl => l_pd_attrib_tbl
        );

        if NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		-- the bin does not exist (maybe deleted)
	     l_bin_info.bin_id := null;
          return;
        end if;

        IF l_pd_attrib_tbl is not null AND l_pd_attrib_tbl.count > 0 THEN
          FOR f_curr_row IN 1..l_pd_attrib_tbl.count
          LOOP
              -- check the attribute name and set the return value
              l_attrib_name  := l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_NAME;
              l_attrib_val := l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_VALUE;

				IF l_attrib_name = G_BIN_PACKAGE_ATTR_NAME THEN
			  		l_bin_info.package_name := l_attrib_val;
				ELSIF l_attrib_name = G_BIN_MANDATORY_ATTR_NAME THEN
					if l_attrib_val = 'Y' then
						l_bin_info.mandatory_flag := FND_API.G_TRUE;
					else
						l_bin_info.mandatory_flag := FND_API.G_FALSE;
					end if;
				ELSIF l_attrib_name = G_BIN_DISABLED_ATTR_NAME THEN
					if l_attrib_val = 'Y' then
						l_bin_info.disabled_flag := FND_API.G_TRUE;
					else
						l_bin_info.disabled_flag := FND_API.G_FALSE;
					end if;
				ELSIF l_attrib_name = G_BIN_MES_ID_ATTR_NAME THEN
					l_bin_info.MES_cat_ID := to_number(l_attrib_val);
				ELSIF l_attrib_name = G_BIN_ROW_NUMBER_ATTR_NAME THEN
					l_bin_info.row_number := to_number(l_attrib_val);
				END IF;
		  END LOOP;
      END IF;

      x_bin_info := l_bin_info;

      exception
        when others then
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
	   x_bin_info := l_bin_info;
      end get_bin_info;

      function get_formatted_date(p_date in DATE, p_format in VARCHAR2)
        return VARCHAR2
	 as
	 begin
	   return to_char(p_date, p_format);
      end get_formatted_date;

      procedure get_ak_region_items(p_region_code IN VARCHAR2,
                                    p_prompts OUT NOCOPY IBU_STR_ARR)
      as
        l_region_name       varchar2(50);
        l_empty_str         varchar2(30) := ' ';
        l_items_table jtf_region_pub.ak_region_items_table;
        l_item_name         varchar2(50) := null;
        l_prompts  IBU_STR_ARR := IBU_STR_ARR ();
      begin
           jtf_region_pub.get_region(p_region_code,
                                      get_app_id,
                                      get_resp_id,
                                      l_empty_str,
                                      l_region_name,
                                      l_empty_str,
                                      l_items_table);

            FOR l in 1..l_items_table.count()
            loop
               l_prompts.extend();
			l_prompts(l) := jtf_region_pub.get_region_item_name(
							l_items_table(l).attribute_code,
							p_region_code);
		  end loop;
		  p_prompts := l_prompts;
      exception
		  when others then
		    -- return empty array
		    p_prompts := l_prompts;
      end get_ak_region_items;

      function get_ak_bin_prompt(p_region_item_name IN VARCHAR2)
		   return VARCHAR2
      as
	   l_region_code       varchar2(20) := G_HOME_REGION_CODE;
        l_region_name       varchar2(50);
        l_empty_str         varchar2(30) := ' ';
        l_items_table jtf_region_pub.ak_region_items_table;
        l_item_name         varchar2(50) := null;
      begin
           jtf_region_pub.get_region(l_region_code,
                                      get_app_id,
                                      get_resp_id,
                                      l_empty_str,
                                      l_region_name,
                                      l_empty_str,
                                      l_items_table);

            FOR l in 1..l_items_table.count()
            loop
			if l_items_table(l).attribute_code like p_region_item_name then
			   return jtf_region_pub.get_region_item_name(
							l_items_table(l).attribute_code,
							l_region_code);
			end if;
		  end loop;

		  return null;
      end get_ak_bin_prompt;

      procedure get_ak_region_items_from_user(p_user_id IN NUMBER,
							 p_region_code IN VARCHAR2,
                                    p_prompts OUT NOCOPY IBU_STR_ARR)
      as
        l_region_name       varchar2(50);
        l_empty_str         varchar2(30) := ' ';
        l_items_table jtf_region_pub.ak_region_items_table;
        l_item_name         varchar2(50) := null;
        l_prompts  IBU_STR_ARR := IBU_STR_ARR ();
      begin
           jtf_region_pub.get_region(p_region_code,
                                      get_app_id,
                                      get_resp_id_from_user(p_user_id),
                                      l_empty_str,
                                      l_region_name,
                                      l_empty_str,
                                      l_items_table);

            FOR l in 1..l_items_table.count
            loop
               l_prompts.extend();
			l_prompts(l) := jtf_region_pub.get_region_item_name(
							l_items_table(l).attribute_code,
							p_region_code);
		  end loop;
		  p_prompts := l_prompts;
      exception
		  when others then
		    -- return empty array
		    p_prompts := l_prompts;
      end;

procedure get_filter_list(p_api_version     IN   NUMBER,
                     p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
                     p_user_id            IN   NUMBER,
                     p_bin_id        In   NUMBER,
                     x_return_status          OUT  NOCOPY VARCHAR2,
                     x_msg_count         OUT NOCOPY  NUMBER,
                     x_msg_data          OUT NOCOPY  VARCHAR2,
                     x_filter_list OUT NOCOPY Filter_Data_List_Type,
                     x_filter_string OUT NOCOPY VARCHAR2)
as
     l_api_name     CONSTANT       VARCHAR2(30)   := 'Get_Filter_List';
     l_api_version  CONSTANT       NUMBER         := 1.0;

     l_attrib_val  VARCHAR2(300);
     l_pd_attrib_tbl JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;

     data             Filter_Data_Type;
     filter_list      Filter_Data_List_Type;
     ind              NUMBER := 0;
begin

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API Body
     filter_list         := Filter_Data_List_Type ();
     ind                 := 1;
     x_filter_string     := null;
     x_filter_list       := null;

     IBU_Home_Page_PVT.get_perz_data_attrib(
          p_api_version_number => l_api_version,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_user_id   => p_user_id,
          p_pd_id     => null,
          p_pd_name   => G_FILTER_DATA_NAME || to_char(p_bin_id),
          p_pd_type   => G_FILTER_DATA_TYPE,
          p_one_attrib => FND_API.G_FALSE,
          p_pd_attrib_name => null,
          x_pd_attrib_value => l_attrib_val,
          x_pd_attrib_tbl => l_pd_attrib_tbl
     );

     IF x_return_status = FND_API.G_RET_STS_SUCCESS
       AND l_pd_attrib_tbl is not null AND l_pd_attrib_tbl.count > 0 THEN
          FOR f_curr_row IN 1..l_pd_attrib_tbl.count
          LOOP
              -- add one more item in filter list
              data.name  := l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_NAME;
              data.value := l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_VALUE;

              filter_list.extend ();
              filter_list (ind) := data;
              ind := ind + 1;

              -- append it to filter string
		    if l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_VALUE is not null then
                if f_curr_row = 1 then
                  x_filter_string := l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_NAME
                    || '=' || l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_VALUE;
                else
                  x_filter_string := x_filter_string || fnd_global.local_chr(38)
                    || l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_NAME
                    || '=' || l_pd_attrib_tbl (f_curr_row).ATTRIBUTE_VALUE;
                end if;
              end if;

          END LOOP;
     END IF;

     x_filter_list := filter_list;

     -- End of API Body

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );
EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
end get_filter_list;

      procedure get_perz_data_attrib(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
                     p_commit       IN VARCHAR := FND_API.G_FALSE,
                     x_return_status          OUT NOCOPY  VARCHAR2,
                     x_msg_count         OUT NOCOPY  NUMBER,
                     x_msg_data          OUT NOCOPY  VARCHAR2,
                     p_user_id IN NUMBER := 0,
                     p_prof_name IN VARCHAR2 := NULL,
                     p_pd_id   IN NUMBER,
                     p_pd_name IN VARCHAR2,
                     p_pd_type IN VARCHAR2,
                     p_one_attrib IN VARCHAR2 := FND_API.G_TRUE,
                     p_pd_attrib_name IN VARCHAR2 := NULL,
                     --x_pd_id   OUT NOCOPY NUMBER,
                     --x_pd_name OUT NOCOPY VARCHAR2,
                     --x_pd_type OUT NOCOPY VARCHAR2,
                     --x_pd_desc OUT NOCOPY VARCHAR2,
                     x_pd_attrib_value OUT NOCOPY VARCHAR2,
                     x_pd_attrib_tbl OUT NOCOPY JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
                    )
      as
	   l_profile_id    NUMBER;
        l_profile_name  VARCHAR2(60);
	   l_pd_id NUMBER;
	   l_pd_name VARCHAR2(60);
	   l_pd_type VARCHAR2(30);
        out_perz_data_id         NUMBER;
        out_perz_data_name        VARCHAR2(60);
        out_perz_data_type  VARCHAR2(30);
        out_perz_data_desc  VARCHAR2(240);
      begin

        --  Initialize API return status to success
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_pd_attrib_value := NULL;

        --  API Body

        -- get the profile name first
	   if p_prof_name is NULL then
          if p_pd_id = 0 then
            -- add error message
            RETURN;
          else
            -- get the profile name from user id
            l_profile_name := G_USER_PROFILE_NAME || to_char(p_user_id);
          end if;
        else
          l_profile_name := p_prof_name;
        end if;

	   if p_pd_id is not NULL then
		l_pd_id := p_pd_id;
	   end if;
	   if p_pd_name is not NULL then
		l_pd_name := p_pd_name;
	   end if;
	   if p_pd_type is not NULL then
		l_pd_type := p_pd_type;
	   end if;

        if p_one_attrib = FND_API.G_TRUE and p_pd_attrib_name is NULL then
          RETURN;
        end if;

        JTF_PERZ_DATA_PUB.Get_Perz_Data
        (
          p_api_version_number     =>   p_api_version_number,
          p_init_msg_list          =>   p_init_msg_list,
          p_application_id    =>   get_app_id,
		p_profile_id        =>   l_profile_id,
          p_profile_name          =>    l_profile_name,
          p_perz_data_id      =>   l_pd_id,
          p_perz_data_name    =>   l_pd_name,
          p_perz_data_type    =>   l_pd_type,
          x_perz_data_id          =>    out_perz_data_id,
          x_perz_data_name        =>    out_perz_data_name,
          x_perz_data_type    =>   out_perz_data_type,
          x_perz_data_desc    =>   out_perz_data_desc,
          x_data_attrib_tbl   =>   x_pd_attrib_tbl,
          x_return_status          =>   x_return_status,
          x_msg_count         =>   x_msg_count,
          x_msg_data          =>   x_msg_data
        );

	   if NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             RETURN;
        end if;

        if p_pd_attrib_name is not null then
          for l_curr_row in 1..x_pd_attrib_tbl.count
	     loop
		  if x_pd_attrib_tbl(l_curr_row).ATTRIBUTE_NAME = p_pd_attrib_name then
		    x_pd_attrib_value := x_pd_attrib_tbl(l_curr_row).ATTRIBUTE_VALUE;
		    RETURN;
		  end if;
          end loop;

          if p_one_attrib = FND_API.G_TRUE then
            -- the value does not exist
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_pd_attrib_value := null;
          end if;
        end if;

       exception
         WHEN OTHERS THEN
           --ROLLBACK TO CS_Process_Order_Line;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
 	  end get_perz_data_attrib;



end IBU_HOME_PAGE_PVT;

/
