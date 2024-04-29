--------------------------------------------------------
--  DDL for Package CSP_REPAIR_PO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REPAIR_PO_GRP" AUTHID CURRENT_USER AS
/* $Header: cspgrpos.pls 120.4 2007/09/19 18:38:42 ajosephg ship $ */
-- Start of Comments
-- Package name     : CSP_REPAIR_PO_GRP
-- Purpose          : This package creates Repair Purchase Order Requisition and Reservation of defective parts.
-- History          :
-- NOTE             :
-- End of Comments
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- ajosephg    01/22/01 Created Package

  TYPE defective_parts_rec_type IS RECORD
       (defective_item_id         NUMBER
        ,defective_quantity       NUMBER
       );

  TYPE defective_parts_tbl_Type IS TABLE OF defective_parts_rec_type
  INDEX BY BINARY_INTEGER;

  TYPE defect_parts_reserve_rec_type IS RECORD
       (defective_item_id         NUMBER
        ,defective_quantity       NUMBER
        ,reservation_id           NUMBER
       );

  TYPE defect_parts_reserve_tbl_Type IS TABLE OF defect_parts_reserve_rec_type
  INDEX BY BINARY_INTEGER;


  TYPE out_reserve_rec_type IS RECORD(need_by_date       DATE
                                     ,organization_id    NUMBER
                                     ,item_id            NUMBER
                                     ,item_uom_code      VARCHAR2(3)
                                     ,quantity_needed    NUMBER
                                     ,sub_inventory_code VARCHAR2(10)
                                     ,line_id            NUMBER
                                     ,revision           VARCHAR2(3)
                                     ,reservation_id     NUMBER);

  TYPE out_reserve_tbl_Type IS TABLE OF out_reserve_rec_type
  INDEX BY BINARY_INTEGER;

  PROCEDURE CREATE_REPAIR_PO
         (p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2  DEFAULT FND_API.G_FALSE
         ,p_commit                  IN VARCHAR2  DEFAULT FND_API.G_FALSE
         ,P_repair_supplier_id		IN NUMBER
         ,P_repair_supplier_org_id	IN NUMBER
         ,P_repair_program			IN VARCHAR2
         ,P_dest_organization_id	IN NUMBER
         ,P_source_organization_id	IN NUMBER
         ,P_repair_to_item_id		IN NUMBER
         ,P_quantity				IN NUMBER
         ,P_need_by_date            IN DATE
         ,P_defective_parts_tbl	    IN CSP_REPAIR_PO_GRP.defective_parts_tbl_Type
         ,x_requisition_header_id   OUT NOCOPY NUMBER
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
         );

  FUNCTION GET_ORGANIZATION_NAME
          (P_dest_organization_id NUMBER
          ) return VARCHAR2;

  PROCEDURE GET_ITEM_DETAILS
           (P_organization_id       IN NUMBER
            ,P_inventory_item_id    IN NUMBER
            ,x_item_number          OUT NOCOPY VARCHAR2
            ,x_item_description     OUT NOCOPY VARCHAR2
            ,x_primary_uom_code     OUT NOCOPY VARCHAR2
            ,x_return_status        OUT NOCOPY VARCHAR2
            ,x_msg_data             OUT NOCOPY VARCHAR2
            ,x_msg_count            OUT NOCOPY NUMBER
           );

    PROCEDURE CREATE_CSP_SNAP_LOG ;

    Procedure create_csp_index
         (p_sql_stmt IN varchar2,
          p_object IN varchar2);


END CSP_REPAIR_PO_GRP; -- Package spec

/
