--------------------------------------------------------
--  DDL for Package WSMPLBJT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPLBJT" AUTHID CURRENT_USER AS
/* $Header: WSMLBJTS.pls 120.1 2005/06/21 03:26:20 appldev ship $ */

FUNCTION Material_Issue (
X_Wip_Entity_Id 		IN NUMBER,
X_Inventory_Item_Id 		IN NUMBER,
X_Organization_id 		IN NUMBER,
X_Quantity 			IN NUMBER,
X_Acct_Period_Id 		IN NUMBER,
X_Lot_Creation_Id 		IN NUMBER,
X_Lot_Number 			IN VARCHAR2,
X_Subinventory 			IN VARCHAR2,
X_Locator_Id 			IN NUMBER,
X_Revision 			IN VARCHAR2,
X_err_code 			OUT NOCOPY NUMBER,
X_err_msg 			OUT NOCOPY VARCHAR2,
X_passed_header_id 		IN  NUMBER DEFAULT null,
-- ST : Serial Support Project --
-- Return the transaction temp id also... --
X_Temp_id			OUT NOCOPY  NUMBER
-- ST : Serial Support Project --
)
RETURN NUMBER;


FUNCTION get_assembly(
X_Component_Item_Id IN NUMBER,
X_Organization_Id IN NUMBER,
X_err_code OUT NOCOPY NUMBER,
X_err_msg OUT NOCOPY VARCHAR2)
RETURN NUMBER;

FUNCTION get_id(
X_item_name IN VARCHAR2,
X_organization_id IN NUMBER,
X_err_code OUT NOCOPY NUMBER,
X_err_msg OUT NOCOPY VARCHAR2)
return NUMBER;

FUNCTION next_job_name (
 X_Job_Name IN VARCHAR2,
 X_Organization_Id IN NUMBER,
 X_Item_Id IN NUMBER,
 X_Count IN NUMBER,
 X_err_code OUT NOCOPY NUMBER,
 X_err_msg OUT NOCOPY VARCHAR2)

RETURN NUMBER;

END WSMPLBJT;

 

/
