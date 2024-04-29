--------------------------------------------------------
--  DDL for Package INV_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: INVSVATS.pls 120.3.12010000.4 2010/10/12 23:31:51 vissubra ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.

T CONSTANT NUMBER := 1;
F CONSTANT NUMBER := 0;

/*** Various row types for the IN OUT parameters ***/
SUBTYPE ORG     IS MTL_PARAMETERS%ROWTYPE;
SUBTYPE ITEM    IS MTL_SYSTEM_ITEMS%ROWTYPE;
SUBTYPE SUB     IS MTL_SECONDARY_INVENTORIES%ROWTYPE;
SUBTYPE LOCATOR IS MTL_ITEM_LOCATIONS%ROWTYPE;
SUBTYPE LOT     IS MTL_LOT_NUMBERS%ROWTYPE;
SUBTYPE SERIAL  IS MTL_SERIAL_NUMBERS%ROWTYPE;
SUBTYPE transaction IS mtl_transaction_types%ROWTYPE;

/* Added the below types for Bug# 6633612
 */
TYPE SERIAL_NUMBER_TBL IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

g_kf_segment_values FND_FLEX_EXT.SegmentArray;
EXISTS_ONLY            CONSTANT VARCHAR2(20) :=  'FIND_COMBINATION';

/* Bug# 3595460. Changed the operation CREATE_COMBINATION to CREATE_COMB_NO_AT */
--EXISTS_OR_CREATE       CONSTANT VARCHAR2(20) :=  'CREATE_COMBINATION';
EXISTS_OR_CREATE       CONSTANT VARCHAR2(20) :=  'CREATE_COMB_NO_AT';

/***generate the concatenated segment given the application short name like
'INV' OR 'FND' AND the key flex field code LIKE 'MTLL' and the structure
  NUMBER LIKE 101 ***/
FUNCTION concat_segments(p_appl_short_name IN VARCHAR2,
                         p_key_flex_code IN VARCHAR2,
                         p_structure_number IN NUMBER) RETURN VARCHAR2;

FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )RETURN NUMBER;

function check_creation_updation(p_created_updated_by in number,
                                 p_is_creation in number)return NUMBER;

FUNCTION Created_By(p_created_by IN NUMBER)RETURN NUMBER;

function check_date(p_date in date, p_msg in varchar2)return NUMBER;

FUNCTION Creation_Date(p_creation_date IN DATE)RETURN NUMBER;

-- Bug 4373226 added parameter transaction_date for
-- checking the conversion rate on the basis of
-- transaction date but not on sysdate
FUNCTION conversion_rate(from_org IN NUMBER,
                         to_org IN NUMBER, transaction_date DATE DEFAULT SYSDATE) RETURN NUMBER;


FUNCTION Description(p_description IN VARCHAR2)RETURN NUMBER;

/*** validates employee based on either employee id or the employee
name. If need to validate based on employee name then employee id should be
  null. It returns F if all three are null. Also, if name results in multiple
  records, gives a error asking for employee id. Passing any of the three
  will return the other two if the validation is successful.
***/
  FUNCTION Employee(p_employee_id IN OUT NOCOPY NUMBER,
                    p_last_name IN OUT NOCOPY VARCHAR2,
                    p_full_name IN OUT NOCOPY VARCHAR2,
                    p_org IN org)RETURN NUMBER;

/*** Validates a from subinventory in the context of an org and item.
 if it is an account transfer then p_acct_txn should be 1. else 0.***/
FUNCTION From_Subinventory(p_sub IN OUT NOCOPY SUB,
                           p_org IN ORG,
                           p_item IN ITEM,
                           p_acct_txn IN NUMBER)RETURN NUMBER;

/* Bug# 6633612
 * Added Overloaded From_Subinventory function for Material Status Enhancement Project
 * This function would call the existing From_Subinventory function and then
 * call inv_material_status_grp.is_status_applicable() API to check validity of status
 * for this subinventory for a given transaction type.
 */
FUNCTION From_Subinventory(p_sub IN OUT NOCOPY SUB,
                           p_org IN ORG,
                           p_item IN ITEM,
                           p_acct_txn IN NUMBER,
                           p_trx_type_id IN NUMBER, -- For Bug# 6633612
                           p_object_type IN VARCHAR2 DEFAULT 'Z'-- For Bug# 6633612
                          )RETURN NUMBER;


FUNCTION Last_Updated_By(p_last_updated_by IN NUMBER)RETURN NUMBER;

