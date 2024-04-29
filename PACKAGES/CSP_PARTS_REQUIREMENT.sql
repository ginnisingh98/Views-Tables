--------------------------------------------------------
--  DDL for Package CSP_PARTS_REQUIREMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PARTS_REQUIREMENT" AUTHID CURRENT_USER AS
/* $Header: cspvprqs.pls 120.4.12010000.9 2012/12/19 11:49:39 shadas ship $ */


-- Purpose: To create/update/cancel parts requirements for spares
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- phegde      05/17/01 Created Package


TYPE Header_Rec_Type IS RECORD
( requisition_header_id     NUMBER
 ,requisition_number        VARCHAR2(20)
 ,description               VARCHAR2(240)
 ,order_header_id           NUMBER
 ,order_type_id             NUMBER
 ,ship_to_location_id       NUMBER
 ,shipping_method_code      VARCHAR2(30)
 ,task_id                   NUMBER
 ,task_assignment_id        NUMBER
 ,need_by_date              DATE
 ,dest_organization_id      NUMBER
 ,dest_subinventory         VARCHAR2(30)
 ,operation                 VARCHAR2(30)
 ,requirement_header_id     NUMBER
 ,change_Reason             VARCHAR2(30)
 ,change_comments           VARCHAR2(30)
 ,resource_type             VARCHAR2(30)
 ,resource_id               NUMBER
 ,incident_id               NUMBER
 ,address_type              varchar2(1)
 ,JUSTIFICATION             VARCHAR2(480)
 ,NOTE_TO_BUYER             VARCHAR2(480)
 ,NOTE1_ID                  NUMBER
 ,NOTE1_TITLE               VARCHAR2(80)
 ,CALLED_FROM               VARCHAR2(240)
 ,suggested_vendor_id       NUMBER
 ,suggested_vendor_name     VARCHAR2(240)
 ,ATTRIBUTE_CATEGORY        VARCHAR2(30) ,
  ATTRIBUTE1                VARCHAR2(150),
  ATTRIBUTE2                VARCHAR2(150),
  ATTRIBUTE3                VARCHAR2(150),
  ATTRIBUTE4                VARCHAR2(150),
  ATTRIBUTE5                VARCHAR2(150),
  ATTRIBUTE6                VARCHAR2(150),
  ATTRIBUTE7                VARCHAR2(150),
  ATTRIBUTE8                VARCHAR2(150),
  ATTRIBUTE9                VARCHAR2(150),
  ATTRIBUTE10               VARCHAR2(150),
  ATTRIBUTE11               VARCHAR2(150),
  ATTRIBUTE12               VARCHAR2(150),
  ATTRIBUTE13               VARCHAR2(150),
  ATTRIBUTE14               VARCHAR2(150),
  ATTRIBUTE15               VARCHAR2(150),
  SHIP_TO_CONTACT_ID        NUMBER
 );

TYPE Line_Rec_type IS RECORD
( requisition_line_id       NUMBER
 ,order_line_id             NUMBER
 ,line_num                  NUMBER
 ,inventory_item_id         NUMBER
 ,item_description          VARCHAR2(240)
 ,revision                  VARCHAR2(3)
 ,quantity                  NUMBER
 ,unit_of_measure           VARCHAR2(3)
 ,dest_subinventory         VARCHAR2(30)
 ,source_organization_id    NUMBER
 ,source_subinventory       VARCHAR2(30)
 ,ship_complete             VARCHAR2(30)
 ,shipping_method_code      VARCHAR2(30)
 ,likelihood                NUMBER
 ,ordered_quantity          NUMBER
 ,order_by_date             DATE
,arrival_date               DATE
 ,need_by_date              DATE
 ,reservation_id            NUMBER
 ,requirement_line_id       NUMBER
 ,change_reason             VARCHAR2(30)
 ,change_comments           VARCHAR2(30)
 ,booked_flag			   VARCHAR2(30) := 'N'
 ,sourced_from              VARCHAR2(30) := 'IO'
 ,available_by_need_date    VARCHAR2(1)
 ,ATTRIBUTE_CATEGORY        VARCHAR2(30) ,
  ATTRIBUTE1                VARCHAR2(150),
  ATTRIBUTE2                VARCHAR2(150),
  ATTRIBUTE3                VARCHAR2(150),
  ATTRIBUTE4                VARCHAR2(150),
  ATTRIBUTE5                VARCHAR2(150),
  ATTRIBUTE6                VARCHAR2(150),
  ATTRIBUTE7                VARCHAR2(150),
  ATTRIBUTE8                VARCHAR2(150),
  ATTRIBUTE9                VARCHAR2(150),
  ATTRIBUTE10               VARCHAR2(150),
  ATTRIBUTE11               VARCHAR2(150),
  ATTRIBUTE12               VARCHAR2(150),
  ATTRIBUTE13               VARCHAR2(150),
  ATTRIBUTE14               VARCHAR2(150),
  ATTRIBUTE15               VARCHAR2(150)
 );


 TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type
    INDEX BY BINARY_INTEGER;


 TYPE Line_details_Rec_type IS RECORD
