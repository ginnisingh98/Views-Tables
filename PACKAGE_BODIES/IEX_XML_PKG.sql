--------------------------------------------------------
--  DDL for Package Body IEX_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_XML_PKG" AS
/* $Header: iextxmlb.pls 120.0.12010000.8 2009/12/29 13:05:42 pnaveenk ship $ */

     PG_DEBUG NUMBER(2) ;

PROCEDURE insert_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_xml_request_id                 IN OUT NOCOPY NUMBER
        , p_query_temp_id                    NUMBER
        , p_status                           VARCHAR2
        , p_document                         BLOB
	, p_html_document                    BLOB
        , p_xmldata                          CLOB
        , p_method                           VARCHAR2
        , p_destination                      VARCHAR2
	, p_subject                          VARCHAR2
        , p_object_type                      VARCHAR2
        , p_object_id                        NUMBER
        , p_resource_id                      NUMBER
        , p_view_by                          VARCHAR2
        , p_party_id                         NUMBER
        , p_cust_account_id                  NUMBER
        , p_cust_site_use_id                 NUMBER
        , p_delinquency_id                   NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_object_version_number            NUMBER
	, p_request_id			     NUMBER
	, p_worker_id                        NUMBER
	, p_confirmation_mode		     VARCHAR2  -- added by gnramasa for bug 8489610 14-May-09
	, p_conc_request_id		     NUMBER    -- added by gnramasa for bug 8489610 14-May-09
	, p_org_id                           number   -- added for bug 9151851
	, p_template_language                VARCHAR2  -- added by gnramasa for bug 8489610 28-May-09
	, p_template_territory               VARCHAR2  -- added by gnramasa for bug 8489610 28-May-09
     ) IS

        CURSOR get_rowid IS
          SELECT ROWID
            FROM iex_xml_request_histories
           WHERE xml_request_id = px_xml_request_id;
        --
        CURSOR get_seq_csr is
          SELECT IEX_XML_REQUEST_HISTORIES_s.nextval
            FROM sys.dual;

     BEGIN
     --
        If (px_xml_request_id IS NULL) OR (px_xml_request_id = FND_API.G_MISS_NUM) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO px_xml_request_id;
            CLOSE get_seq_csr;
        End If;
        --dbms_output.put_line('id=' || px_xml_request_id);
        --dbms_output.put_line('insert');
        --
	--Start adding for bug 8489610 by gnramasa 14-May-09
         WriteLog( ' in xml_pkg org_id ' || p_org_id);
        INSERT INTO IEX_XML_REQUEST_HISTORIES (
          XML_REQUEST_ID
        , QUERY_TEMP_ID
        , STATUS
        , DOCUMENT
	, HTML_DOCUMENT
        , XMLDATA
        , METHOD
        , DESTINATION
	, SUBJECT
        , OBJECT_TYPE
        , OBJECT_ID
        , RESOURCE_ID
        , VIEW_BY
        , PARTY_ID
        , CUST_ACCOUNT_ID
        , CUST_SITE_USE_ID
        , DELINQUENCY_ID
        , last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        , object_version_number
	, request_id
	, worker_id
	, confirmation_mode
	, conc_request_id
	, language
	, territory
	, org_id -- added for bug 9151851

        ) VALUES (
          px_xml_request_id
        , p_query_temp_id
        , p_status
        , p_document
	, p_html_document
        , p_xmldata
        , p_method
        , p_destination
	, p_subject
        , p_object_type
        , p_object_id
        , p_resource_id
        , p_view_by
        , p_party_id
        , p_cust_account_id
        , p_cust_site_use_id
        , p_delinquency_id
        , p_last_update_date
        , p_last_updated_by
        , p_creation_date
        , p_created_by
        , p_last_update_login
        , p_object_version_number
	, p_request_id
	, p_worker_id
	, p_confirmation_mode
	, p_conc_request_id
	, p_template_language
	, p_template_territory
        , p_org_id   -- added for bug 9151851
        );

        OPEN get_rowid;
        FETCH get_rowid INTO px_rowid;
        IF (get_rowid%NOTFOUND) THEN
            CLOSE get_rowid;
            RAISE NO_DATA_FOUND;
        END IF;

     EXCEPTION
        WHEN OTHERS THEN
           --dbms_output.put_line('error' || SQLERRM);
           WriteLog('iextxmlb.pls:insert_row:Exception errmsg='||SQLERRM);
     END insert_row;



     PROCEDURE delete_row(
        p_xml_request_id                   NUMBER
     ) IS
     BEGIN
        DELETE FROM iex_xml_request_histories
        WHERE xml_request_id = p_xml_request_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;

     EXCEPTION
        WHEN OTHERS THEN
           --dbms_output.put_line('error' || SQLERRM);
           WriteLog('iextxmlb.pls:delete_row:Exception errmsg='||SQLERRM);
     END delete_row;


