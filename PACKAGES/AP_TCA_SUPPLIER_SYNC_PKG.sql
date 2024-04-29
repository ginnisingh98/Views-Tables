--------------------------------------------------------
--  DDL for Package AP_TCA_SUPPLIER_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_TCA_SUPPLIER_SYNC_PKG" AUTHID CURRENT_USER AS
/* $Header: aptcasys.pls 120.0.12010000.3 2009/08/12 21:13:04 dcshanmu ship $ */

  -- Procedure Sync Supplier
  PROCEDURE SYNC_Supplier
            (x_return_status    OUT     NOCOPY VARCHAR2,
             x_msg_count        OUT     NOCOPY NUMBER,
             x_msg_data         OUT     NOCOPY VARCHAR2,
             x_party_id         IN             NUMBER);

  -- Procedure Sync Supplier Site
  PROCEDURE SYNC_Supplier_Sites
            (x_return_status    OUT     NOCOPY VARCHAR2,
             x_msg_count        OUT     NOCOPY NUMBER,
             x_msg_data         OUT     NOCOPY VARCHAR2,
             x_location_id      IN             NUMBER,
             x_party_site_id    IN             NUMBER,
	     x_vendor_site_id	IN	NUMBER DEFAULT NULL); -- bug 8723400

END AP_TCA_SUPPLIER_SYNC_PKG;

/
