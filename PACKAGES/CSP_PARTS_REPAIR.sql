--------------------------------------------------------
--  DDL for Package CSP_PARTS_REPAIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PARTS_REPAIR" AUTHID CURRENT_USER AS
/* $Header: cspvprps.pls 115.1 2003/11/05 18:19:40 phegde noship $ */
--
--
-- Purpose: This package will contain procedures for creating internal orders
--          and repair order for repair notifications

-- MODIFICATION HISTORY
-- Person      Date       Comments
-- phegde      05/02/03   Created package


   PROCEDURE create_orders
    (  p_api_version             IN NUMBER
      ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
      ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
      ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
      ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
      ,p_repair_supplier_id      IN NUMBER
      ,x_return_status           OUT NOCOPY VARCHAR2
      ,x_msg_count               OUT NOCOPY NUMBER
      ,x_msg_data                OUT NOCOPY VARCHAR2);
END;

 

/