PROCEDURE UPDATE_ROW (
          p_xml_request_id                   NUMBER
        , p_query_temp_id                    NUMBER
        , p_status                           VARCHAR2
        , p_document                         BLOB
	, p_html_document                    BLOB
        , p_xmldata                          CLOB
        , p_method                           VARCHAR2
        , p_destination                      VARCHAR2
	, p_subject                          VARCHAR2
        , p_object_type                      VARCHAR2
        , p_object_id                        NUMBER
        , p_resource_id                      NUMBER
        , p_view_by                          VARCHAR2
        , p_party_id                         NUMBER
        , p_cust_account_id                  NUMBER
        , p_cust_site_use_id                 NUMBER
        , p_delinquency_id                   NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_object_version_number            NUMBER
	, p_request_id			     NUMBER
	, p_worker_id                        NUMBER
	, p_confirmation_mode		     VARCHAR2  -- added by gnramasa for bug 8489610 14-May-09
	, p_conc_request_id		     NUMBER    -- added by gnramasa for bug 8489610 14-May-09
	, p_template_language                VARCHAR2  -- added by gnramasa for bug 8489610 28-May-09
	, p_template_territory               VARCHAR2  -- added by gnramasa for bug 8489610 28-May-09
     )
     IS
       cursor c_get_rec (in_request_id number) is
         select rowid,
                xml_request_id,
                query_temp_id,
                status,
                document,
		html_document,
                xmldata,
                object_type,
                object_id,
                resource_id,
                method,
                destination,
		subject,
                view_by,
                party_id,
                cust_account_id,
                cust_site_use_id,
                delinquency_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                object_version_number,
		request_id,
		worker_id,
		confirmation_mode,
		conc_request_id,
		language,
		territory
           from iex_xml_request_histories
          where xml_request_id = in_request_id
          for update nowait;
      --
      l_xml_request_id                   NUMBER;
      l_query_temp_id                    NUMBER;
      l_status                           VARCHAR2(40);
      l_document                         BLOB;
      l_html_document                    BLOB;
      l_xmldata                          CLOB;
      l_method                           VARCHAR2(10);
      l_destination                      VARCHAR2(2000);
      l_subject                          VARCHAR2(4000);
      l_object_type                      VARCHAR2(100);
      l_object_id                        NUMBER;
      l_resource_id                      NUMBER;
      --Start for bug 8791904 gnramasa 29th Aug 09
      --l_view_by                          VARCHAR2(10);
      l_view_by                          VARCHAR2(20);
      --End for bug 8791904 gnramasa 29th Aug 09
      l_party_id                         NUMBER;
      l_cust_account_id                  NUMBER;
      l_cust_site_use_id                 NUMBER;
      l_delinquency_id                   NUMBER;
      l_last_update_date                 DATE;
      l_last_updated_by                  NUMBER;
      l_creation_date                    DATE;
      l_created_by                       NUMBER;
      l_last_update_login                NUMBER;
      l_object_version_number            NUMBER;
      l_request_id NUMBER;
      l_worker_id NUMBER;
      l_rowid                            varchar2(2000);
      l_confirmation_mode		 varchar2(10);
      l_conc_request_id			 number;
      l_language                         varchar2(10);
      l_territory                        varchar2(10);

     BEGIN

        open c_get_rec (p_xml_request_id);
        fetch c_get_rec into
                l_rowid,
                l_xml_request_id,
                l_query_temp_id,
                l_status,
                l_document,
		l_html_document,
                l_xmldata,
                l_object_type,
                l_object_id,
                l_resource_id,
                l_method,
                l_destination,
		l_subject,
                l_view_by,
                l_party_id,
                l_cust_account_id,
                l_cust_site_use_id,
                l_delinquency_id,
                l_creation_date,
                l_created_by,
                l_last_update_date,
                l_last_updated_by,
                l_last_update_login,
                l_object_version_number,
		l_request_id,
		l_worker_id,
		l_confirmation_mode,
		l_conc_request_id,
		l_language,
		l_territory;
        CLOSE c_get_rec;

        if (p_status is not null ) then
            l_status := p_status;
        end if;
        if (p_document is not null ) then
            l_document := p_document;
        end if;
	if (p_html_document is not null ) then
            l_html_document := p_html_document;
        end if;
        if (p_xmldata is not null ) then
            l_xmldata := p_xmldata;
        end if;
        if (p_method is not null ) then
            l_method := p_method;
        end if;
        if (p_destination is not null ) then
            l_destination := p_destination;
        end if;
	if (p_subject is not null) then
	    l_subject := p_subject;
	end if;
        if (p_resource_id is not null ) then
            l_resource_id := p_resource_id;
        end if;
        if (p_last_update_date is not null ) then
            l_last_update_date := p_last_update_date;
        end if;
        if (p_last_updated_by is not null ) then
            l_last_updated_by := p_last_updated_by;
        end if;
	if (p_request_id is not null ) then
            l_request_id := p_request_id;
        end if;
	if (p_worker_id is not null ) then
            l_worker_id := p_worker_id;
        end if;
	if (p_confirmation_mode is not null ) then
            l_confirmation_mode := p_confirmation_mode;
        end if;
	if (p_conc_request_id is not null ) then
            l_conc_request_id := p_conc_request_id;
        end if;
	if (p_template_language is not null ) then
            l_language := p_template_language;
        end if;
	if (p_template_territory is not null ) then
            l_territory := p_template_territory;
        end if;

        UPDATE iex_xml_request_histories
        SET
          query_temp_id     = l_query_temp_id
        , status            = l_status
        , document          = l_document
	, html_document     = l_html_document
        , xmldata           = l_xmldata
        , method            = l_method
        , destination       = l_destination
	, subject           = l_subject
        , object_type       = l_object_type
        , object_id         = l_object_id
        , resource_id       = l_resource_id
        , view_by           = l_view_by
        , party_id          = l_party_id
        , cust_account_id   = l_cust_account_id
        , cust_site_use_id  = l_cust_site_use_id
        , delinquency_id    = l_delinquency_id
        , last_update_date  = l_last_update_date
        , last_updated_by   = l_last_updated_by
        , last_update_login = l_last_update_login
        , creation_date     = l_creation_date
        , created_by        = l_created_by
        , object_version_number  = l_object_version_number
	, request_id = l_request_id
	, worker_id = l_worker_id
	, confirmation_mode = l_confirmation_mode
	, conc_request_id = l_conc_request_id
	, language        = l_language
	, territory       = l_territory
        WHERE xml_request_id  =  p_xml_request_id;

        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
	--End adding for bug 8489610 by gnramasa 14-May-09

     EXCEPTION
        WHEN OTHERS THEN
           --dbms_output.put_line('error' || SQLERRM);
           WriteLog('iextxmlb.pls:update_row:Exception errmsg='||SQLERRM);

     END update_row;



     Procedure WriteLog      (  p_msg                     IN VARCHAR2)
     IS
     BEGIN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.LogMessage (p_msg);
         END IF;

         --dbms_output.put_line(p_msg);

     END WriteLog;


BEGIN
     PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));


END iex_xml_pkg;

/
