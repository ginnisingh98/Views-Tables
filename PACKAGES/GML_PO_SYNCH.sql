--------------------------------------------------------
--  DDL for Package GML_PO_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_SYNCH" AUTHID CURRENT_USER AS
/* $Header: GMLPOSYS.pls 115.4 2002/12/04 19:11:39 gmangari ship $ */

   PROCEDURE cpg_conv_duom
      (v_item_id                IN  NUMBER,
       v_um1                    IN  VARCHAR2,
       v_order1                 IN  NUMBER,
       v_um2                    IN  VARCHAR2,
       v_order2                 OUT NOCOPY NUMBER);

  PROCEDURE cpg_int2gms( retcode      OUT NOCOPY NUMBER);

  PROCEDURE next_line_id(line_type   IN  VARCHAR2,
			 new_line_id OUT NOCOPY PO_ORDR_DTL.LINE_ID%TYPE,
			 v_next_id_status OUT NOCOPY BOOLEAN);

  FUNCTION gemms_validate
   (v_orgn_code              IN    VARCHAR2,
    v_of_payvend_site_id     IN    NUMBER,
    v_of_shipvend_site_id    IN    NUMBER,
    v_to_whse                IN    VARCHAR2,
    v_billing_currency       IN    VARCHAR2,
    v_item_no                IN    VARCHAR2,
    v_order_um1              IN    VARCHAR2,
    v_price_um               IN    VARCHAR2,
    v_order_um2              IN    VARCHAR2,
    v_item_um                IN    VARCHAR2,
    v_buyer_code             IN    VARCHAR2,
    v_from_whse              IN    VARCHAR2,
    v_shipper_code           IN    VARCHAR2,
    v_of_frtbill_mthd        IN    VARCHAR2,
    v_of_terms_code          IN    VARCHAR2,
    v_qc_grade_wanted        IN    VARCHAR2,
    v_po_no                  IN    VARCHAR2,
    v_line_id                IN    NUMBER,
    v_line_location_id       IN    NUMBER,
    v_revision_count         IN    NUMBER,
    v_last_update_date       IN    DATE)  RETURN BOOLEAN;

END GML_PO_SYNCH;

 

/
