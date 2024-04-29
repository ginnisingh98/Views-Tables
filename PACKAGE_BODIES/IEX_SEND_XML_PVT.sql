--------------------------------------------------------
--  DDL for Package Body IEX_SEND_XML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SEND_XML_PVT" as
/* $Header: iexvxmlb.pls 120.6.12010000.26 2010/06/23 17:34:23 gnramasa ship $ */
-- Start of Comments
-- Package name     : IEX_SEND_XML_PVT
-- Purpose          : Generate XML Data and Delivery by XML Publisher
-- NOTE             :
-- History          :
--     11/08/2004 CLCHANG  Created.
-- END of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_SEND_XML_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvxmlb.pls';

--   Validation
-- **************************
PG_DEBUG NUMBER ;

-- **************************

PROCEDURE fetch_lang_terr_of_loc ( p_bind_tbl  IN  IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
				   p_template_code  IN  VARCHAR2, --Added for bug 8649857 gnramasa 3rd July 09
				 x_tmpl_lang   OUT NOCOPY VARCHAR2,
				 x_tmpl_terr   OUT NOCOPY VARCHAR2)
IS
l_bind_cnt    number;
l_bind_name   varchar2(150);
l_bind_val    varchar2(240);
l_loc_lang    varchar2(10);
l_loc_terr    varchar2(10);
l_iso_lang    varchar2(10);
l_iso_lang1   varchar2(10);
l_templ_lang  varchar2(10);
l_templ_terr  varchar2(10);
l_templ_terr1 varchar2(10);
l_no_terr     number;
l_msg         VARCHAR2(1000);
l_templ_code  varchar2(100);  --Added for bug 8649857 gnramasa 3rd July 09

BEGIN
l_msg         := 'iexvxmlb.pls:FETCH_LANG_TERR_OF_LOC:';
WriteLog(l_msg || ' BEGIN' );

l_bind_cnt := p_bind_tbl.count;
--Start adding for bug 8649857 gnramasa 3rd July 09
l_templ_code := p_template_code;

for j in 1..l_bind_cnt
loop
	l_bind_name := upper(p_bind_tbl(j).Key_name);

	if l_bind_name ='LOCATION_ID' then
	    l_bind_val  := p_bind_tbl(j).Key_Value;
	    WriteLog(l_msg || 'bind_name = '||l_bind_name || ' value=' || l_bind_val );
	    EXIT;
	end if;
end loop;

if l_bind_val is not null then
select language
into l_loc_lang
from hz_locations
where location_id= to_number(l_bind_val);

WriteLog(l_msg || 'l_loc_lang = '||l_loc_lang );

if l_loc_lang is not null then
	select iso_language
	into l_iso_lang
	from fnd_languages
	where language_code= upper(l_loc_lang);

	WriteLog(l_msg || 'l_iso_lang = '||l_iso_lang );

	select count(distinct territory)
	into l_no_terr
	from xdo_lobs
	where application_short_name='IEX' and upper(language)=l_iso_lang
	and territory <> '00'
	and lob_code = l_templ_code;

	WriteLog(l_msg || 'l_no_terr = '||l_no_terr );

	l_templ_lang := l_iso_lang;

	--if no of territory is >1 then send territory as '00' else the default territory for that template.
	if l_no_terr = 1 then
		select distinct territory
		into l_templ_terr
		from xdo_lobs
		where application_short_name='IEX' and upper(language)=l_iso_lang
		and territory <> '00'
		and lob_code = l_templ_code;

	--End adding for bug 8649857 gnramasa 3rd July 09

	else
		l_templ_terr := '00';
	end if;
	WriteLog(l_msg || 'l_templ_terr = '||l_templ_terr );
end if;
end if;
x_tmpl_lang := l_templ_lang;
x_tmpl_terr := l_templ_terr;
WriteLog(l_msg || ', l_templ_lang :' ||l_templ_lang );
WriteLog(l_msg || ', l_templ_terr :' ||l_templ_terr );
WriteLog(l_msg || ' END' );

EXCEPTION
WHEN OTHERS THEN
           WriteLog(l_msg || ' Procedure fetch_lang_terr_of_loc, in when Other exception:'|| SQLERRM);

END fetch_lang_terr_of_loc;