FUNCTION Last_Update_Date(p_last_update_date IN DATE)RETURN NUMBER;

FUNCTION Last_Update_Login(p_last_update_login IN NUMBER)RETURN NUMBER;

/*** Validates organization. ***/
FUNCTION Organization(p_org IN OUT nocopy ORG)RETURN NUMBER;

FUNCTION Program_Application(p_program_application_id IN NUMBER)RETURN NUMBER;

FUNCTION Program(p_program_id IN NUMBER)RETURN NUMBER;

FUNCTION Program_Update_Date(p_program_update_date IN DATE)RETURN NUMBER;

FUNCTION To_Account(p_to_account_id IN NUMBER)RETURN NUMBER;

/*** Validates a from subinventory in the context of an org and item.
 if it is an account transfer then p_acct_txn should be 1. else 0.***/
FUNCTION To_Subinventory(p_sub IN OUT NOCOPY SUB,
                         p_org IN ORG,
                         p_item IN ITEM,
                         p_from_sub IN SUB,
                         p_acct_txn IN NUMBER)RETURN NUMBER;

/* Bug# 6633612
 * Added Overloaded To_Subinventory function for Material Status Enhancement Project
 * This function would call the existing To_Subinventory function and then
 * call inv_material_status_grp.is_status_applicable() API to check validity of status
 * for this subinventory for a given transaction type.
 */
FUNCTION To_Subinventory(p_sub IN OUT NOCOPY SUB,
                         p_org IN ORG,
                         p_item IN ITEM,
                         p_from_sub IN SUB,
                         p_acct_txn IN NUMBER,
                         p_trx_type_id IN NUMBER, -- For Bug# 6633612
                         p_object_type IN VARCHAR2 DEFAULT 'Z' -- For Bug# 6633612
                        )RETURN NUMBER;


/*** Validates a given transaction_type_id and if valid returns the corresponding
  transaction_action_id and transaction_source_type_id***/
FUNCTION Transaction_Type(p_transaction_type_id IN NUMBER,
                          x_transaction_action_id OUT NOCOPY NUMBER,
                          x_transaction_source_type_id OUT NOCOPY NUMBER) RETURN NUMBER;

/*** Validates a given transaction_type ***/
FUNCTION transaction_type(x_transaction IN OUT nocopy transaction)RETURN
  NUMBER;

/*** Validates locator in context of org,item,sub. This is mainly an internal
     routine used by other public api functions. So, avoid using this. ***/
function check_locator(p_locator IN OUT nocopy locator,
                       p_org IN ORG,
                       p_item IN ITEM,
                       p_sub IN SUB,
                       p_project_id IN NUMBER,
                       p_task_id IN NUMBER,
                       p_txn_action_id IN number,
                       p_is_from_locator in NUMBER,
                       p_dynamic_ok IN BOOLEAN)RETURN NUMBER;

/*** Validates from locator in the context of an org,item,sub,project,task
    and a transaction_action ***/
FUNCTION From_Locator(p_locator IN OUT nocopy locator,
                      p_org IN ORG,
                      p_item IN ITEM,
                      p_from_sub IN SUB,
                      p_project_id IN NUMBER,
                      p_task_id IN NUMBER,
                      p_txn_action_id IN number
                      )RETURN NUMBER;

/*** Validates item in context of an org. p_validation_mode can be null. It
    is useful if one needs to validate the item using the item-flexfield
      then one needs to give the mode of validation chosen from the two
      modes listed above***/
FUNCTION inventory_item(p_item IN OUT nocopy item,
                        p_org IN org)RETURN NUMBER;
/***Added overloaded function to pass the transaction_type_id, because
we are allowing delivery of PO receipt for expense items as part of this bug***/
FUNCTION inventory_item(p_item IN OUT nocopy item,
		        p_org IN org,
			p_transaction_type IN NUMBER)RETURN NUMBER;--bug9267446

/** Validates locator in the context of an org and sub  p_validation_mode
    can be null. It is useful if one needs to validate the item using the
      item-flexfield then one needs to give the mode of validation chosen
      from the two modes listed above***/
FUNCTION validateLocator(p_locator IN OUT nocopy locator,
                         p_org IN org,
                         p_sub IN sub,
                         p_validation_mode IN VARCHAR2 DEFAULT EXISTS_ONLY,
                         p_value_or_id  IN VARCHAR2 DEFAULT 'V'
                         ) RETURN NUMBER;

