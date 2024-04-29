--------------------------------------------------------
--  DDL for Package GR_XML_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_XML_REPORTS" AUTHID CURRENT_USER AS
/* $Header: GRXREPS.pls 120.0 2005/10/03 07:35:32 ragsriva noship $ */
   PROCEDURE dispatch_history_report (
      errbuf                     OUT NOCOPY      VARCHAR2
    , retcode                    OUT NOCOPY      VARCHAR2
    , p_organization_id          IN              NUMBER
    , p_from_item                IN              VARCHAR2
    , p_to_item                  IN              VARCHAR2
    , p_from_recipient           IN              VARCHAR2
    , p_to_recipient             IN              VARCHAR2
    , p_from_document_category   IN              VARCHAR2
    , p_to_document_category     IN              VARCHAR2
    , p_from_date_sent           IN              VARCHAR2
    , p_to_date_sent             IN              VARCHAR2
    , p_cas_number               IN              VARCHAR2
    , p_ingredient_item_id       IN              NUMBER
    , p_order_by                 IN              VARCHAR2);


   PROCEDURE xml_transfer (
      p_xml_clob   IN   CLOB);
END GR_XML_REPORTS;

 

/