PROCEDURE Send_COPY(
    p_Api_Version_Number     IN  NUMBER,
    p_Init_Msg_List          IN  VARCHAR2   ,
    p_Commit                 IN  VARCHAR2   ,
    p_resend                 IN  VARCHAR2   ,
    p_request_id             IN  NUMBER   ,
    p_user_id                IN  NUMBER,
    p_party_id               IN  NUMBER,
    p_subject                IN  VARCHAR2,
    p_bind_tbl               IN  IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
    p_template_id            IN  NUMBER,
    p_resource_id            IN  NUMBER,
    p_query_id               IN  NUMBER,
    p_method                 IN  VARCHAR2,
    p_dest                   IN  VARCHAR2,
    p_level                  IN  VARCHAR2,
    p_source_id              IN  NUMBER,
    p_object_type            IN  VARCHAR2,
    p_object_id              IN  NUMBER,
    p_dunning_mode           IN  VARCHAR2,  -- added by gnramasa for bug 8489610 14-May-09
    p_parent_request_id      IN NUMBER,
    p_org_id                 in number, -- added for bug 9151851
    X_Request_ID             OUT NOCOPY NUMBER,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2
    )
 IS

    CURSOR C_GET_DEL (IN_DEL_ID NUMBER) IS
      SELECT cust_account_id, customer_site_use_id
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
    --
    --Start Adding for bug 8649857 gnramasa 3rd July 09
    CURSOR C_GET_TEMPCODE (IN_TEMP_ID NUMBER) IS
      SELECT template_code
        FROM XDO_TEMPLATES_VL
       WHERE template_id = in_TEMP_ID
         --AND Application_id = 695;
         AND Application_short_name = 'IEX';

	 --Start Adding for bug 8845762 snuthala 9/14/2009
    CURSOR C_GET_QUERY_TEMP_ID (P_QUERY_ID NUMBER) IS
      SELECT xref.query_temp_id
        FROM iex_query_temp_xref xref
       WHERE xref.query_id = P_QUERY_ID;
    -- end  Adding for bug 8845762 snuthala 9/14/2009


    l_api_name         	   CONSTANT VARCHAR2(30) := 'IEXVXMLB';
    l_api_version				   NUMBER := 1.0;
    l_commit               VARCHAR2(5) ;
    --
    l_template_id				   NUMBER;
    l_tempcode             VARCHAR2(80);
    l_lang                 VARCHAR2(6);
    l_terr                 VARCHAR2(6);
    l_query_id             NUMBER;
    l_method               VARCHAR2(30);
    l_email                VARCHAR2(1000) ;
    l_printer              VARCHAR2(1000) ;
    l_fax                  VARCHAR2(1000) ;
    --
    l_party_id             NUMBER ;
    l_account_id           NUMBER ;
    l_site_id              NUMBER ;
    l_delinquency_id       NUMBER ;
    l_user_id              NUMBER ;
    --
    l_request_id           NUMBER ;
    l_rowid                VARCHAR2(2000) ;
    l_msg_count            NUMBER ;
    l_msg_data             VARCHAR2(1000);
    l_return_status        VARCHAR2(1000);
    l_status               VARCHAR2(100);
    l_curr_lang            VARCHAR2(100);
    l_submit_request_id    NUMBER ;
    --l_content_xml          VARCHAR2(32767);
    l_content_xml          CLOB;
    l_doc                  BLOB;

    l_msg                  VARCHAR2(1000);
    l_query_temp_id        VARCHAR2(100);  -- Added for bug#8845762 by SNUTHALA on 9/14/2009

    uphase VARCHAR2(255);
    dphase VARCHAR2(255);
    ustatus VARCHAR2(255);
    dstatus VARCHAR2(255);
    l_bool BOOLEAN;
    message VARCHAR2(32000);

    l_templ_lang  varchar2(10);
    l_templ_terr  varchar2(10);

    l_object_type varchar2(30); -- Added for bug#8445620 by PNAVEENK on 21-4-2009
    l_con_req_id  number;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT SEND_COPY_PUB;

      l_party_id				  := p_party_id;
      l_user_id				    := p_user_id;
      l_msg               := 'iexvxmlb.pls:SEND_COPY:';

      WriteLog(l_msg || 'Start...');


      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      WriteLog(l_msg || ' p_party_id = ' || p_party_id  );
      WriteLog(l_msg || ' p_resource_id = ' || p_resource_id  );
      WriteLog(l_msg || ' p_level= ' || p_level );
      WriteLog(l_msg || ' p_source_id= ' || p_source_id );
      WriteLog(l_msg || ' p_object_type= ' || p_object_type );
      WriteLog(l_msg || ' p_object_id= ' || p_object_id );
      WriteLog(l_msg || ' p_dest = ' || p_dest);
      WriteLog(l_msg || ' p_dunning_mode = ' || p_dunning_mode);
      WriteLog(' p_org_id ' || p_org_id);
      IF (p_level = 'CUSTOMER') then
          null;
      ELSIF (p_level = 'ACCOUNT') then
          l_account_id := p_source_id;
      ELSIF (p_level = 'BILL_TO') then
          l_site_id := p_source_id;
      ELSIF (p_level = 'DELINQUENCY') then
          l_delinquency_id := p_source_id;
          if (l_delinquency_id is not null) then
             Open C_Get_Del(l_delinquency_id);
             Fetch C_Get_Del into l_account_id, l_site_id;
             Close C_Get_Del;
          end if;
      END IF;
      WriteLog(l_msg || ' l_account_id = ' || l_account_id  );
      WriteLog(l_msg || ' l_site_id = ' || l_site_id  );
      WriteLog(l_msg || ' l_delinquency_id = ' || l_delinquency_id  );

      -- ******************************************************************
      -- Get Request Id first
      -- ******************************************************************

      -- The output request_id must be passed to all subsequent calls made
      -- for this request.

      -- ******************************************************************
      -- Generate XML DATA
      -- ******************************************************************

       WriteLog(l_msg || ' p_resend='  || p_resend);

       if p_request_id is not null then

         -- retrieve xml data from table
         WriteLog(l_msg || ' Retrieve XML Data...' );
    	   RetrieveXmlData (
            p_request_id      => p_request_id,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data,
            x_xml             => l_content_xml );
         WriteLog(l_msg || ' End Retrieve XML Data...' );
         --l_request_id := p_request_id;

       else

         WriteLog(l_msg || ' GetXmlData...' );

    	   GetXmlData (
            p_party_id        => l_party_id,
            p_bind_tbl        => p_bind_tbl,
            p_resource_id     => p_resource_id,
            p_query_id        => p_query_id,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data,
            x_xml             => l_content_xml );

         WriteLog(l_msg || ' End GetXmlData...' );
       end if;

       WriteLog(l_msg || ' GetXmlData status=' || l_return_status );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             WriteLog(l_msg || ' error to get XML data');
             --
             x_msg_data := l_msg_data;
             x_msg_count := l_msg_count;
             --
             FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_XMLDATA');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
       END IF;

       --WriteLog(l_msg || ' xml= ' || l_content_xml );
       l_request_id := null;
       l_doc := empty_blob();


       WriteLog(l_msg || ' Get Template Code' );

       OPEN C_GET_TEMPCODE (p_template_id);
       FETCH C_GET_TEMPCODE INTO l_tempcode;

       IF (C_GET_TEMPCODE%NOTFOUND) THEN
         --FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
         --FND_MESSAGE.Set_Token ('INFO', 'Cannot find xdo template code');
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_XDOTEMP');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE C_GET_TEMPCODE;
       WriteLog(l_msg || ' Template Code = ' || l_tempcode);

       if  nvl(fnd_profile.value('IEX_USE_CUST_LANG_DUNN_LETTER'),'N') = 'N' then
		l_templ_lang := null;
		l_templ_terr := null;
       else
       --call fetch_lang_terr_of_loc to find the lang and territory of a location.
		fetch_lang_terr_of_loc ( p_bind_tbl   => p_bind_tbl,
					 p_template_code => l_tempcode,
					 x_tmpl_lang  => l_templ_lang,
					 x_tmpl_terr  => l_templ_terr
					);

	end if; --nvl(fnd_profile.value('IEX_USE_CUST_LANG_DUNN_LETTER'),'N') = 'N' then
	--End adding for bug 8649857 gnramasa 3rd July 09

       WriteLog('Template will be processed with language, l_templ_lang :' || l_templ_lang );
       WriteLog('Template will be processed with territory, l_templ_terr :' || l_templ_terr );

	if p_parent_request_id is not null then
		l_con_req_id := p_parent_request_id;
	else
		l_con_req_id := FND_GLOBAL.Conc_Request_Id;
	end if;

