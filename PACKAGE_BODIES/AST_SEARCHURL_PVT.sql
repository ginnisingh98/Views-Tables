--------------------------------------------------------
--  DDL for Package Body AST_SEARCHURL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_SEARCHURL_PVT" AS
/* $Header: astvschb.pls 115.12 2002/02/06 11:44:32 pkm ship   $ */

  G_PKG_NAME        CONSTANT VARCHAR2(30) :='AST_SEARCHURL_PVT';
  G_FILE_NAME       CONSTANT VARCHAR2(12) :='astvsrch.pls';
  G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
  G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;

  PROCEDURE Query_SearchURL (p_api_version      IN NUMBER := 1.0,
                             p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                             p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                             p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status   OUT VARCHAR2,
                             x_msg_count       OUT NUMBER,
                             x_msg_data        OUT VARCHAR2,
			     p_search_id       IN NUMBER, -- add by jypark 12/27/2000 for new requirement
                             p_fname           IN VARCHAR2,
                             p_lname           IN VARCHAR2,
                             p_address         IN VARCHAR2,
                             p_city            IN VARCHAR2,
			     p_state           IN VARCHAR2,
                             p_zip             IN VARCHAR2,
                             p_country         IN VARCHAR2,
 			     x_search_url      OUT VARCHAR2,
                             x_max_nbr_pages   OUT VARCHAR2,
                             x_next_page_ident OUT VARCHAR2)
  AS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Query_SearchURL';
    l_search_url VARCHAR2(1000);
    i  NUMBER;
    j  NUMBER;
    k  NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

	-- added these for message hooks
    l_fname            VARCHAR2(50);
    l_lname            VARCHAR2(50);
    l_address          VARCHAR2(100);
    l_city             VARCHAR2(50);
    l_state            VARCHAR2(50);
    l_zip              VARCHAR2(50);
    l_country          VARCHAR2(50);

    CURSOR c_wsearch(x_search_id NUMBER) IS
      SELECT search_id, search_url, next_page_ident, max_nbr_pages
      FROM ast_web_searches
      WHERE search_id = x_search_id
	 AND UPPER(enabled_flag) = 'Y';

      /* begin: commented by scherkas on 01/12/2001 to support maps
	 AND UPPER(directory_assist_flag) = 'Y';
         end: commented by scherkas on 01/12/2001 to support maps */

    CURSOR c_qstring(x_search_id NUMBER) IS
      SELECT query_string_id, switch_separator, url_separator, header_const, trailer_const
      FROM ast_query_strings
      WHERE search_id = x_search_id
      AND UPPER(enabled_flag) = 'Y';

    CURSOR c_cswitch(x_query_string_id NUMBER) IS
      SELECT cgi_switch_id, switch_code, switch_type
      FROM ast_cgi_switches
      WHERE query_string_id = x_query_string_id
      AND UPPER(enabled_flag) = 'Y'
      ORDER BY sort_order;

    CURSOR c_sdata(x_cgi_switch_id NUMBER) IS
      SELECT first_name_yn, last_name_yn, address_yn, city_yn, state_yn, country_yn, zip_yn
      FROM ast_switch_data
      WHERE cgi_switch_id = x_cgi_switch_id;

  BEGIN
    --dbms_output.put_line('In Query_SearchURL ....');
    --  Standard begin of API savepoint
    SAVEPOINT	Query_SearchURL_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	-- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   -- Implementation of User Hooks
    /*   Copy all parameters to local variables to be passed to Pre, Post and Business APIs  */
    /*  l_rec      -  will be used as In Out parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a out variable to get return code from called APIs  */

	l_fname            := p_fname;
	l_lname            := p_lname;
	l_address          := p_address;
	l_city             := p_city;
	l_state            := p_state;
	l_zip              := p_zip;
	l_country          := p_country;

    /*  	Customer pre -processing  section - Mandatory 	*/
    IF  (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C' )  )  THEN
	     ast_SEARCHURL_CUHK.Query_SearchURL_PRE(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_fname => l_fname,
						p_lname => l_lname,
						p_address => l_address,
						p_city => l_city,
						p_state => l_state,
						p_zip => l_zip,
						p_country => l_country);
             IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
    END IF;


    /*  	Verticle industry pre- processing section  -  mandatory     */
    IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
		ast_SEARCHURL_VUHK.Query_SearchURL_PRE(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_fname => l_fname,
						p_lname => l_lname,
						p_address => l_address,
						p_city => l_city,
						p_state => l_state,
						p_zip => l_zip,
						p_country => l_country);
		IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
           	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- beginning of API body

    --dbms_output.put_line('before first cursor');

    FOR rec_wsearch IN c_wsearch(p_search_id) LOOP
      l_search_url := rec_wsearch.search_url;
      x_max_nbr_pages := rec_wsearch.max_nbr_pages;
      x_next_page_ident := rec_wsearch.next_page_ident;
    --dbms_output.put_line('l_search_url=' || l_search_url);
      FOR rec_qstring IN c_qstring(rec_wsearch.search_id) LOOP
        l_search_url := l_search_url || rec_qstring.url_separator || rec_qstring.header_const;
    --dbms_output.put_line('l_search_url=' || l_search_url);
	   i := 0;
        FOR rec_cswitch IN c_cswitch(rec_qstring.query_string_id) LOOP
		IF i = 0 THEN
            l_search_url := l_search_url ||  rec_cswitch.switch_code;
		ELSE
            l_search_url := l_search_url ||  rec_qstring.switch_separator || rec_cswitch.switch_code;
		END IF;
		i := i + 1;

    --dbms_output.put_line('l_search_url=' || l_search_url);
          FOR rec_sdata IN c_sdata(rec_cswitch.cgi_switch_id) LOOP
            IF UPPER(rec_sdata.first_name_yn) = 'Y' THEN
              l_search_url := l_search_url || '=' || l_fname;
            ELSIF UPPER(rec_sdata.last_name_yn) = 'Y' THEN
              l_search_url := l_search_url || '=' || l_lname;
            ELSIF UPPER(rec_sdata.address_yn) = 'Y' THEN
              l_search_url := l_search_url || '=' || l_address;
            ELSIF UPPER(rec_sdata.city_yn) = 'Y' THEN
              l_search_url := l_search_url || '=' || l_city;
            ELSIF UPPER(rec_sdata.state_yn) = 'Y' THEN
              l_search_url := l_search_url || '=' || l_state;
            ELSIF UPPER(rec_sdata.country_yn) = 'Y' THEN
              l_search_url := l_search_url || '=' || l_country;
            ELSIF UPPER(rec_sdata.zip_yn) = 'Y' THEN
              l_search_url := l_search_url || '=' || l_zip;
            END IF;
    --dbms_output.put_line('l_search_url=' || l_search_url);
          END LOOP;
        END LOOP;
    --dbms_output.put_line('l_search_url=' || l_search_url);
        if rec_qstring.trailer_const is not null then
      	    l_search_url := l_search_url ||  rec_qstring.switch_separator || rec_qstring.trailer_const;
        end if;
    --dbms_output.put_line('l_search_url=' || l_search_url);
      END LOOP;
      exit;
    END LOOP;
    --dbms_output.PUT_LINE('Query String > ' || l_search_url);

    l_search_url := REPLACE(l_search_url, ' ', '+');
    x_search_url := l_search_url;

    --dbms_output.PUT_LINE('x_searchurl >>>>>>>>>>>>> ' || x_search_url);
    --dbms_output.PUT_LINE('x_max_nbr_pages >>>>>>>>> ' || x_max_nbr_pages);
    --dbms_output.PUT_LINE('x_next_page_ident >>>>>>> ' || x_next_page_ident);

    -- end of API body


    /*  Vertical Post Processing section      -  mandatory              	*/
    IF  (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V' )  )  THEN
          ast_SEARCHURL_VUHK.Query_SearchURL_POST(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_fname => l_fname,
						p_lname => l_lname,
						p_address => l_address,
						p_city => l_city,
						p_state => l_state,
						p_zip => l_zip,
						p_country => l_country);
		if (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
					RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	END IF;

	/*  Customer  Post Processing section      -  mandatory              	*/
	IF  (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' )  )  THEN
		ast_SEARCHURL_CUHK.Query_SearchURL_POST(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_fname => l_fname,
						p_lname => l_lname,
						p_address => l_address,
						p_city => l_city,
						p_state => l_state,
						p_zip => l_zip,
						p_country => l_country);
		IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
				RAISE FND_API.G_EXC_ERROR;
           	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Query_SearchURL_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Query_SearchURL_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
          ROLLBACK TO Query_SearchURL_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  END;
END;

/
