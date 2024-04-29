--------------------------------------------------------
--  DDL for Package INV_XML_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_XML_REPORTS" AUTHID CURRENT_USER AS
/* $Header: INVXREPS.pls 120.1 2005/10/05 09:35:49 ragsriva noship $ */
   PROCEDURE lot_inventory_report (
      errbuf              OUT NOCOPY      VARCHAR2
    , retcode             OUT NOCOPY      VARCHAR2
    , p_organization_id   IN              NUMBER
    , p_from_item         IN              VARCHAR2
    , p_to_item           IN              VARCHAR2
    , p_from_subinv       IN              VARCHAR2
    , p_to_subinv         IN              VARCHAR2);

   PROCEDURE lot_master_report (
      errbuf              OUT NOCOPY      VARCHAR2
    , retcode             OUT NOCOPY      VARCHAR2
    , p_organization_id   IN              NUMBER
    , p_from_item         IN              VARCHAR2
    , p_to_item           IN              VARCHAR2);

   PROCEDURE mat_status_def_report (
      errbuf          OUT NOCOPY      VARCHAR2
    , retcode         OUT NOCOPY      VARCHAR2
    , p_from_status   IN              VARCHAR2
    , p_to_status     IN              VARCHAR2
    , p_sort_order    IN              NUMBER);

   PROCEDURE grade_change_history_report (
      errbuf              OUT NOCOPY      VARCHAR2
    , retcode             OUT NOCOPY      VARCHAR2
    , p_organization_id   IN              NUMBER
    , p_item_id           IN              NUMBER
    , p_from_lot          IN              VARCHAR2
    , p_to_lot            IN              VARCHAR2
    , p_from_date         IN              VARCHAR2
    , p_to_date           IN              VARCHAR2);

   PROCEDURE xml_transfer (
      p_xml_clob   IN   CLOB);
END inv_xml_reports;

 

/