-- Added for bug#8845762 by SNUTHALA on 9/14/2009
	 if (p_query_id is not null) then
             Open C_GET_QUERY_TEMP_ID(p_query_id);
             Fetch C_GET_QUERY_TEMP_ID into l_query_temp_id;
             Close C_GET_QUERY_TEMP_ID;
          end if;
        WriteLog('Query temp id '|| l_query_temp_id);
       WriteLog(l_msg || ' insert_row' );
       WriteLog(' before insert xml org_id ' || p_org_id);
       -- Insert Table with XML
       IEX_XML_PKG.insert_row (
          px_rowid                  => l_rowid
         ,px_xml_request_id         => l_request_id
         ,p_query_temp_id           => l_query_temp_id   -- Added for bug#8845762 by SNUTHALA on 9/14/2009
         ,p_status                  => 'XMLDATA'
         ,p_document                => l_doc
	 ,p_html_document           => l_doc
         ,p_xmldata                 => l_content_xml
         ,p_method                  => p_method
         ,p_destination             => p_dest
	 ,p_subject                 => p_subject
         ,p_object_type             => p_object_type
         ,p_object_id               => p_object_id
         ,p_resource_id             => p_resource_id
         ,p_view_by                 => p_level
         ,p_party_id                => l_party_id
         ,p_cust_account_id         => l_account_id
         ,p_cust_site_use_id        => l_site_id
         ,p_delinquency_id          => l_delinquency_id
         ,p_last_update_date        => sysdate
         ,p_last_updated_by         => l_user_id
         ,p_creation_date           => sysdate
         ,p_created_by              => l_user_id
         ,p_last_update_login       => l_user_id
         ,p_object_version_number   => l_user_id
	 ,p_request_id              => -1
	 ,p_worker_id               => -1
	 ,p_confirmation_mode       => null                         -- added by gnramasa for bug 8489610 14-May-09
	 ,p_conc_request_id         => l_con_req_id   --FND_GLOBAL.Conc_Request_Id   -- added by gnramasa for bug 8489610 14-May-09
	 ,p_org_id                  => p_org_id       -- added for bug 9151851
	 ,p_template_language       => lower(l_templ_lang)                 -- added by gnramasa for bug 8489610 28-May-09
	 ,p_template_territory      => upper(l_templ_terr)                 -- added by gnramasa for bug 8489610 28-May-09
       );

       COMMIT;

       WriteLog(l_msg || 'l_request_id = ' || l_request_id);
       x_request_id := l_request_id;



      -- ******************************************************************
      -- Delivery
      -- ******************************************************************

       WriteLog(l_msg || ' Delivery...' );

       /*
	if l_lang is not null then
		select iso_language
		into l_iso_lang1
		from fnd_languages
		where language_code= upper(l_lang);

		WriteLog(l_msg || 'l_iso_lang1 = '||l_iso_lang1 );

		select count(distinct territory)
		into l_no_terr
		from xdo_lobs
		where application_short_name='IEX' and upper(language)=l_iso_lang1;

		WriteLog(l_msg || 'l_no_terr = '||l_no_terr );

		l_lang := l_iso_lang1;

		--if no of territory is >1 then send territory as '00' else the default territory for that template.
		if l_no_terr = 1 then
			select distinct territory
			into l_templ_terr1
			from xdo_lobs
			where application_short_name='IEX' and upper(language)=l_iso_lang1;
		else
			l_templ_terr1 := '00';
		end if;
		WriteLog(l_msg || 'l_templ_terr1 = '||l_templ_terr1 );
	end if;
	l_terr := l_templ_terr1;
	WriteLog(l_msg || ' Default Lang = ' || l_lang);
        WriteLog(l_msg || ' Default Terr = ' || l_terr);
	*/

	--l_templ_lang := l_lang;
	--l_templ_terr := l_terr;

