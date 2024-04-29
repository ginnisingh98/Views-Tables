--------------------------------------------------------
--  DDL for Package OE_BULK_ORDER_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_ORDER_IMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEBVIMNS.pls 120.1.12010000.4 2008/11/26 01:35:51 smusanna ship $ */


G_BOOKED_ORDERS           NUMBER := 0;
G_ENTERED_ORDERS          NUMBER := 0;
G_ERROR_ORDERS            NUMBER := 0;
G_RTRIM_IFACE_DATA        VARCHAR2(1) := 'N';
G_ORG_ID                  NUMBER;

PROCEDURE ORDER_IMPORT_CONC_PGM(
   errbuf                               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,retcode                              OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,p_operating_unit                     IN  NUMBER
  ,p_order_source_id                    IN  NUMBER
  ,p_orig_sys_document_ref              IN  VARCHAR2
  ,p_validate_only                      IN  VARCHAR2 DEFAULT 'N'
  ,p_validate_desc_flex                 IN  VARCHAR2 DEFAULT 'Y'
  ,p_defaulting_mode                    IN  VARCHAR2 DEFAULT 'N'
  ,p_debug_level                        IN  NUMBER DEFAULT NULL
  ,p_num_instances                      IN  NUMBER DEFAULT 1
  ,p_batch_size                         IN  NUMBER DEFAULT 10000
  ,p_rtrim_data                         IN  VARCHAR2 DEFAULT 'N'
  ,p_process_recs_with_no_org           IN  VARCHAR2 DEFAULT 'Y'
  ,p_process_tax                        IN  VARCHAR2 DEFAULT 'N'
 , p_process_configurations             IN  VARCHAR2 DEFAULT 'N'
 , p_dummy                              IN  VARCHAR2 DEFAULT NULL
 , p_validate_configurations            IN  VARCHAR2 DEFAULT 'Y'
 , p_schedule_configurations            IN  VARCHAR2 DEFAULT 'N'
  );


END OE_BULK_ORDER_IMPORT_PVT;

/
