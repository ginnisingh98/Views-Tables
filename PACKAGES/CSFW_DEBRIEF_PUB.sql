--------------------------------------------------------
--  DDL for Package CSFW_DEBRIEF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_DEBRIEF_PUB" AUTHID CURRENT_USER AS
/*$Header: csfwdbfs.pls 120.8.12010000.2 2009/04/08 11:45:52 shadas ship $*/
PROCEDURE Create_Debrief_header
  ( p_task_assignment_id     IN  NUMBER
  , p_error_id               OUT NOCOPY NUMBER
  , p_error                  OUT NOCOPY VARCHAR2
  , p_debrief_header_id      OUT NOCOPY NUMBER
  ) ;

PROCEDURE Create_Labor_Line
  ( p_debrief_header_id      IN  NUMBER,
    p_labor_start_date       IN  DATE,
    p_labor_end_date         IN  DATE,
    p_service_date           IN  DATE,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_txnTypeId		     IN  NUMBER,
    p_quantity		     IN  NUMBER,
    p_uom		     IN  VARCHAR2,
    p_justificationCode      IN  VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_debrief_line_id        OUT NOCOPY NUMBER,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2

  ) ;

  PROCEDURE Update_debrief_Labor_line(
    p_debrief_line_id        IN  NUMBER,
    p_labor_start_date       IN  DATE,
    p_labor_end_date         IN  DATE,
    p_service_date           IN  DATE,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_txnTypeId		     IN  NUMBER,
    p_quantity		     IN  NUMBER,
    p_uom		     IN  VARCHAR2,
    p_justificationCode      IN  VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2
    );


