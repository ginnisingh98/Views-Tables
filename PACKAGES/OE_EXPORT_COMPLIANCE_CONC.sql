--------------------------------------------------------
--  DDL for Package OE_EXPORT_COMPLIANCE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_EXPORT_COMPLIANCE_CONC" AUTHID CURRENT_USER AS
/* $Header: OEXCITMS.pls 120.1.12000000.1 2007/01/16 21:47:46 appldev ship $ */


FUNCTION Screening_Eligible(
                           p_line_id NUMBER
                           ) RETURN BOOLEAN;


PROCEDURE Screening  (
                      ERRBUF                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                     ,RETCODE                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
		      /* Moac */
                     ,p_org_id		     IN   NUMBER
                     ,p_order_num_low        IN   NUMBER
                     ,p_order_num_high       IN   NUMBER
                     ,p_customer             IN   NUMBER
                     ,p_customer_po_num      IN   VARCHAR2
                     ,p_order_type           IN   NUMBER
                     ,p_warehouse            IN   NUMBER
                     ,p_ship_to_location     IN   NUMBER
                     ,p_inventory_item_id    IN   NUMBER
                     ,p_schedule_date_low    IN   VARCHAR2
                     ,p_schedule_date_high   IN   VARCHAR2
                     ,p_ordered_date_low     IN   VARCHAR2
                     ,p_ordered_date_high    IN   VARCHAR2
                     );

END OE_EXPORT_COMPLIANCE_CONC;

 

/
