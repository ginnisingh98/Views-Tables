--------------------------------------------------------
--  DDL for Package IEX_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_XML_PKG" AUTHID CURRENT_USER AS
/* $Header: iextxmls.pls 120.0.12010000.6 2009/12/29 13:08:11 pnaveenk ship $ */

     PROCEDURE insert_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_xml_request_id                 IN OUT NOCOPY NUMBER
        , p_query_temp_id                    NUMBER
        , p_status                           VARCHAR2
        , p_document                         BLOB
	, p_html_document                         BLOB
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
     );

     PROCEDURE delete_row(
        p_xml_request_id                     NUMBER
     );


     PROCEDURE update_row(
          p_xml_request_id                   NUMBER
        , p_query_temp_id                    NUMBER default null
        , p_status                           VARCHAR2 default null
        , p_document                         BLOB default null
	, p_html_document                    BLOB default null
        , p_xmldata                          CLOB default null
        , p_method                           VARCHAR2 default null
        , p_destination                      VARCHAR2 default null
	, p_subject                          VARCHAR2 default null
        , p_object_type                      VARCHAR2 default null
        , p_object_id                        NUMBER default null
        , p_resource_id                      NUMBER default null
        , p_view_by                          VARCHAR2 default null
        , p_party_id                         NUMBER default null
        , p_cust_account_id                  NUMBER default null
        , p_cust_site_use_id                 NUMBER default null
        , p_delinquency_id                   NUMBER default null
        , p_last_update_date                 DATE default null
        , p_last_updated_by                  NUMBER default null
        , p_creation_date                    DATE default null
        , p_created_by                       NUMBER default null
        , p_last_update_login                NUMBER default null
        , p_object_version_number            NUMBER default null
	, p_request_id			     NUMBER default null
	, p_worker_id                        NUMBER default null
	, p_confirmation_mode		     VARCHAR2 default null  -- added by gnramasa for bug 8489610 14-May-09
	, p_conc_request_id		     NUMBER default null    -- added by gnramasa for bug 8489610 14-May-09
	, p_template_language                VARCHAR2 default null  -- added by gnramasa for bug 8489610 28-May-09
	, p_template_territory               VARCHAR2 default null  -- added by gnramasa for bug 8489610 28-May-09
     );


     Procedure WriteLog      (  p_msg             IN VARCHAR2);



END iex_xml_pkg;

/