PROCEDURE Create_Expense_Line
  ( p_debrief_header_id      IN  NUMBER,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_expense_amount         IN  NUMBER,
    p_currency_code          IN  VARCHAR2,
    p_txnTypeId		     IN  NUMBER,
    p_justificationCode      IN  VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_quantity               IN  NUMBER,
    p_uom_code               IN  VARCHAR2,
    p_debrief_line_id        OUT NOCOPY NUMBER,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE Update_debrief_Expense_line(
    p_debrief_line_id        IN  NUMBER,
    p_expense_amount         IN  NUMBER,
    p_currency_code          IN  VARCHAR2,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_txnTypeId		     IN  NUMBER,
    p_justificationCode      IN VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_quantity               IN  NUMBER,
    p_uom_code               IN  VARCHAR2,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2
     );


    PROCEDURE SAVE_DEBRIEF_MATERIAL_LINE (
	p_taskid		IN VARCHAR2,
	p_taskassignmentid	IN VARCHAR2,
	p_incidentid		IN VARCHAR2,
	p_partyid		IN VARCHAR2,
	p_dbfNr			IN VARCHAR2,
	p_billingTypeId		IN VARCHAR2,
	p_txnTypeId		IN VARCHAR2,
	p_orderCategoryCode	IN VARCHAR2,
	p_txnTypeName		IN VARCHAR2,
	p_itemId		IN VARCHAR2,
	p_revisionFlag		IN VARCHAR2,
	p_businessProcessId	IN VARCHAR2,
	p_subTypeId		IN VARCHAR2,
	p_updateIBFlag		IN VARCHAR2,
	p_srcChangeOwner	IN VARCHAR2,
	p_srcChangeOwnerToCode	IN VARCHAR2,
	p_srcReferenceReqd	IN VARCHAR2,
	p_srcReturnReqd		IN VARCHAR2,
	p_parentReferenceReqd	IN VARCHAR2,
	p_srcStatusId		IN VARCHAR2,
	p_srcStatusName		IN VARCHAR2,
	p_csiTxnTypeId		IN VARCHAR2,
	p_subInv		IN VARCHAR2,
	p_orgId			IN VARCHAR2,
	p_serviceDate		IN VARCHAR2,
	p_qty			IN VARCHAR2,
	p_chgFlag		IN VARCHAR2,
	p_ibFlag		IN VARCHAR2,
	p_invFlag		IN VARCHAR2,
	p_reasonCd		IN VARCHAR2,
	p_instanceId		IN VARCHAR2,
	p_parentProductId	IN VARCHAR2,
	p_partStatusCd		IN VARCHAR2,
	p_recoveredPartId	IN VARCHAR2,
	p_retReasonCd		IN VARCHAR2,
	p_serialNr		IN VARCHAR2,
	p_lotNr			IN VARCHAR2,
	p_revisionNr		IN VARCHAR2,
	p_locatorId		IN VARCHAR2,
	p_UOM			IN VARCHAR2,
	p_updateFlag		IN Number,
	p_dbfLineId		IN Number,
   p_ret_dbfLine_id         OUT NOCOPY NUMBER,
	p_error_id               OUT NOCOPY NUMBER,
	p_error                  OUT NOCOPY VARCHAR2,
	p_return_date           IN VARCHAR2
);


FUNCTION validate_labor_time(
      p_resource_type_code         in  Varchar2,
      p_resource_id                in  Number,
      p_debrief_line_id            in  Number,
      p_labor_start_date           in  Date,
      p_labor_end_date             in  Date
)
return varchar;



/*
PROCEDURE UPDATE_CHARGES(
p_dbfLineId in number,
p_incidentId in number,
p_error       out NOCOPY varchar2,
p_error_id    out NOCOPY number
);
PROCEDURE UPDATE_IB
(
p_dbfLineId in number,
p_incidentId in number,
p_error_id out NOCOPY number,
p_error out NOCOPY varchar2
) ;
PROCEDURE UPDATE_SPARES(
p_dbfLineId in number,
p_dbfNr in varchar2,
p_error_id out NOCOPY number,
p_error out NOCOPY varchar2
);
*/

/* Updates info for travel debrief */
PROCEDURE Create_Travel_Debrief
  ( p_task_assignment_id     IN         NUMBER
  , p_debrief_header_id      IN		NUMBER
  , p_start_date	     IN		DATE
  , p_end_date		     IN		DATE
  , p_distance     	     IN		NUMBER
  , p_error_id               OUT NOCOPY NUMBER
  , p_error                  OUT NOCOPY VARCHAR2
  );

-- For Debrief Header DFF
PROCEDURE Update_Debrief_Header
   (  p_DEBRIEF_ID            IN    NUMBER,
      p_DEBRIEF_NUMBER        IN    VARCHAR2 default FND_API.G_MISS_CHAR,
      p_DEBRIEF_DATE          IN    DATE default FND_API.G_MISS_DATE,
      p_DEBRIEF_STATUS_ID     IN    NUMBER default FND_API.G_MISS_NUM,
      p_TASK_ASSIGNMENT_ID    IN    NUMBER default FND_API.G_MISS_NUM,
      p_CREATED_BY            IN    NUMBER default FND_API.G_MISS_NUM,
      p_CREATION_DATE         IN    DATE default FND_API.G_MISS_DATE,
      p_LAST_UPDATED_BY       IN    NUMBER default FND_API.G_MISS_NUM,
      p_LAST_UPDATE_DATE      IN    DATE default FND_API.G_MISS_DATE,
      p_LAST_UPDATE_LOGIN     IN    NUMBER default FND_API.G_MISS_NUM,
      p_ATTRIBUTE1            IN    VARCHAR2,
      p_ATTRIBUTE2            IN    VARCHAR2,
      p_ATTRIBUTE3            IN    VARCHAR2,
      p_ATTRIBUTE4            IN    VARCHAR2,
      p_ATTRIBUTE5            IN    VARCHAR2,
      p_ATTRIBUTE6            IN    VARCHAR2,
      p_ATTRIBUTE7            IN    VARCHAR2,
      p_ATTRIBUTE8            IN    VARCHAR2,
      p_ATTRIBUTE9            IN    VARCHAR2,
      p_ATTRIBUTE10           IN    VARCHAR2,
      p_ATTRIBUTE11           IN    VARCHAR2,
      p_ATTRIBUTE12           IN    VARCHAR2,
      p_ATTRIBUTE13           IN    VARCHAR2,
      p_ATTRIBUTE14           IN    VARCHAR2,
      p_ATTRIBUTE15           IN    VARCHAR2,
      p_ATTRIBUTE_CATEGORY    IN    VARCHAR2,
      p_return_status         OUT NOCOPY VARCHAR2,
      p_error_count           OUT NOCOPY NUMBER,
      p_error                 OUT NOCOPY VARCHAR2
   );

END csfw_debrief_pub;


/
