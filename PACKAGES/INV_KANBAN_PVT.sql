--------------------------------------------------------
--  DDL for Package INV_KANBAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_KANBAN_PVT" AUTHID CURRENT_USER as
/* $Header: INVVKBNS.pls 120.5.12010000.3 2009/04/08 08:31:29 aambulka ship $ */


/* **
List of Global constants used in kanban API's
** */
G_Current_Plan		    Constant      Number := -1;

G_Source_Type_InterOrg      Constant      Number := 1;
G_Source_Type_Supplier      Constant      Number := 2;
G_Source_Type_IntraOrg      Constant      Number := 3;
G_Source_Type_Production    Constant      Number := 4;

G_Supply_Status_New         Constant      Number := 1;
G_Supply_Status_Full        Constant      Number := 2;
G_Supply_Status_Wait        Constant      Number := 3;
G_Supply_Status_Empty       Constant      Number := 4;
G_Supply_Status_InProcess   Constant      Number := 5;
G_Supply_Status_InTransit   Constant      Number := 6;
G_Supply_Status_Exception   Constant      Number := 7;

G_Card_Type_Replenishable   Constant      Number := 1;
G_Card_Type_NonReplenishable Constant     Number := 2;

G_Card_Status_Active        Constant      Number := 1;
G_Card_Status_Hold          Constant      Number := 2;
G_Card_Status_Cancel        Constant      Number := 3;

G_No_Pull_Sequence          Constant      Number := -1;

G_Doc_type_PO          		 Constant      Number := 1;
G_Doc_type_Release    		 Constant      Number := 2;
G_Doc_type_Internal_Req		 Constant      Number := 3;
G_Doc_type_Transfer_Order	 Constant      Number := 4;
G_Doc_type_Discrete_Job    	 Constant      Number := 5;
G_Doc_type_Rep_Schedule          Constant      Number := 6;
G_Doc_type_Flow_Schedule    	 Constant      Number := 7;
G_Doc_type_lot_job   	         Constant      Number := 8;

/* **
Defining a data type - table of kanban card Ids
( Single column table - )
** */
TYPE Kanban_Card_Id_Tbl_Type IS TABLE OF MTL_KANBAN_CARDS.KANBAN_CARD_ID%TYPE
    INDEX BY BINARY_INTEGER;


/* **
Defining a structure of type Pull_sequence_Rec
** */
TYPE Pull_Sequence_Rec_Type IS RECORD
(   pull_sequence_id              NUMBER         := FND_API.G_MISS_NUM
,   inventory_item_id             NUMBER         := FND_API.G_MISS_NUM
,   organization_id               NUMBER         := FND_API.G_MISS_NUM
,   subinventory_name             VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   Kanban_plan_id                NUMBER         := FND_API.G_MISS_NUM
,   source_type                   NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   locator_id                    NUMBER         := FND_API.G_MISS_NUM
,   supplier_id                   NUMBER         := FND_API.G_MISS_NUM
,   supplier_site_id              NUMBER         := FND_API.G_MISS_NUM
,   source_organization_id        NUMBER         := FND_API.G_MISS_NUM
,   source_subinventory           VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   source_locator_id             NUMBER         := FND_API.G_MISS_NUM
,   wip_line_id                   NUMBER         := FND_API.G_MISS_NUM
,   replenishment_lead_time       NUMBER         := FND_API.G_MISS_NUM
,   calculate_kanban_flag         NUMBER         := FND_API.G_MISS_NUM
,   kanban_size                   NUMBER         := FND_API.G_MISS_NUM
,   fixed_lot_multiplier          NUMBER         := FND_API.G_MISS_NUM
,   safety_stock_days             NUMBER         := FND_API.G_MISS_NUM
,   number_of_cards               NUMBER         := FND_API.G_MISS_NUM
,   minimum_order_quantity        NUMBER         := FND_API.G_MISS_NUM
,   aggregation_type              NUMBER         := FND_API.G_MISS_NUM
,   allocation_percent            NUMBER         := FND_API.G_MISS_NUM
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   updated_flag             	  NUMBER         := FND_API.G_MISS_NUM
,   attribute_category            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   release_kanban_flag           NUMBER         := FND_API.G_MISS_NUM
,   point_of_use_x                NUMBER         := FND_API.G_MISS_NUM
,   point_of_use_y                NUMBER         := FND_API.G_MISS_NUM
,   point_of_supply_x             NUMBER         := FND_API.G_MISS_NUM
,   point_of_supply_y             NUMBER         := FND_API.G_MISS_NUM
,   planning_update_status        NUMBER         := FND_API.G_MISS_NUM
,   auto_request                  VARCHAR2(1)    := NULL
,   kanban_card_type              NUMBER         := NULL
,   auto_allocate_flag            NUMBER         := FND_API.G_MISS_NUM   --Added for 3905884.
);



