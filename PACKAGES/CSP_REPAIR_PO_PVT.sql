--------------------------------------------------------
--  DDL for Package CSP_REPAIR_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REPAIR_PO_PVT" AUTHID CURRENT_USER AS
/* $Header: cspgrexs.pls 120.1 2005/07/20 11:52:15 ajosephg noship $ */

-- Start of Comments
-- Package name     : CSP_REPAIR_PO_GRP
-- Purpose          : This package creates Repair Purchase Order Execution details.
-- History          :
-- NOTE             :
-- End of Comments
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- ajosephg    07/05/05 Created Package


  TYPE out_reserve_rec_type IS RECORD(need_by_date       DATE
                                     ,organization_id    NUMBER
                                     ,item_id            NUMBER
                                     ,item_uom_code      VARCHAR2(3)
                                     ,quantity_needed    NUMBER
                                     ,sub_inventory_code VARCHAR2(10)
                                     ,line_id            NUMBER
                                     ,revision           VARCHAR2(3)
                                     ,reservation_id     NUMBER);

    /** Errbuf returns error messages
        Retcode returns 0 = Success, 1 = Success with warnings, 2 = Error
    **/

    PROCEDURE RUN_REPAIR_EXECUTION
    (errbuf                 OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_Api_Version_Number    IN  NUMBER,
    p_repair_po_header_id   IN  NUMBER default null
    );

    PROCEDURE REP_PO_SCRAP_ADJUST_TRANSACT
    (p_Api_Version_Number     IN NUMBER
    ,p_Init_Msg_List          IN VARCHAR2     := FND_API.G_FALSE
    ,p_commit                 IN VARCHAR2     := FND_API.G_FALSE
    ,p_REPAIR_PO_HEADER_ID    IN NUMBER
    ,p_SCRAP_ADJUST_FLAG      IN VARCHAR2
    ,p_SCRAP_ADJUST_ITEM_ID   IN NUMBER
    ,p_SCRAP_ADJUST_QTY	      IN NUMBER
    ,p_SCRAP_ADJUST_DATE      IN  DATE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
    );

END CSP_REPAIR_PO_PVT; -- Package spec

 

/