( req_line_detail_id        NUMBER
 ,req_line_id               NUMBER
 ,source_type               varchar2(10):= 'IO'
 ,source_id                 NUMBER
 );

 TYPE Line_detail_Tbl_Type IS TABLE OF Line_details_Rec_type
    INDEX BY BINARY_INTEGER;

 TYPE Rqmt_Line_Rec_Type IS RECORD
 ( Requirement_Line_Id  NUMBER);

 TYPE Rqmt_Line_Tbl_Type IS TABLE OF Rqmt_Line_Rec_Type
    INDEX BY BINARY_INTEGER;

/* TYPE Item_Rec_Type IS RECORD
 (  Inventory_Item_Id NUMBER);

 TYPE Item_Tbl_Type IS TABLE OF Item_Rec_Type
    INDEX BY BINARY_INTEGER;
*/

 TYPE Order_Rec_Type IS RECORD
 (  SOURCE_TYPE VARCHAR2(10)
   ,ORDER_NUMBER NUMBER);

 TYPE Order_Tbl_Type IS TABLE OF Order_Rec_Type
    INDEX BY BINARY_INTEGER;

 -- Operations
 G_OPR_CREATE	    CONSTANT	VARCHAR2(30) := 'CREATE';
 G_OPR_UPDATE	    CONSTANT	VARCHAR2(30) := 'UPDATE';
 G_OPR_DELETE	    CONSTANT	VARCHAR2(30) := 'DELETE';
 G_OPR_LOCK	        CONSTANT	VARCHAR2(30) := 'LOCK';
 G_OPR_CANCEL        CONSTANT    VARCHAR2(30) := 'CANCEL';
 --G_OPR_NONE	    CONSTANT	VARCHAR2(30) := FND_API.G_MISS_CHAR;

 -- Address Types
 G_ADDR_RESOURCE   CONSTANT  VARCHAR2(1) := 'R';
 G_ADDR_CUSTOMER   CONSTANT  VARCHAR2(1) := 'C';
 G_ADDR_SPECIAL    CONSTANT  VARCHAR2(1) := 'S';

 PROCEDURE process_requirement
     (    p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
         ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
         ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
         ,p_create_order_flag       IN VARCHAR2
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
      );

 -- This procedure will be called from the parts requirement UI for creating orders
 -- and updating the requirements table with the order details
 PROCEDURE csptrreq_fm_order(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
        ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  );

  PROCEDURE csptrreq_order_res(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
        ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  );
   PROCEDURE Get_source_organization (
    P_Inventory_Item_Id          IN   NUMBER,
    P_Organization_Id            IN   NUMBER,
    P_Secondary_Inventory        IN   VARCHAR2,
    x_source_org_id              OUT NOCOPY  NUMBER,
	x_source_subinv              OUT NOCOPY VARCHAR2
    );

        PROCEDURE delete_rqmt_header(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_header_id               IN NUMBER
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  );

  PROCEDURE save_rqmt_line(
        p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,px_header_rec              IN OUT NOCOPY csp_parts_requirement.Header_rec_type
        ,px_line_tbl               IN OUT NOCOPY csp_parts_requirement.Line_tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  );

  PROCEDURE delete_rqmt_line(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_line_tbl                IN OUT NOCOPY csp_parts_requirement.Rqmt_Line_tbl_type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  );

  PROCEDURE check_Availability(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_header_id               IN NUMBER
        ,x_line_Tbl                OUT NOCOPY csp_parts_requirement.Line_tbl_type
        ,x_avail_flag              OUT NOCOPY VARCHAR2
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  );

  PROCEDURE create_order(
         p_api_version               IN NUMBER
        ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        ,p_header_id               IN NUMBER
        ,x_order_tbl               OUT NOCOPY Order_Tbl_Type
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
  );

  PROCEDURE TASK_ASSIGNMENT_POST_UPDATE(x_return_status out nocopy varchar2);
  PROCEDURE TASK_ASSIGNMENT_PRE_UPDATE( x_return_status OUT NOCOPY varchar2);
  PROCEDURE TASK_ASSIGNMENT_POST_INSERT(x_return_status out nocopy varchar2);
  PROCEDURE TASK_ASSIGNMENT_PRE_DELETE(x_return_status out nocopy varchar2);

  procedure get_resource_shift_end(
         p_resource_id             in number
        ,p_resource_type           in varchar2
        ,x_shift_end_datetime      out nocopy date
        ,x_return_status           out nocopy varchar2
        ,x_msg_count               out nocopy number
        ,x_msg_data                out nocopy varchar2
  );

END; -- Package spec

/