/*** Validates locator in the context of an org,sub and a particular item ***/
FUNCTION validateLocator(p_locator IN OUT nocopy locator,
                 p_org IN org,
                 p_sub IN SUB,
                 p_item IN item) RETURN NUMBER;

/* Bug# 6633612
 * Added Overloaded validateLocator function for Material Status Enhancement Project
 * This function would call the existing validateLocator function and then
 * call inv_material_status_grp.is_status_applicable() API to check validity of status
 * for this subinventory, locator for a given transaction type.
 */
FUNCTION validateLocator(p_locator IN OUT nocopy locator,
                         p_org IN org,
                         p_sub IN SUB,
                         p_item IN item,
                         p_trx_type_id IN NUMBER, -- For Bug# 6633612
                         p_object_type IN VARCHAR2 DEFAULT 'L' -- For Bug# 6633612
                        ) RETURN NUMBER;


/*** Validates a lot in the context of an org,sub,item,location and item revision ***/
FUNCTION Lot_Number(p_lot IN OUT nocopy lot,
                    p_org IN ORG,
                    p_item IN ITEM,
                    p_from_sub IN SUB,
                    p_loc in LOCATOR,
                    p_revision in VARCHAR)RETURN NUMBER;

/* Bug# 6633612
 * Added Overloaded Lot_Number function for Material Status Enhancement Project
 * This function would call the existing Lot_Number function and then
 * call inv_material_status_grp.is_status_applicable() API to check validity of status
 * for this subinventory, locator, lot for a given transaction type.
 */
FUNCTION Lot_Number(p_lot IN OUT nocopy lot,
                    p_org IN ORG,
                    p_item IN ITEM,
                    p_from_sub IN SUB,
                    p_loc in LOCATOR,
                    p_revision in VARCHAR,
                    p_trx_type_id IN NUMBER, -- For Bug# 6633612
                    p_object_type IN VARCHAR2 DEFAULT 'O' -- For Bug# 6633612
                   )RETURN NUMBER;


/*** Validates a lot in the context of an org and item ***/
FUNCTION Lot_Number(p_lot IN OUT nocopy lot,
                    p_org IN ORG,
                    p_item IN ITEM)RETURN NUMBER;


/*** Validates a project ***/
FUNCTION Project(p_project_id IN NUMBER)RETURN NUMBER;

FUNCTION Quantity(p_quantity IN NUMBER)RETURN NUMBER;

FUNCTION Reason(p_reason_id IN NUMBER)RETURN NUMBER;

FUNCTION Reference(p_reference IN VARCHAR2)RETURN NUMBER;

FUNCTION Reference(p_reference_id IN NUMBER,
                   p_reference_type_code IN NUMBER) RETURN NUMBER;

FUNCTION Reference_Type(p_reference_type_code IN NUMBER)RETURN NUMBER;

/*** Validates revision of an item in the context of org and item ***/
FUNCTION Revision(p_revision IN VARCHAR2,
                  p_org IN ORG,
                  p_item IN ITEM)RETURN NUMBER;

/*** Validates serial numbers in context of org,item,sub,lot,loc. This is
mainly an internal routine used by other public api functions. So, avoid
  using this. ***/
function check_serial(p_serial IN OUT nocopy serial,
                         p_org in ORG,
                         p_item IN ITEM,
                         p_from_sub IN sub,
                         p_lot in lot,
                         p_loc in locator,
                         p_revision in VARCHAR2,
                         p_msg IN VARCHAR2,
                         p_txn_type_id IN NUMBER DEFAULT NULL) RETURN NUMBER;

/*** Validates serial number in reference to org,item,sub,lot,loc***/
function validate_serial(p_serial IN OUT nocopy serial,
                         p_org in ORG,
                         p_item IN ITEM,
                         p_from_sub IN sub,
                         p_lot in lot,
                         p_loc in locator,
                         p_revision in VARCHAR2,
                         p_txn_type_id IN NUMBER DEFAULT NULL) RETURN NUMBER;

/* Bug# 6633612
 * Added Overloaded validate_serial function for Material Status Enhancement Project
 * This function would call the existing validate_serial function and then
 * call inv_material_status_grp.is_status_applicable() API to check validity of status
 * for this subinventory, locator, lot, serial for a given transaction type.
 */
 function validate_serial(p_serial IN OUT nocopy serial,
                          p_org in ORG,
                          p_item IN ITEM,
                          p_from_sub IN sub,
                          p_lot in lot,
                          p_loc in locator,
                          p_revision in VARCHAR2,
                          p_trx_type_id IN NUMBER, -- For Bug# 6633612
                          p_object_type IN VARCHAR2 DEFAULT 'S' -- For Bug# 6633612
                         ) RETURN NUMBER;