/* **
Defining a structure of type Kanban_Card_Rec_Type
** */
TYPE Kanban_Card_Rec_Type IS RECORD
(   kanban_card_id                NUMBER         := FND_API.g_miss_num
,   kanban_card_number            VARCHAR2(30)   := FND_API.g_miss_char
,   pull_sequence_id              NUMBER         := FND_API.g_miss_num
,   inventory_item_id             NUMBER         := FND_API.g_miss_num
,   organization_id               NUMBER         := FND_API.g_miss_num
,   subinventory_name             VARCHAR2(10)   := FND_API.g_miss_char
,   supply_status                 NUMBER         := FND_API.g_miss_num
,   card_status                   NUMBER         := FND_API.g_miss_num
,   kanban_card_type              NUMBER         := FND_API.g_miss_num
,   source_type                   NUMBER         := FND_API.g_miss_num
,   kanban_size                   NUMBER         := FND_API.g_miss_num
,   last_update_date              DATE           := FND_API.g_miss_date
,   last_updated_by               NUMBER         := FND_API.g_miss_num
,   creation_date                 DATE           := FND_API.g_miss_date
,   created_by                    NUMBER         := FND_API.g_miss_num
,   locator_id                    NUMBER         := FND_API.g_miss_num
,   supplier_id                   NUMBER         := FND_API.g_miss_num
,   supplier_site_id              NUMBER         := FND_API.g_miss_num
,   source_organization_id        NUMBER         := FND_API.g_miss_num
,   source_subinventory           VARCHAR2(10)   := FND_API.g_miss_char
,   source_locator_id             NUMBER         := FND_API.g_miss_num
,   wip_line_id                   NUMBER         := FND_API.g_miss_num
,   current_replnsh_cycle_id      NUMBER         := FND_API.g_miss_num
,   document_type	          NUMBER         := FND_API.G_MISS_NUM
,   document_header_id	          NUMBER         := FND_API.G_MISS_NUM
,   document_detail_id	          NUMBER         := FND_API.G_MISS_NUM
,   error_code                    VARCHAR2(30)   := FND_API.g_miss_char
,   last_update_login             NUMBER         := FND_API.g_miss_num
,   last_print_date               DATE           := FND_API.g_miss_date
,   attribute_category            VARCHAR2(30)   := FND_API.g_miss_char
,   attribute1                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute2                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute3                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute4                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute5                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute6                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute7                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute8                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute9                    VARCHAR2(150)  := FND_API.g_miss_char
,   attribute10                   VARCHAR2(150)  := FND_API.g_miss_char
,   attribute11                   VARCHAR2(150)  := FND_API.g_miss_char
,   attribute12                   VARCHAR2(150)  := FND_API.g_miss_char
,   attribute13                   VARCHAR2(150)  := FND_API.g_miss_char
,   attribute14                   VARCHAR2(150)  := FND_API.g_miss_char
,   attribute15                   VARCHAR2(150)  := FND_API.g_miss_char
,   request_id                    NUMBER         := FND_API.g_miss_num
,   program_application_id        NUMBER         := FND_API.g_miss_num
,   program_id                    NUMBER         := FND_API.g_miss_num
,   program_update_date           DATE           := FND_API.g_miss_date
,   lot_item_id                   NUMBER         DEFAULT NULL
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
,   lot_number                    VARCHAR2(80)   DEFAULT NULL
,   lot_item_revision             VARCHAR2(1)    DEFAULT NULL
,   lot_subinventory_code         VARCHAR2(30)   DEFAULT NULL
,   lot_location_id               NUMBER         DEFAULT NULL
,   lot_quantity                  NUMBER         DEFAULT NULL
  ,   replenish_quantity            NUMBER         DEFAULT NULL
  ,   need_by_date                  DATE           DEFAULT NULL
  ,   source_wip_entity_id          NUMBER         DEFAULT NULL);


/* **
Defining a data type - table of pull_sequence_id
Single column table -
** */
TYPE Pull_Sequence_Id_Tbl_Type IS TABLE
	OF MTL_KANBAN_PULL_SEQUENCES.PULL_SEQUENCE_ID%TYPE
    INDEX BY BINARY_INTEGER;


PullSeqTable  Pull_Sequence_Id_Tbl_Type;

TYPE Operation_Tbl_Type IS TABLE
      OF NUMBER INDEX BY BINARY_INTEGER;

G_Operation_Tbl Operation_Tbl_Type;

/* **
To update pull sequence table
** */
PROCEDURE Update_Pull_sequence_tbl
(x_return_status       Out NOCOPY Varchar2,
 p_Pull_Sequence_tbl   INV_Kanban_PVT.Pull_Sequence_Id_Tbl_Type,
 x_update_flag         IN  Varchar2,
 p_operation_tbl       INV_Kanban_PVT.operation_tbl_type := G_Operation_Tbl);