--Start adding for bug 8489610 by gnramasa 14-May-09
--Don't span the IEXXMLGEN at any time for IEX: Send dunning cp. Irrespective of the IEX_DELIVER_DUNNING_LETTERS profile value,
--Span only bulk xml manager at the end i.e in iexpdunb.pls
 -- if ((FND_GLOBAL.Conc_Request_Id = -1) or (fnd_profile.value('IEX_DELIVER_DUNNING_LETTERS')='IMMEDIATE')) and (p_dunning_mode IS NULL) then
  IF ((fnd_profile.value('IEX_DELIVER_DUNNING_LETTERS')='IMMEDIATE' or
  (p_object_type not in ('PARTY' , 'IEX_ACCOUNT' , 'IEX_BILLTO' , 'IEX_DELINQUENCY', 'IEX_STRATEGY') and FND_GLOBAL.Conc_Request_Id = -1))
  and (p_dunning_mode IS NULL)) then
	--start added by snuthala 7442795 added if condition such that request will be submitted only if profile value is IMMEDIATE or its called from IEXRCALL

	       if  nvl(fnd_profile.value('IEX_USE_CUST_LANG_DUNN_LETTER'),'N') = 'N' then

	       WriteLog(l_msg || ' Send dunning with currently logged in lang...' );
	       l_submit_request_id := FND_REQUEST.SUBMIT_REQUEST(
				      APPLICATION       => 'IEX',
				      PROGRAM           => 'IEXXMLGEN',
				      DESCRIPTION       => 'Oracle Collections Delivery XML Process',
				      START_TIME        => sysdate,
				      SUB_REQUEST       => false,
				      ARGUMENT1         => l_request_id,
				      ARGUMENT2         => p_method,
				      ARGUMENT3         => p_dest,
				      ARGUMENT4         => p_subject,
				      ARGUMENT5         => l_tempcode,
				      ARGUMENT6         => null,  -- Send dunning letter by using the current logged in language
				      ARGUMENT7         => null);
	       else
	       WriteLog(l_msg || ' Send dunning with the language from the site' );

	       l_submit_request_id := FND_REQUEST.SUBMIT_REQUEST(
				      APPLICATION       => 'IEX',
				      PROGRAM           => 'IEXXMLGEN',
				      DESCRIPTION       => 'Oracle Collections Delivery XML Process',
				      START_TIME        => sysdate,
				      SUB_REQUEST       => false,
				      ARGUMENT1         => l_request_id,
				      ARGUMENT2         => p_method,
				      ARGUMENT3         => p_dest,
				      ARGUMENT4         => p_subject,
				      ARGUMENT5         => l_tempcode,
				      ARGUMENT6         => lower(l_templ_lang),
				      ARGUMENT7         => upper(l_templ_terr));
	   end if; --profile value lang
 end if; --if (FND_GLOBAL.Conc_Request_Id = -1) or (fnd_profile.value('IEX_DELIVER_DUNNING_LETTERS')='IMMEDIATE') then
