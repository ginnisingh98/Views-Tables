--------------------------------------------------------
--  DDL for Package WIP_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_COMMON" AUTHID CURRENT_USER AS
/* $Header: wipcomms.pls 120.0 2005/05/25 07:55:46 appldev noship $ */


/*=====================================================================+
 | FUNCTION
 |   DEFAULT_ACC_CLASS
 |
 | PURPOSE
 |   Defaults the accounting class if one is defined for Product Line
 |   Accounting.
 |
 | ARGUMENTS
 |   X_ORG_ID : Organization Id .
 |   X_ITEM_ID : Item Id for which the accounting class is defaulted.
 |   X_CLASS_TYPE : WIP accounting class type
 |   X_PROJECT_ID : Project Id if defined, else NULL.
 |   X_ERR_MESG : The Message_name for the error message.
 |   X_ERR_CLASS : The class that is disabled.
 |   Returns NUMBER: Returns the Accounting Class if defined or NULL.
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
function default_acc_class
         (X_ORG_ID       IN     NUMBER,
          X_ITEM_ID      IN     NUMBER,
          X_ENTITY_TYPE  IN     NUMBER,
          X_PROJECT_ID   IN     NUMBER,
          X_ERR_MESG_1   OUT NOCOPY    VARCHAR2,
          X_ERR_CLASS_1  OUT NOCOPY    VARCHAR2,
          X_ERR_MESG_2   OUT NOCOPY    VARCHAR2,
          X_ERR_CLASS_2  OUT NOCOPY    VARCHAR2
         )
RETURN VARCHAR2;

/*=====================================================================+
 | FUNCTION
 |   Bill_Exists
 |
 | PURPOSE
 |   To check whether the Item/Assembly has got a Bill of Material
 |
 | ARGUMENTS
 |   p_item_id: Inventory Item Id.
 |   p_org_id : Organization Id .
 |
 | NOTE
 |     Returns 1 if Bill Exists
 |     Returns 0 if Bill does not exist or SQL Error
 |     Returns -1 if SQLERROR
 |
 +=====================================================================*/

function Bill_Exists(
	 p_item_id in number,
	 p_org_id in number) return number ;

/*=====================================================================+
 | FUNCTION
 |   Revision_Exists
 |
 | PURPOSE
 |   To check whether the Item/Assembly is under Revision Control
 |
 | ARGUMENTS
 |   p_item_id: Inventory Item Id.
 |   p_org_id : Organization Id .
 |
 | NOTE
 |     Returns 1 if the component is under revision control
 |     Returns 0 if the component is not under revision control
 |     Return  -2 if application level error
 |     Returns -1 if SQLERROR
 |
 +=====================================================================*/

function Revision_Exists(
	 p_item_id in number,
	 p_org_id in number) return number ;


/*=====================================================================+
 | FUNCTION
 |   Routing_Exists
 |
 | PURPOSE
 |   To check whether the Item/Assembly has got a Routing
 |
 | ARGUMENTS
 |   p_item_id: Inventory Item Id
 |   p_org_id : Organization Id .
 |
 | NOTE
 |     Returns 1 if Routing Exists
 |     Returns 0 if Routing does not exist
 |     Returns -1 if SQLERROR
 |
 +=====================================================================*/

function Routing_Exists(
         p_item_id in number,
         p_org_id in number,
         p_eff_date IN DATE := NULL) return number ;


/*=====================================================================+
 | FUNCTION
 |   Is_Primary_UOM
 |
 | PURPOSE
 |   To check whether the Txn_Uom specified is the Item's primary UOM
 |
 | ARGUMENTS
 |   p_item_id: Inventory Item Id
 |   p_org_id : Organization Id
 |   p_txn_uom: Transaction_UOM
 |   p_pri_uom: Primary UOM
 |
 | NOTE
 |     Returns 1 if Routing Exists
 |     Returns 0 if Routing does not exist
 |     Return  -2 if application level error
 |     Returns -1 if SQLERROR
 |
 +=====================================================================*/

function Is_Primary_UOM(
	p_item_id in number,
	p_org_id in number,
	p_txn_uom in varchar2,
	p_pri_uom in out nocopy varchar2) return number ;

/*=====================================================================+
 | PROCEDURE
 |   get_total_quantity
 |
 | PURPOSE
 |    This procedure would return the total quantity in a job/schedule
 | in an out nocopy variable. The total quantity is the sum of all assemblies in
 | all the operations, which may be different from the start quantity.
 |
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE get_total_quantity
   (
    p_organization_id             IN   NUMBER,
    p_wip_entity_id               IN   NUMBER,
    p_repetitive_schedule_id      IN   NUMBER DEFAULT NULL,
    p_total_quantity              OUT NOCOPY  NUMBER
    );

   PROCEDURE Get_Released_Revs_Type_Meaning
   (
    x_released_revs_type	OUT NOCOPY NUMBER,
    x_released_revs_meaning	OUT NOCOPY Varchar2
   );


END WIP_COMMON;

 

/