/* **
API to get Kanban constants
** */
Procedure Get_Constants
(X_Ret_Success     		Out NOCOPY Varchar2,
 X_Ret_Error       		Out NOCOPY Varchar2 ,
 X_Ret_Unexp_Error 		Out NOCOPY Varchar2 ,
 X_Current_Plan    		Out NOCOPY Number,
 X_Source_Type_InterOrg    	Out NOCOPY Number,
 X_Source_Type_Supplier    	Out NOCOPY Number,
 X_Source_Type_IntraOrg    	Out NOCOPY Number,
 X_Source_Type_Production  	Out NOCOPY Number,
 X_Card_Type_Replenishable  	Out NOCOPY Number,
 X_Card_Type_NonReplenishable  	Out NOCOPY Number,
 X_Card_Status_Active  		Out NOCOPY Number,
 X_Card_Status_Hold  		Out NOCOPY Number,
 X_Card_Status_Cancel  		Out NOCOPY Number,
 X_No_Pull_sequence  		Out NOCOPY Number,
 X_Doc_Type_Po  		Out NOCOPY Number,
 X_Doc_Type_Release  		Out NOCOPY Number,
 X_Doc_Type_Internal_Req  	Out NOCOPY Number);


/* **
API to Delete a pull sequence
** */
PROCEDURE Delete_Pull_Sequence
(x_return_status  Out NOCOPY Varchar2,
 p_kanban_plan_id     Number);

/* **
API to Create a new Pull sequence
** */
PROCEDURE Insert_Pull_sequence
(x_return_status       Out NOCOPY Varchar2,
 p_Pull_Sequence_Rec   INV_Kanban_PVT.Pull_sequence_Rec_Type);

/* **
API to update an existing Pull Sequence
** */
PROCEDURE Update_Pull_sequence
(x_return_status       Out NOCOPY Varchar2,
 x_Pull_Sequence_Rec   IN OUT NOCOPY INV_Kanban_PVT.Pull_sequence_Rec_Type);

/* **
Updating a Kanban Card supply Status is a Overloaded function
can be called with various inputs. Following are the various
forms of this API with the inputs required.
** */
PROCEDURE Update_Card_Supply_Status(X_Return_Status      Out NOCOPY Varchar2,
                                    p_Kanban_Card_Id     Number,
                                    p_Supply_Status      Number,
                                    p_Document_type      Number,
                                    p_Document_Header_Id Number,
                                    p_Document_detail_Id NUMBER,
				    p_replenish_quantity NUMBER DEFAULT	NULL,
				    p_need_by_date       DATE   DEFAULT NULL,
				    p_source_wip_entity_id  NUMBER DEFAULT NULL);

PROCEDURE Update_Card_Supply_Status(X_Return_Status      Out NOCOPY Varchar2,
                                    p_Kanban_Card_Id         Number,
                                    p_Supply_Status          Number);

PROCEDURE Update_Card_Supply_Status
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Kanban_Card_Id                    Number
    ,   p_Supply_Status                     NUMBER
    ,   p_Document_type                 IN  NUMBER DEFAULT NULL
    ,   p_Document_Header_Id            IN  NUMBER DEFAULT NULL
    ,   p_Document_detail_Id            IN  NUMBER DEFAULT NULL
    ,   p_replenish_quantity            IN  NUMBER DEFAULT NULL
    ,   p_need_by_date                  IN  DATE   DEFAULT NULL
    ,   p_source_wip_entity_id          IN  NUMBER DEFAULT NULL);

PROCEDURE Update_Card_Supply_Status(X_Return_Status      Out NOCOPY Varchar2,
                                    p_Kanban_Card_Id     Number,
                                    p_Supply_Status      Number,
                                    p_Document_type      Number,
                                    p_Document_Header_Id Number);

/* **
API to check the existence of valid kanban cards for
a pull sequence.
** */
FUNCTION Valid_Kanban_Cards_Exist(p_Pull_sequence_id number)
Return Boolean;


/* **
API to check the existence of valid kanban cards for
a pull sequence, which have the same Point of Supply
but different quantity
** */
FUNCTION Diff_Qty_Kanban_Cards_Exist(
                                     p_pull_sequence_id       number,
                                     p_source_type            number,
                                     p_supplier_id            number,
                                     p_supplier_site_id       number,
                                     p_source_organization_id number,
                                     p_source_subinventory    varchar2,
                                     p_source_locator_id      number,
                                     p_wip_line_id            number,
                                     p_kanban_size            number)
Return Number;


/* **
API to check if it is OK to create kanban cards for the given
 pull sequence.
** */
FUNCTION Ok_To_Create_Kanban_Cards(p_Pull_sequence_id number)
Return Boolean;