--End adding for bug 8489610 by gnramasa 14-May-09

       COMMIT;

       WriteLog(l_msg || ' delivery xml : concurrent request id= ' || l_submit_request_id );

       /**** dont wait the concurrent program

       --the main process should wait till the spawned process is over.
       IF (l_submit_request_id IS NOT NULL AND l_submit_request_id  <> 0) THEN
           LOOP
              WriteLog(l_msg ||
                     'Start Time of the xml Process IEXXMLGEN : '  ||
                     to_char (sysdate, 'dd/mon/yyyy :HH:MI:SS'));
              l_bool := FND_CONCURRENT.wait_for_request(
                     request_id =>l_submit_request_id,
                     interval   =>30,
                     max_wait   =>144000,
                     phase      =>uphase,
                     status     =>ustatus,
                     dev_phase  =>dphase,
                     dev_status =>dstatus,
                     message    =>message);

              IF dphase = 'COMPLETE'
              --and dstatus = 'NORMAL'
              --the possible values are NORMAL/ERROR/WARNING/CANCELLED/TERMINATED
              THEN
                 WriteLog(l_msg || 'End Time of the xml Process IEXXMLGEN : '||
                    to_char (sysdate, 'dd/mon/yyyy :HH:MI:SS'));
                 EXIT;
               END If; --dphase
           END LOOP;
       --
       ELSE

          WriteLog(l_msg || ' Error to delivery xml...' );
          --FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
          --FND_MESSAGE.Set_Token ('INFO', 'error to delivery xml');
          FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_DELIVERY');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;

       END IF;
       WriteLog(l_msg || ' delivery xml : concurrent request id= ' || l_submit_request_id );


       -- Update Table with Status
       IEX_XML_PKG.update_row (
          p_xml_request_id          => l_request_id
         ,p_status                  => l_return_status
         --,p_document                => l_doc
       );
      ******/

      x_request_id := l_request_id;

      --
      -- END of API body
      --

      -- Standard check for p_commit
/*      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
*/
      COMMIT WORK;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
               COMMIT WORK;
--               ROLLBACK TO SEND_COPY_PUB;
               WriteLog(l_msg || ' Exc_Error:'|| SQLERRM);
               x_return_status := FND_API.G_RET_STS_ERROR;
               -- Update Table with Status
               l_status := 'FAILURE';
               IEX_XML_PKG.update_row (
                 p_xml_request_id          => l_request_id
                ,p_status                  => l_status
               );
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               COMMIT WORK;
--               ROLLBACK TO SEND_COPY_PUB;
               WriteLog(l_msg || ' UnExc_Error:'|| SQLERRM);
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               -- Update Table with Status
               l_status := 'FAILURE';
               IEX_XML_PKG.update_row (
                 p_xml_request_id          => l_request_id
                ,p_status                  => l_status
               );
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
               COMMIT WORK;
--               ROLLBACK TO SEND_COPY_PUB;
               WriteLog(l_msg || ' Other:'|| SQLERRM);
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               -- Update Table with Status
               l_status := 'FAILURE';
               IEX_XML_PKG.update_row (
                 p_xml_request_id          => l_request_id
                ,p_status                  => l_status
               );
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
                );

END Send_COPY;


/*
   Overview: This function is to retrieve the existing xml data from
             iex_xml_request_histories table by the xml_request_id.
 */
procedure RetrieveXmlData
(
    p_request_id     IN  number
  , x_return_status  OUT NOCOPY varchar2
  , x_msg_count      OUT NOCOPY NUMBER
  , x_msg_data       OUT NOCOPY VARCHAR2
  , x_xml            OUT NOCOPY clob
)
IS
    CURSOR C_GET_XML (IN_REQUEST_ID NUMBER) IS
      SELECT xmldata
        FROM IEX_XML_REQUEST_HISTORIES
       WHERE xml_request_id = in_request_id;

    l_xml                          CLOB;

BEGIN

     WriteLog('begin RetrieveXmlData()');
     WriteLog('RetrieveXmlData: p_request_id = '||p_request_id);

     if (p_request_id is null) then
         FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
         FND_MESSAGE.Set_Token ('INFO', 'No Request_Id');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     end if;

     OPEN C_GET_XML (p_request_id);
     FETCH C_GET_XML INTO l_xml;

     IF (C_GET_XML%NOTFOUND) THEN
         FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
         FND_MESSAGE.Set_Token ('INFO', 'Cannot find xmldata');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE C_GET_XML;

     x_xml := l_xml;
     WriteLog('get XmlData');
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
        p_data           =>   x_msg_data );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         WriteLog('RetrieveXmlData: Exc_Error:'|| SQLERRM);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         WriteLog('RetrieveXmlData: Exc_Error:'|| SQLERRM);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data);
    when others then
         WriteLog('RetrieveXmlData: Exc_Error:'|| SQLERRM);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data);

END RetrieveXmlData;


/*
   Overview: This function is to get the xml data from a query which is defined by the dunning letter template.
   Parameter: p_party_id : party_id
   Return:  clob contains the result of the query
   creation date: 08/25/2004
   author:  ctlee
   Note: test only
 */
procedure GetXmlData
(
    p_party_id       IN  number
  , p_resource_id    IN  number
  , p_bind_tbl       IN  IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL
  , p_query_id       IN  number
  , x_return_status  OUT NOCOPY varchar2
  , x_msg_count      OUT NOCOPY NUMBER
  , x_msg_data       OUT NOCOPY VARCHAR2
  , x_xml            OUT NOCOPY clob
)
IS
    CURSOR C_GET_QUERY (IN_QUERY_ID NUMBER) IS