/* Bug# 6633612
 * Added validate_serial_range function for Material Status Enhancement Project
 * This function would call the existing validate_serial function and then
 * call inv_material_status_grp.is_status_applicable() API to check validity of status
 * for this subinventory, locator, lot, serial for a given transaction type.
 */
 function validate_serial_range(p_fm_serial IN OUT nocopy SERIAL_NUMBER_TBL,
                                p_to_serial IN OUT nocopy SERIAL_NUMBER_TBL,
                                p_org in ORG,
                                p_item IN ITEM,
                                p_from_sub IN sub,
                                p_lot in lot,
                                p_loc in locator,
                                p_revision in VARCHAR2,
                                p_trx_type_id IN NUMBER, -- For Bug# 6633612
                                p_object_type IN VARCHAR2 DEFAULT 'S', -- For Bug# 6633612
                                x_errored_serials OUT nocopy SERIAL_NUMBER_TBL -- For Bug# 6633612
                               ) RETURN NUMBER;

/*** Validates starting serial number in reference to org,item,sub,lot,loc***/
FUNCTION Serial_Number_End(p_serial IN OUT nocopy serial,
                           p_org in ORG,
                           p_item IN ITEM,
                           p_from_sub IN sub,
                           p_lot in lot,
                           p_loc in Locator,
                           p_revision in VARCHAR2) RETURN NUMBER;

/*** Validates ending serial number in reference to org,item,sub,lot,loc***/
FUNCTION Serial_Number_Start(p_serial IN OUT nocopy serial,
                             p_org IN org,
                             p_item in item,
                             p_from_sub in sub,
                             p_lot in lot,
                             p_loc in Locator,
                             p_revision in VARCHAR2)RETURN NUMBER;

FUNCTION subinventory(p_sub IN OUT nocopy sub,
                      p_org IN org) RETURN NUMBER;

FUNCTION subinventory(p_sub IN OUT nocopy sub,
                      p_org IN org,
                      p_item IN item)RETURN NUMBER;

FUNCTION Task(p_task_id IN NUMBER, p_project_id IN NUMBER)RETURN NUMBER;

/*** Validates to locator in the context of an org,item,sub,project,task
    and a transaction_action ***/
FUNCTION To_Locator(p_locator IN OUT nocopy locator,
                    p_org           IN ORG,
                    p_item          IN ITEM,
                    p_to_sub        IN SUB,
                    p_project_id    IN NUMBER,
                    p_task_id       IN NUMBER,
                    p_txn_action_id IN number)RETURN NUMBER;

FUNCTION Transaction_Header(p_transaction_header_id IN NUMBER)RETURN NUMBER;

FUNCTION HR_Location(p_hr_location IN NUMBER) RETURN NUMBER;

/*** Validates the txn uom in the context of an org and an item ***/
FUNCTION Uom(p_uom_code IN VARCHAR2,
             p_org IN ORG,
             p_item IN ITEM)RETURN NUMBER;

--  END GEN validate
PROCEDURE NUMBER_FROM_SEQUENCE (
        p_sequence    IN   VARCHAR2,
        x_prefix     OUT   NOCOPY VARCHAR2,
        x_number     OUT   NOCOPY NUMBER
);

FUNCTION Cost_Group(p_cost_group_id IN NUMBER,
                     p_org_id IN NUMBER) return NUMBER;

FUNCTION LPN(p_lpn_id IN NUMBER) RETURN NUMBER;
--INVCONV
FUNCTION Secondary_Quantity(p_secondary_quantity IN NUMBER)RETURN NUMBER;
--INVCONV

--Start of new code added as part of eIB Build. Bug# 4348541
PROCEDURE check_pending_transaction(
  p_transaction_type_id IN NUMBER,
  p_pending_tran_flag   OUT NOCOPY NUMBER);
PROCEDURE check_location_required_setup(
  p_transaction_type_id IN NUMBER,
  p_required_flag       OUT NOCOPY VARCHAR2);
--End of new code added as part of eIB Build. Bug# 4348541

END INV_Validate;

/
