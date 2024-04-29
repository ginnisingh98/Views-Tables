--------------------------------------------------------
--  DDL for Package WMS_EPC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_EPC_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSEPCVS.pls 120.6.12010000.2 2012/07/20 20:42:36 sahmahes ship $ */

-- R12
G_PROFILE_GTIN       VARCHAR2(100) := NULL;

/* NOT USED. Coded in R12 but not used
  type  l_num_tbl is table of number index by binary_integer;
  g_EPC_ORG_id l_num_tbl;
*/

  TYPE epc_rule_types IS RECORD
    (
     type_id         NUMBER,
     type_name       VARCHAR2(100),
     partition_value NUMBER,
     category_id     NUMBER
     );


  TYPE epc_rule_types_tbl IS TABLE OF epc_rule_types INDEX BY BINARY_INTEGER;



  --constants TO IDENTIFY OBJECT TYPE

  WMS_EPC_OTHER_OBJ_TYPE          CONSTANT NUMBER := 0;
  WMS_EPC_ITEM_OBJ_TYPE           CONSTANT NUMBER := 1;
  WMS_EPC_INNER_PACK_OBJ_TYPE     CONSTANT NUMBER := 2;
  WMS_EPC_CASE_OBJ_TYPE           CONSTANT NUMBER := 3;
  WMS_EPC_PALLET_OBJ_TYPE         CONSTANT NUMBER := 4;
  WMS_EPC_OTH5_OBJ_TYPE           CONSTANT NUMBER := 5;
  WMS_EPC_OTH6_OBJ_TYPE           CONSTANT NUMBER := 6;
  WMS_EPC_OTH7_OBJ_TYPE           CONSTANT NUMBER := 7;


  PROCEDURE  generate_epc
    (p_org_id          IN NUMBER,
     p_label_type_id   IN NUMBER, /* VALID VALUES 1,2,3,4,5*/
     p_group_id	     IN	NUMBER,
     p_label_format_id IN NUMBER,
     p_item_id          IN NUMBER   DEFAULT NULL, --For Material Label: 1
     p_txn_qty          IN NUMBER   DEFAULT null, --For Material Label: 1
     p_txn_uom          IN VARCHAR2 DEFAULT NULL, --For Material Label: 1
     p_label_request_id IN NUMBER,
     p_business_flow_code IN NUMBER DEFAULT NULL,
     x_epc             OUT nocopy VARCHAR2,
     x_return_status   OUT nocopy VARCHAR2,
     x_return_mesg     OUT nocopy VARCHAR2
     );


   --To be called from rcv_transaction_processor/3rd party to populate from inerface tables
    PROCEDURE populate_outside_epc
    (p_group_id IN NUMBER ,      --obtained from WMS_EPC_S2.nextval by calling API
     p_cross_ref_type IN NUMBER, --1: LPN-EPC , 2: ITEM_SERIAL-EPC , 3: GTIN-EPC
     p_Lpn_id         IN NUMBER DEFAULT NULL, --for p_cross_ref_type =1 only
     p_ITEM_ID        IN NUMBER DEFAULT NULL, --for p_cross_ref_type = 2 only
     p_SERIAL_NUMBER  VARCHAR2  DEFAULT NULL, --for p_cross_ref_type = 2 only
     p_GTIN           IN NUMBER DEFAULT NULL, --for p_cross_ref_type = 3 , for future
     p_GTIN_SERIAL    IN NUMBER DEFAULT NULL, --for p_cross_ref_type = 3 , for future
     p_EPC            IN VARCHAR2,
     x_return_status  OUT nocopy VARCHAR2,
     x_return_mesg    OUT nocopy VARCHAR2
     );

  FUNCTION db_version RETURN NUMBER;--BUG8796558
  FUNCTION is_lpn_standard(p_lpn_id NUMBER) RETURN NUMBER;


  FUNCTION bin2dec (binval in char) RETURN NUMBER;
  FUNCTION dec2bin (N in number) RETURN VARCHAR2;
  FUNCTION oct2dec (octval in char) RETURN NUMBER;
  FUNCTION dec2oct (N in number) RETURN VARCHAR2;
  FUNCTION hex2dec (hexval in char) RETURN NUMBER;
  FUNCTION dec2hex (N in number) RETURN VARCHAR2;


END wms_epc_pvt;

/