--Bug5370344. Use the New column.
--      SELECT upper(statement)
      SELECT UPPER(ADDITIONAL_QUERY), UPPER(STATEMENT)
        FROM IEX_XML_QUERIES
       WHERE query_id = in_query_id
         and trunc(sysdate) between trunc(nvl(start_date, sysdate)) and
             trunc(nvl(end_date, sysdate))
         and enabled_flag = 'Y';

--Bug5370344    l_query                         Varchar2(4000);
    l_query                         clob;
    l_query_stmt                    varchar2(4000);
    l_new_query                     clob;
    qry_string                      Varchar2(4000);
    qryCtx                          DBMS_XMLQuery.ctxType;
    result                          CLOB;
    xmlstr                          varchar2(32767);
    line                            varchar2(4000);

    l_bind_name                     varchar2(150);
    l_bind_type                     varchar2(25);
    l_bind_val                      varchar2(240);
    l_cnt                           number;
    l_found                         number;
    l_bind_cnt                      number;
    l_bind_found                    number;

    len                    number;
    l_start                number;
    l_end                  number;
    sMsg                   varchar2(250);

    v_cursor         NUMBER;
    v_numrows        NUMBER;

    --Begin Bug#6743267 24-Jul-2008 barathsr
    l_dataHdr_clob		    clob;
    l_dataHdrTag		    Varchar2(100);
    l_dataHeader		    varchar2(1000) := '';
    l_dataHdrQry		    varchar2(1000) := '';
    l_rowSetName	            varchar2(1000) := '';
    TYPE refCur IS REF CURSOR;
    xml_element  refCur;
    --End Bug#6743267 24-Jul-2008 barathsr

    /* begin bug 4732366 - ctlee - use set bind variables  11/28/2005 */
  --  l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
  --  l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_temp_index integer;

    l_temp_s_first varchar2(4000);
    l_temp_s_second varchar2(4000);

    TYPE VAR_COUNT_REC IS RECORD(
    VAR_COUNT         integer);

    TYPE VAR_COUNT_tbl IS TABLE OF VAR_COUNT_REC INDEX BY binary_integer;
    l_var_count_rec var_count_rec;
    l_var_count_tbl var_count_tbl;
    l_bind_count integer;
    /* end bug 4732366 - ctlee - use set bind variables  11/28/2005 */