/* **
API to check if it is OK to delete a given
 pull sequence.
** */
FUNCTION Ok_To_Delete_Pull_Sequence(p_Pull_sequence_id number)
RETURN BOOLEAN;


/* **
API to check if the kanban card is a valid production card.
** */
FUNCTION Valid_Production_Kanban_Card(	p_wip_entity_id  number,
 					p_org_id         number,
               		                p_kanban_id      number,
               		                p_inv_item_id    number,
               		                p_subinventory   varchar2,
               		                p_locator_id     number  )
RETURN BOOLEAN;


/* **
API to create kanban cards for
a pull sequence.
** */
PROCEDURE Create_Kanban_Cards
(X_return_status    	OUT NOCOPY VARCHAR2,
 X_Kanban_Card_Ids  	OUT NOCOPY INV_Kanban_PVT.Kanban_Card_Id_Tbl_Type,
 P_Pull_Sequence_Rec    INV_Kanban_PVT.Pull_Sequence_Rec_Type,
 p_Supply_Status        NUMBER);


/* **
API to validate and create replenishment order for a
Kanban card.
** */
PROCEDURE Check_And_Create_Replenishment
(x_return_status                  Out NOCOPY Varchar2,
 X_Supply_Status                  Out NOCOPY Number,
 X_Current_Replenish_Cycle_Id     Out NOCOPY Number,
 P_Kanban_Card_Rec                In Out NOCOPY INV_Kanban_PVT.Kanban_Card_Rec_Type);

PROCEDURE test;

PROCEDURE update_kanban_card_status
  (p_Card_Status                    IN Number,
   p_pull_sequence_id               IN Number);

/*Bug 3740514: Controlling the Updation of Kanban Cards and its activity for
Cards with Supply Type as 'Supplier' and Document Type as 'Release' */
PROCEDURE update_card_and_card_status
  (p_kanban_card_id    IN NUMBER,
   p_supply_status     IN NUMBER,/*Bug# 4490269 */
   p_document_detail_Id IN NUMBER DEFAULT NULL, /*Bug#7133795*/
   p_Document_header_id IN NUMBER DEFAULT NULL, /*Bug#7133795*/
   p_update            OUT NOCOPY BOOLEAN) ;


PROCEDURE return_att_quantity(p_org_id       IN NUMBER,
			      p_item_id      IN NUMBER,
			      p_rev          IN VARCHAR2,
			      p_lot_no       IN VARCHAR2,
			      p_subinv       IN VARCHAR2,
			      p_locator_id   IN NUMBER,
			      x_qoh          OUT NOCOPY NUMBER,
			      x_atr          OUT NOCOPY NUMBER,
			      x_att          OUT NOCOPY NUMBER,
			      x_err_code     OUT NOCOPY NUMBER,
			      x_err_msg      OUT NOCOPY VARCHAR2);

PROCEDURE get_max_kanban_asmbly_qty( p_bill_seq_id        IN NUMBER,
				     P_COMPONENT_ITEM_ID  IN NUMBER,
				     P_BOM_REVISION_DATE  IN DATE DEFAULT NULL,
				     P_START_SEQ_NUM	  IN NUMBER,
				     P_AVAILABLE_QTY	  IN NUMBER,
				     X_MAX_ASMBLY_QTY     OUT NOCOPY NUMBER,
				     X_ERROR_CODE	  OUT NOCOPY NUMBER,
				     X_error_msg          OUT NOCOPY VARCHAR2);

PROCEDURE GET_KANBAN_REC_GRP_INFO(p_organization_id     IN NUMBER,
				   p_kanban_assembly_id  IN NUMBER,
				   p_rtg_rev_date        IN DATE DEFAULT Sysdate,
				   x_bom_seq_id	         OUT NOCOPY NUMBER,
				   x_start_seq_num	 OUT NOCOPY NUMBER,
				   X_error_code	         OUT NOCOPY NUMBER,
				   X_error_msg	         OUT NOCOPY VARCHAR2);

FUNCTION eligible_for_lbj
  (p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_source_type_id    IN NUMBER,
   p_kanban_card_id    IN NUMBER DEFAULT NULL) RETURN VARCHAR2;


/*The following procedure is added for 3905884. This procedure automatically
  allocates the move order created for Kanaban replenishment if the
  Auto_Allocate_Flag is set
*/
PROCEDURE Auto_Allocate_Kanban (
  p_mo_header_id    IN            NUMBER   ,
  x_return_status   OUT NOCOPY    VARCHAR2 ,
  x_msg_count       OUT NOCOPY    NUMBER  ,
  x_msg_data        OUT NOCOPY    VARCHAR2  );

/* Added below function for bug 7721127 */
FUNCTION get_preprocessing_lead_time( p_organization_id   IN NUMBER,
                                 p_inventory_item_id IN NUMBER)
        RETURN NUMBER;


END INV_Kanban_PVT;

/
