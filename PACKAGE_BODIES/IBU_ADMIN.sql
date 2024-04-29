--------------------------------------------------------
--  DDL for Package Body IBU_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_ADMIN" as
/* $Header: ibuadmnb.pls 115.10.1158.2 2002/07/24 23:42:30 jamose ship $ */

	    procedure ibu_get_subscribe_details (app_Id           NUMBER,
									 lang_code        VARCHAR2,
									 userId           VARCHAR2,
									 header       out VARCHAR2,
									 footer       out VARCHAR2,
									 subject      out VARCHAR2,
									 lstupdt      in  DATE)
         as
	        l_return_status    	    VARCHAR2(240);
	        l_api_version		    NUMBER;
    	        l_init_msg_list	         VARCHAR2(240);
    	        l_commit		         VARCHAR2(240);

    	        l_msg_count		         NUMBER;
    	        l_msg_data		         VARCHAR2(2000);
    	        l_err_msg		         VARCHAR2(240);

	        l_profile_id		    NUMBER;
	        l_profile_name		    VARCHAR2(60);
	        l_profile_type		    VARCHAR2(30);
	        l_profile_attrib_tbl JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE;

	        l_application_id	         NUMBER;

	        l_perz_data_id		    NUMBER;
	        l_perz_data_name          VARCHAR2(60);
	        l_perz_data_type	         VARCHAR2(30);
	        l_perz_data_desc	         VARCHAR2(240);
	        l_data_attrib_tbl	    JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE ;
	        l_data_out_tbl	         JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE;

	        out_perz_data_id	         NUMBER;

	        out_perz_data_name        VARCHAR2(60);
	        out_perz_data_type	    VARCHAR2(30);
	        out_perz_data_desc	    VARCHAR2(240);
             newln                     VARCHAR2(2) := fnd_global.newline ();
	    begin
	       l_api_version	:= 1.0;
    	       l_init_msg_list	:= FND_API.G_TRUE;
	       l_application_id	:= app_Id;
	       l_perz_data_name	:= 'IBU_A_SUB_' || lang_code;
	       l_profile_name	:= 'IBU_A_PROFILE00';

            JTF_PERZ_DATA_PVT.Get_Perz_Data
            (
	            p_api_version_number	=>	l_api_version,
  	            p_init_msg_list		=>	l_init_msg_list,
	            p_application_id       =>   l_application_id,
	            p_profile_id           => 	l_profile_id,
	            p_profile_name         => 	l_profile_name,
	            p_perz_data_id		=>	l_perz_data_id,
	            p_perz_data_name	     =>	l_perz_data_name,
	            p_perz_data_type	     =>	l_perz_data_type,

    	            x_perz_data_id         =>	out_perz_data_id,
	            x_perz_data_name       =>	out_perz_data_name,
	            x_perz_data_type	     =>	out_perz_data_type,
	            x_perz_data_desc	     =>	out_perz_data_desc,
	            x_data_attrib_tbl	     =>	l_data_attrib_tbl,

	            x_return_status		=>	l_return_status,
	            x_msg_count		     =>	l_msg_count,
	            x_msg_data		     =>	l_msg_data
            );

            /* Prepend footer with a new line */
            footer := newln;

            FOR l_curr_row in 1..l_data_attrib_tbl.count
            LOOP
               IF (l_data_attrib_tbl (l_curr_row).ATTRIBUTE_NAME = 'HEADER')
               THEN
	              header := l_data_attrib_tbl (l_curr_row).ATTRIBUTE_VALUE;

               ELSIF (l_data_attrib_tbl (l_curr_row).ATTRIBUTE_NAME = 'FOOTER')
               THEN
	              footer := footer || l_data_attrib_tbl (l_curr_row).ATTRIBUTE_VALUE;

               ELSE
			    subject := l_data_attrib_tbl (l_curr_row).ATTRIBUTE_VALUE;
			END IF;
            END LOOP;
		  ibu_replace_cluewords (userId, header, lstupdt);
		  /* dbms_output.put_line ('aft header=' || header); */
		  ibu_replace_cluewords (userId, subject, lstupdt);
		  /* dbms_output.put_line ('subject=' || subject); */
		  ibu_replace_cluewords (userId, footer, lstupdt);
		  /* dbms_output.put_line ('footer=' || footer); */
	    end ibu_get_subscribe_details;

    /*---------------------------------------------------------------*/
         procedure ibu_replace_cluewords (userId varchar2,
							       str in  out varchar2,
								  lstupdt DATE)
         as
            username               varchar2 (50);
		  firstname              varchar2(50);
		  lastname               varchar2(50);
	       lastmaildate           date;
	       company_name           varchar2 (50);
	       company_site           varchar2 (50);

	       query_custid           varchar2(200);
	       query_name             varchar2(200);
	       query_companyname      varchar2(200);
	       query_companysite      varchar2(200);
	       query_companyemail     varchar2(200);
	       currdate               varchar2(30);
	       custId                 varchar2(30);
		  lastmaildt             varchar2(30);
         begin
	       query_custid := 'select customer_id from FND_USER where user_id='|| userId;
		  execute immediate query_custid into custId;
		  /* dbms_output.put_line ('custId =' || custId); */

	       query_name := 'select person_first_name, person_last_name from HZ_PARTIES where party_id =' || custId;

		  execute immediate query_name into firstname, lastname;
		  firstname := firstname || ' ' || lastname;
		  str := replace (str, '<FULL_USERNAME>', firstname);
		  /* dbms_output.put_line ('str=' || str); */

	       currdate := to_char(sysdate);
            str := replace (str, '<CURRENT_DATE>', currdate);
		  /*  dbms_output.put_line ('str=' || str); */

		  /* Last Mail Date */
		  lastmaildt := to_char(lstupdt);
            str := replace (str, '<LAST_MAIL_DATE>', lastmaildt);
		  /* dbms_output.put_line ('str=' || str); */

		  /* Retrieve data company site */
            company_site := getCompanyData('COMPANY_URL');
		  str := replace (str, '<COMPANY_SITE>', company_site);

		  /* Retrieve data company name */
		  company_name := getCompanyData('COMPANY_NAME');
		  str := replace (str, '<COMPANY_NAME>', company_name);

         end ibu_replace_cluewords;

         /*---------------------------------------------------------------*/
	    function getCompanyData ( perzDataName varchar2) return varchar2
	    is
               l_return_status         VARCHAR2(240);
               l_api_version           NUMBER;
               l_init_msg_list         VARCHAR2(240);
               l_commit                VARCHAR2(240);

               l_msg_count             NUMBER;
               l_msg_data              VARCHAR2(2000);
               l_err_msg               VARCHAR2(240);
               my_message              VARCHAR2(240);

               l_profile_id            NUMBER;
               l_profile_name          VARCHAR2(60);
               l_profile_type          VARCHAR2(30);
               l_profile_attrib_tbl    JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE;

               l_application_id        NUMBER;

               l_perz_data_id          NUMBER;
               l_perz_data_name        VARCHAR2(60);
               l_perz_data_type        VARCHAR2(30);
               l_perz_data_desc        VARCHAR2(240);
               l_data_attrib_tbl       JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE ;
               l_data_out_tbl          JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE;

               out_perz_data_id        NUMBER;

               out_perz_data_name      VARCHAR2(60);
               out_perz_data_type      VARCHAR2(30);
               out_perz_data_desc      VARCHAR2(240);
               out_data_attrib_tbl     JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;
               profile_id              NUMBER;
               str                     VARCHAR2(50);
	    begin

          /* Retrieve Property Manager Profile ID */
          select profile_id into profile_id from jtf_perz_profile where profile_name like 'JTF_PROPERTY_MANAGER_DEFAULT_1';

          /* Assignments */
          l_api_version       := 1.0;
          l_init_msg_list     := FND_API.G_TRUE;

          l_perz_data_name    := perzDataName;
          l_profile_id        := profile_id;
          l_application_id    := 690;

          JTF_PERZ_DATA_PVT.Get_Perz_Data
          (
          p_api_version_number     =>   l_api_version,
          p_init_msg_list          =>   l_init_msg_list,
          p_application_id         =>   l_application_id,
          p_profile_id             =>   l_profile_id,
          p_profile_name           =>   l_profile_name,
          p_perz_data_id           =>   l_perz_data_id,
          p_perz_data_name         =>   l_perz_data_name,
          p_perz_data_type         =>   l_perz_data_type,

          x_perz_data_id          =>    out_perz_data_id,
          x_perz_data_name        =>    out_perz_data_name,
          x_perz_data_type        =>    out_perz_data_type,
          x_perz_data_desc        =>    out_perz_data_desc,
          x_data_attrib_tbl       =>    l_data_attrib_tbl,

          x_return_status         =>    l_return_status,
          x_msg_count             =>    l_msg_count,
          x_msg_data              =>    l_msg_data
          );

          /* dbms_output.put_line ('return =' || l_return_status); */
          str :=  l_data_attrib_tbl (1).ATTRIBUTE_VALUE;
          return str;
         exception
           when others then
              return '';
	    end;
         /*---------------------------------------------------------------*/
	    procedure ibu_get_subscribe_interval (app_Id           NUMBER,
								       prof_name        VARCHAR2,
								       e_interval   out VARCHAR2)
         as
	        l_return_status    	    VARCHAR2(240);
	        l_api_version		    NUMBER;
    	        l_init_msg_list	         VARCHAR2(240);
    	        l_commit		         VARCHAR2(240);

    	        l_msg_count		         NUMBER;
    	        l_msg_data		         VARCHAR2(2000);
    	        l_err_msg		         VARCHAR2(240);

	        l_profile_id		    NUMBER;
	        l_profile_name		    VARCHAR2(60);
	        l_profile_type		    VARCHAR2(30);
	        l_profile_attrib_tbl JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE;

	        l_application_id	         NUMBER;

	        l_perz_data_id		    NUMBER;
	        l_perz_data_name          VARCHAR2(60);
	        l_perz_data_type	         VARCHAR2(30);
	        l_perz_data_desc	         VARCHAR2(240);
	        l_data_attrib_tbl	    JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE ;
	        l_data_out_tbl	         JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE;

	        out_perz_data_id	         NUMBER;

	        out_perz_data_name        VARCHAR2(60);
	        out_perz_data_type	    VARCHAR2(30);
	        out_perz_data_desc	    VARCHAR2(240);
	    begin

	       l_api_version	:= 1.0;
    	       l_init_msg_list	:= FND_API.G_TRUE;
	       l_application_id	:= app_Id;
	       l_perz_data_name	:= 'IBU_A_SUBE';
	       l_profile_name	:= 'IBU_A_PROFILE00';

            JTF_PERZ_DATA_PVT.Get_Perz_Data
            (
	            p_api_version_number	=>	l_api_version,
  	            p_init_msg_list		=>	l_init_msg_list,
	            p_application_id       =>   l_application_id,
	            p_profile_id           => 	l_profile_id,
	            p_profile_name         => 	l_profile_name,
	            p_perz_data_id		=>	l_perz_data_id,
	            p_perz_data_name	     =>	l_perz_data_name,
	            p_perz_data_type	     =>	l_perz_data_type,

    	            x_perz_data_id         =>	out_perz_data_id,
	            x_perz_data_name       =>	out_perz_data_name,
	            x_perz_data_type	     =>	out_perz_data_type,
	            x_perz_data_desc	     =>	out_perz_data_desc,
	            x_data_attrib_tbl	     =>	l_data_attrib_tbl,

	            x_return_status		=>	l_return_status,
	            x_msg_count		     =>	l_msg_count,
	            x_msg_data		     =>	l_msg_data
            );


            FOR l_curr_row in 1..l_data_attrib_tbl.count
            LOOP
               IF (l_data_attrib_tbl (l_curr_row).ATTRIBUTE_NAME = 'DEFAULT_INTERVAL')
               THEN
	              e_interval := l_data_attrib_tbl (l_curr_row).ATTRIBUTE_VALUE;
			END IF;
            END LOOP;
	    end ibu_get_subscribe_interval;

	    procedure ibu_get_cnews_filter (app_Id           NUMBER,
							      filter_list out IBU_HOME_PAGE_PVT.Filter_Data_List_Type)
         as
	        l_return_status    	    VARCHAR2(240);
	        l_api_version		    NUMBER;
    	        l_init_msg_list	         VARCHAR2(240);
    	        l_commit		         VARCHAR2(240);

    	        l_msg_count		         NUMBER;
    	        l_msg_data		         VARCHAR2(2000);
    	        l_err_msg		         VARCHAR2(240);

	        l_profile_id		    NUMBER;
	        l_profile_name		    VARCHAR2(60);
	        l_profile_type		    VARCHAR2(30);
	        l_profile_attrib_tbl JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE;

	        l_application_id	         NUMBER;

	        l_perz_data_id		    NUMBER;
	        l_perz_data_name          VARCHAR2(60);
	        l_perz_data_type	         VARCHAR2(30);
	        l_perz_data_desc	         VARCHAR2(240);
	        l_data_attrib_tbl	    JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE ;
	        l_data_out_tbl	         JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE;

	        out_perz_data_id	         NUMBER;

	        out_perz_data_name        VARCHAR2(60);
	        out_perz_data_type	    VARCHAR2(30);
	        out_perz_data_desc	    VARCHAR2(240);

             data                      IBU_HOME_PAGE_PVT.Filter_Data_Type;
	        ind                       NUMBER := 1;
	    begin

	       l_api_version	:= 1.0;
    	       l_init_msg_list	:= FND_API.G_TRUE;
	       l_application_id	:= app_Id;
	       l_perz_data_name	:= 'IBU_A_CATEGORY';
	       l_profile_name	:= 'IBU_A_PROFILE00';

            JTF_PERZ_DATA_PVT.Get_Perz_Data
            (
	            p_api_version_number	=>	l_api_version,
  	            p_init_msg_list		=>	l_init_msg_list,
	            p_application_id       =>   l_application_id,
	            p_profile_id           => 	l_profile_id,
	            p_profile_name         => 	l_profile_name,
	            p_perz_data_id		=>	l_perz_data_id,
	            p_perz_data_name	     =>	l_perz_data_name,
	            p_perz_data_type	     =>	l_perz_data_type,

    	            x_perz_data_id         =>	out_perz_data_id,
	            x_perz_data_name       =>	out_perz_data_name,
	            x_perz_data_type	     =>	out_perz_data_type,
	            x_perz_data_desc	     =>	out_perz_data_desc,
	            x_data_attrib_tbl	     =>	l_data_attrib_tbl,

	            x_return_status		=>	l_return_status,
	            x_msg_count		     =>	l_msg_count,
	            x_msg_data		     =>	l_msg_data
            );


	       filter_list         := IBU_HOME_PAGE_PVT.Filter_Data_List_Type ();
            FOR f_curr_row IN 1..l_data_attrib_tbl.count
            LOOP
	         data.name  := l_data_attrib_tbl (f_curr_row).ATTRIBUTE_NAME;
		    /* dbms_output.put_line ('NAme=' || data.name); */
	         data.value := l_data_attrib_tbl (f_curr_row).ATTRIBUTE_VALUE;

	         filter_list.extend ();
	         filter_list (ind) := data;
              ind := ind + 1;
            END LOOP;
		 end ibu_get_cnews_filter;
end ibu_admin;

/
