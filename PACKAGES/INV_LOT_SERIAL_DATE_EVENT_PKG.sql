--------------------------------------------------------
--  DDL for Package INV_LOT_SERIAL_DATE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_SERIAL_DATE_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: INVLSEVS.pls 120.0 2005/08/12 06:58:50 nsinghi noship $ */

PROCEDURE lot_serial_date_notify_cp (
   x_errbuf                   OUT NOCOPY     VARCHAR2
 , x_retcode                  OUT NOCOPY     NUMBER
 , p_organization_id          IN       NUMBER
 , p_structure_id             IN       NUMBER
 , p_category_id              IN       NUMBER
 , p_from_item                IN       VARCHAR2
 , p_to_item                  IN       VARCHAR2
 , p_query_for                IN       VARCHAR2
 , p_from_lot                 IN       VARCHAR2
 , p_to_lot                   IN       VARCHAR2
 , p_from_serial              IN       VARCHAR2
 , p_to_serial                IN       VARCHAR2
 , p_attr_context             IN       VARCHAR2
 , p_date_type                IN       VARCHAR2
 , p_days_in_future           IN       NUMBER
 , p_days_in_past             IN       NUMBER
 , p_include_zero_balance     IN       NUMBER
) ;

END INV_LOT_SERIAL_DATE_EVENT_PKG;

 

/