BEGIN

     WriteLog('begin test GetXmlData()');
     WriteLog('GetXmlData: p_query_id = ' || p_query_id);

     OPEN C_GET_QUERY (p_query_id);
     FETCH C_GET_QUERY INTO l_query, l_query_stmt;

     IF (C_GET_QUERY%NOTFOUND) THEN
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_QUERY');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE C_GET_QUERY;

     -- begin to check the query and bind var are matched or not;
     WriteLog('GetXmlData: chk the bind var and query');

     -- replace bind var by l_bind_tbl
     l_bind_cnt := p_bind_tbl.count;
     l_cnt := 0;
     WriteLog('GetXmlData: l_bind_cnt = '||l_bind_cnt);
     if (l_query is not null) then
            l_new_query := l_query;
     else
	    l_new_query := l_query_stmt;
     end if;

     -- l_new_query := l_query;
     for j in 1..l_bind_cnt
     loop
        l_cnt := 0;
        l_bind_name := ':' || upper(p_bind_tbl(j).Key_name);
        l_bind_type := p_bind_tbl(j).Key_Type;
        l_bind_val  := p_bind_tbl(j).Key_Value;

        if l_bind_val is null then
            l_bind_val := 'null';
        end if;

        -- chk how many bind var in the query
        l_bind_found := instr( l_new_query, l_bind_name);

	--Begin Bug#6743267 24-Jul-2008 barathsr
	IF  (l_bind_found > 0) THEN
	   --Start bug 8627647 gnramasa 30th June 09
	   --l_dataHeader := l_dataHeader||'XMLElement("'||upper(p_bind_tbl(j).Key_name)||'",'''||l_bind_val||''')||';
	   l_dataHeader := l_dataHeader||'XMLElement("'||upper(p_bind_tbl(j).Key_name)||'",'''||l_bind_val||''').getclobval()||';
	   --End bug 8627647 gnramasa 30th June 09
        END IF;

        -- start for bug 9463265 PNAVEENK
	IF UPPER(l_bind_type) = 'DATE' THEN
	   l_bind_val := '''' || l_bind_val || '''';
	END if;
	-- end for bug 9463265
        --End Bug#6743267 24-Jul-2008 barathsr
        WHILE (l_bind_found > 0)
        LOOP
           EXIT when l_bind_found = 0;
           --
           l_cnt := l_cnt + 1;
           l_new_query := replace (l_new_query, l_bind_name, l_bind_val);
           l_bind_found := instr( l_new_query, l_bind_name);
        END LOOP;

        WriteLog('GetXmlData: replace bind_name = '||l_bind_name || ' with val=' || l_bind_val ||'; cnt=' || l_cnt);
        l_var_count_rec.var_count := l_cnt;
        l_var_count_tbl(j) := l_var_count_rec;

     end loop;

     --Begin Bug#6743267 24-Jul-2008 barathsr
     l_dataHeader := substr(l_dataHeader,0,length(l_dataHeader)-2);
     --End Bug#6743267 24-Jul-2008 barathsr

    /* begin bug 4732366 - ctlee - use set bind variables  11/28/2005 */
    --  resource_id is added to the l_bind_tbl
     -- and replace :resource_id
     l_cnt := 0;
     l_bind_found := instr( l_new_query, ':RESOURCE_ID');
     WHILE (l_bind_found > 0)
     LOOP
        EXIT when l_bind_found = 0;
        --
        l_cnt := l_cnt + 1;
        l_new_query := replace (l_new_query, ':RESOURCE_ID', p_resource_id);
        l_bind_found := instr( l_new_query, ':RESOURCE_ID');
     END LOOP;
     WriteLog('GetXmlData: resource_id : l_cnt = '||l_cnt || ' with ' || p_resource_id);
     WriteLog('GetXmlData: after replace');

    /* end bug 4732366 - ctlee - use set bind variables  11/28/2005 */

    /* begin bug 4732366 - ctlee - use set bind variables  12/28/2005 */
    --  using bind variable, no check here
     -- if the replaced query still has ':', cannot execute query;
     l_found := instr(l_new_query, ':');
     if (l_found > 0) then
         WriteLog('GetXmlData: l_found=' || l_found);
         WriteLog('GetXmlData: var='||substr(l_new_query, l_found, 3));
         -- cannot execute the query; the bind variables are not enough;
         WriteLog('GetXmlData: bind var and query are not matched');
         --FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
         --FND_MESSAGE.Set_Token ('INFO', 'Bind Variables are not enough for query_id: ' || p_query_id);
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_BINDVAR');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     end if;
     WriteLog('GetXmlData: bind var and query are matched');

     WriteLog('GetXmlData: end to chk the bind var and query');
     -- end to check the query and bind var are matched or not;


    /* end bug 4732366 - ctlee - use set bind variables  11/28/2005 */

     WriteLog('GetXmlData: l_new_query=' || l_new_query);
     len := length(l_new_query)/100;
     WriteLog('GetXmlData: l_new_query len=' || len);
     /**
     for i in 1..len loop
         l_start := 100 * (i-1) + 1;
         l_end := 100 * i;
         sMsg := substr(l_new_query, l_start, l_end);
         dbms_output.put_line(sMsg);
     end loop;
     **/

    /* begin bug 4732366 - ctlee - use set bind variables  12/28/2005 */
    -- no check of the query
     -- execute the query to see if any records returned.
     BEGIN
         WriteLog('GetXmlData: execute query');
         v_cursor := DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.parse( v_cursor, l_new_query, 1);
         v_numrows := DBMS_SQL.EXECUTE( v_cursor);
         v_numrows := DBMS_SQL.FETCH_ROWS( v_cursor);
         DBMS_SQL.CLOSE_CURSOR( v_cursor);
     EXCEPTION
       when others then
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_CANT_EXEC_QRY');
         FND_MESSAGE.Set_Token ('ID', p_query_id);
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     END;
     if (v_numrows > 0 ) then
        WriteLog('GetXmlData: execute query, numrows > 0');
     else
         WriteLog('GetXmlData: execute query, no rows');
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_DATA');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     end if;

    /* end bug 4732366 - ctlee - use set bind variables  11/28/2005 */

     WriteLog('GetXmlData: calling DBMS_XMLQuery api');
     --qryCtx := DBMS_XMLQuery.newContext(l_query);
     qryCtx := DBMS_XMLQuery.newContext(l_new_query);

     DBMS_XMLQuery.setRowTag(qryCtx, 'COLLECTION');
     -- set the rowset header to null
     DBMS_XMLQuery.setRowSetTag(qryCtx, 'COLLECTIONSET');

     --Begin Bug#6743267 24-Jul-2008 barathsr
     l_rowSetName := '<COLLECTIONSET>';
     --End Bug#6743267 24-Jul-2008 barathsr

/***
     --Set bind values
     --DBMS_XMLQuery.setBindValue(qryCtx, 'PARTY_ID', p_party_id);
     WriteLog('GetXmlData: set bind values');
     l_bind_cnt := l_bind_tbl.count;
     l_cnt := 0;
     WriteLog('GetXmlData: l_bind_cnt = '||l_bind_cnt);
     for j in 1..l_bind_cnt
     loop
        l_cnt := 0;
        l_bind_name := ':' || upper(p_bind_tbl(j).Key_name);
        l_bind_type := p_bind_tbl(j).Key_Type;
        l_bind_val  := p_bind_tbl(j).Key_Value;
        -- chk how many bind var in the query
        l_bind_found := instr( l_query, l_bind_name);
        WHILE (l_bind_found > 0)
        LOOP
           EXIT when l_bind_found = 0;
           --
           l_cnt := l_cnt + 1;
           DBMS_XMLQuery.setBindValue(qryCtx, l_bind_name, l_bind_val);
           l_bind_found := instr( l_query, l_bind_name);
        END LOOP;
        WriteLog('GetXmlData: set bind_name = '||l_bind_name || ' with val=' || l_bind_val ||'; cnt=' || l_cnt);
     end loop;

     l_cnt := 0;
     l_bind_found := instr( l_query, ':RESOURCE_ID');
     WHILE (l_bind_found > 0)
     LOOP
        EXIT when l_bind_found = 0;
        --
        l_cnt := l_cnt + 1;
        DBMS_XMLQuery.setBindValue(qryCtx, 'RESOURCE_ID', p_resource_id);
        l_bind_found := instr( l_query, ':RESOURCE_ID');
     END LOOP;
     WriteLog('GetXmlData: resource_id : l_cnt = '||l_cnt);
   ***/

    /* begin bug 4732366 - ctlee - use set bind variables  12/28/2005 */
    /* WriteLog('GetXmlData: set bind values');
     l_bind_cnt := p_bind_tbl.count;
     --l_cnt := 0;
     WriteLog('GetXmlData: l_bind_cnt = '||l_bind_cnt);
     for j in 1..l_bind_cnt
     loop
        --l_cnt := 0;
        l_bind_name := upper(p_bind_tbl(j).Key_name);
        l_bind_type := p_bind_tbl(j).Key_Type;
        l_bind_val  := p_bind_tbl(j).Key_Value;
        -- l_bind_count := l_var_count_tbl(j).var_count;
        -- chk how many bind var in the query
        -- l_bind_found := instr( l_query, l_bind_name);
        -- WHILE (l_bind_found > 0)
        WHILE (l_bind_count > 0)
        LOOP
           EXIT when l_bind_count = 0;
           --
           --l_cnt := l_cnt + 1;
           DBMS_XMLQuery.setBindValue(qryCtx, l_bind_name||l_bind_count, l_bind_val);
           WriteLog('GetXmlData: set bind_name = '||l_bind_name || l_bind_count || ' with val=' || l_bind_val );
           -- l_bind_found := instr( l_query, l_bind_name);
           l_bind_count := l_bind_count - 1;

        END LOOP;

     end loop; */

    /* end bug 4732366 - ctlee - use set bind variables  11/28/2005 */


    --Begin Bug#6743267 24-Jul-2008 barathsr
     -- Create the XML DataHeader
     l_dataHdrQry := 'SELECT '||l_dataHeader||'  FROM DUAL';

     OPEN  xml_element FOR l_dataHdrQry;
     FETCH xml_element INTO l_dataHdr_clob;
     CLOSE xml_element;

     WriteLog('The XML DataHeader is '||l_dataHdr_clob);
     --End Bug#6743267 24-Jul-2008 barathsr

     -- now get the result
     WriteLog('GetXmlData: getXml');
     result := DBMS_XMLQuery.getXml(qryCtx);
     WriteLog('GetXmlData: get result');
     --Begin Bug#6743267 24-Jul-2008 barathsr
     --  RowSet and Row
     result := replace(result,l_rowSetName,l_rowSetName||''||l_dataHdr_clob);
     --End Bug#6743267 24-Jul-2008 barathsr
     x_xml := result;

    if (result is null) then
         WriteLog('GetXmlData: no result');
         --FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
         --FND_MESSAGE.Set_Token ('INFO', 'No XML result');
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_DATA');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    end if;

    --close context
    WriteLog('GetXmlData: close context ');
    DBMS_XMLQuery.closeContext(qryCtx);


    WriteLog('GetXmlData: end GetXmlData()');

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         WriteLog('GetXmlData: Exc_Error:'|| SQLERRM);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         WriteLog('GetXmlData: Exc_Error:'|| SQLERRM);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data);
    when others then
         WriteLog('GetXmlData: Exc_Error:'|| SQLERRM);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data);
End GetXmlData;



/*
   Overview: This function is to retrieve the existing xml data from
             iex_xml_request_histories table by the xml_request_id.
 */
function getCurrDeliveryMethod return varchar2
IS
    CURSOR C_GET_SETUP  IS
      SELECT NVL(PREFERENCE_VALUE, 'FFM')
        FROM IEX_APP_PREFERENCES_VL
       WHERE PREFERENCE_NAME= 'COLLECTIONS DELIVERY METHOD';

    l_dmethod          VARCHAR2(10);

BEGIN

     WriteLog('begin getCurrDeliveryMethod()');

     OPEN C_GET_SETUP;
     FETCH C_GET_SETUP INTO l_dmethod;

     IF (C_GET_SETUP%NOTFOUND) THEN
       l_dmethod := '';
     END IF;
     CLOSE C_GET_SETUP;

     WriteLog('get Delivery Method');
     return l_dmethod;

END getCurrDeliveryMethod;



Procedure WriteLog      (  p_msg                     IN VARCHAR2)
IS
BEGIN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage (p_msg);
     END IF;

     --dbms_output.put_line(p_msg);

END WriteLog;




BEGIN
  PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_SEND_XML_PVT;

/
