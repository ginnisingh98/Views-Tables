--------------------------------------------------------
--  DDL for Package Body CST_ITEM_COST_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ITEM_COST_IMPORT_INTERFACE" as
/* $Header: CSTCIMPB.pls 120.0.12010000.2 2008/10/29 14:56:06 prashkum ship $ */

PROCEDURE validate_phase1(Error_number OUT NOCOPY NUMBER
                          ,i_new_csttype IN VARCHAR2
                          ,i_group_id IN NUMBER
                          ) IS

SEQ_NEXTVAL NUMBER:=0;
l_org_id NUMBER := 0;
l_stmt_no NUMBER := 0;
CONC_REQUEST BOOLEAN;
Err NUMBER;
CST_ERROR_EXCEPTION EXCEPTION;
BEGIN

Error_number := 0;

SEQ_NEXTVAL := i_group_id;

/* This part populates the Organization_id if it has not been provided by
the user.There will be a check done to see if the user has not entered both of t
hem */

fnd_file.put_line(fnd_file.log, '---------start of the concurrent program for validating CICDI-------------');

l_stmt_no := 10;

Update CST_ITEM_CST_DTLS_INTERFACE ct
SET error_flag = 'E',
    error_code = 'CST_NULL_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_ORGANIZATION'),1,240)
where (Organization_id is null AND organization_code is null)
AND error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

l_stmt_no := 20;

/* check to see if the user has input a valid organization_id or code if he has
entered the organization_id */

Update CST_ITEM_CST_DTLS_INTERFACE ct
SET error_flag = 'E',
    error_code = 'CST_INVALID_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ORGANIZATION'),1,240)
WHERE ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from mtl_parameters mp
                where (NVL(ct.organization_id,mp.organization_id) = mp.organization_id)
                AND (NVL(ct.organization_code,mp.organization_code) = mp.organization_code)
               );

l_stmt_no := 30;

fnd_file.put_line(fnd_file.log, 'after checking for organization_id validity');

/* Select the corresponding organization_id from mtl_parameters given the
  organization code.*/

Update CST_ITEM_CST_DTLS_INTERFACE ct
SET organization_id = (select organization_id
                       FROM mtl_parameters mp
                       WHERE mp.organization_code = ct.organization_code
                       )
WHERE ct.organization_id is null
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

/* OPM INVCONV project to bypass all process orgs in Discrete programs
** umoogala  09-nov-2004 Bug# 3980701
**/

l_stmt_no := 35;

Update CST_ITEM_CST_DTLS_INTERFACE ct
SET error_flag = 'E',
    error_code = 'CST_PROCESS_ORG_ERROR',
    error_explanation =
substrb(fnd_message.get_string(
    'GMF','GMF_PROCESS_ORG_ERROR'),1,240)
WHERE ct.error_flag is null
AND   ct.group_id = SEQ_NEXTVAL
AND EXISTS (select 'This is a process manufacturing org'
            from   mtl_parameters mp
            where  mp.organization_id = ct.organization_id
            AND    NVL(mp.process_enabled_flag, 'N') = 'Y'
           )
;
/* End OPM INVCONV changes */

l_stmt_no := 40;

/* Set the unique transaction_id for each row */
Update CST_ITEM_CST_DTLS_INTERFACE
SET transaction_id = CST_ITEM_CST_DTLS_INTERFACE_S.NEXTVAL,
    request_id = FND_GLOBAL.CONC_REQUEST_ID,
    error_code = null,
    error_explanation = null,
    program_application_id = FND_GLOBAL.PROG_APPL_ID,
    program_id = FND_GLOBAL.CONC_PROGRAM_ID,
    program_update_date = sysdate,
    process_flag = 2
where error_flag is null
AND process_flag = 1
AND group_id=SEQ_NEXTVAL;

commit;

l_stmt_no := 60;
fnd_file.put_line(fnd_file.log,'after assigning the  transaction_id');

/* check for the organization to be a costing organization */

UPDATE CST_ITEM_CST_DTLS_INTERFACE ct
SET ct.error_flag ='E',
    ct.error_code = 'CST_NOT_COSTINGORG',
    ct.error_explanation = substrb(fnd_message.get_string('BOM','CST_NOT_COSTINGORG'),1,240)
WHERE ct.group_id = SEQ_NEXTVAL
AND ct.error_flag is null
AND EXISTS (Select 1 from MTL_PARAMETERS mp
                WHERE mp.cost_organization_id <> mp.organization_id
                AND mp.organization_id = ct.organization_id );

l_stmt_no := 61;
fnd_file.put_line(fnd_file.log,'done checking for the org to be costing org');

/* check to see if the user has input a valid inventory_item_id */
Update CST_ITEM_CST_DTLS_INTERFACE ct set
   error_flag = 'E',
   error_code = 'CST_NULL_ITEMID',
   error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_ITEMID'),1,240)
where group_id = SEQ_NEXTVAL
AND error_flag is null
AND inventory_item_id is null;

l_stmt_no := 62;

fnd_file.put_line(fnd_file.log,'done checking for null item_id');

/* check to see if the user has input a valid inventory_item_id */
Update CST_ITEM_CST_DTLS_INTERFACE ct set
   error_flag = 'E',
   error_code = 'CST_INVALID_ITEM_ID',
   error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ITEMID'),1,240)
where group_id = SEQ_NEXTVAL
AND error_flag is null
AND  NOT EXISTS (select 1 from mtl_system_items msi
                 where ct.organization_id = msi.organization_id
                 AND ct.inventory_item_id = msi.inventory_item_id
                 );
fnd_file.put_line(fnd_file.log,'done checking for invalid inventory_item_id');
l_stmt_no := 63;

/* Now call the function to set the defaults for the CIC flags */

insert_csttype_and_def(Err,i_new_csttype,i_group_id);

IF Err = 1 then
 raise CST_ERROR_EXCEPTION;
END IF;

/*check for the inventory asset flag to be yes */

Update CST_ITEM_CST_DTLS_INTERFACE ct
set ct.error_flag='E',
    ct.error_code = 'CST_NOT_INVASSITEM',
    ct.error_explanation = substrb(fnd_message.get_string('BOM','CST_NOT_INVASSITEM'),1,240)
WHERE ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL
AND ((ct.inventory_asset_flag <> 1)
     OR EXISTS(select 1 from mtl_system_items msi
               where msi.inventory_item_id = ct.inventory_item_id
               and msi.organization_id = ct.organization_id
               and msi.inventory_asset_flag = 'N'
         ));

l_stmt_no := 66;
fnd_file.put_line(fnd_file.log,'done checking for the inventory_asset flag');


l_stmt_no := 70;


/* check to see if the cost_element_id and cost element are both null */

Update CST_ITEM_CST_DTLS_INTERFACE
SET error_flag = 'E',
    error_code = 'CST_NULL_COSTELEMENT',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_COSTELEMENT'),1,240)
where (cost_element_id is null AND cost_element is null)
AND group_id = SEQ_NEXTVAL
AND error_flag is null;

l_stmt_no := 90;

fnd_file.put_line(fnd_file.log,'after checking for cost element for null');


/* Check to see if a valid cost_element has been provided.If only the cost_element_name is provided then, fill up the id */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  error_flag = 'E',
  error_code = 'CST_INVALID_COSTELEMENT',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_COSTELEMENT'),1,240)
WHERE group_id = SEQ_NEXTVAL
AND error_flag is null
AND NOT EXISTS( Select 1 from cst_cost_elements cce where
                NVL(ct.cost_element_id,cce.cost_element_id)= cce.cost_element_id                AND NVL(ct.cost_element,cce.cost_element) = cce.cost_element
               );

l_stmt_no := 140;

Update CST_ITEM_CST_DTLS_INTERFACE ct set
ct.cost_element_id = (select cost_element_id from cst_cost_elements cce
                      WHERE cce.cost_element = ct.cost_element)
WHERE ct.cost_element_id is null
AND ct.group_id = SEQ_NEXTVAL
AND ct.error_flag is null;

l_stmt_no := 150;

fnd_file.put_line(fnd_file.log,'done checking for cost elements validity and picking up the cost element id if it has not been defined');


/*----------Checking for sub elements validity--------------------------*/
/* There is a special case when checking for the resource id validation.*/


/* check if the provided sub element id(not the default) or code exists and is valid*/

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  error_flag = 'E',
  error_code = 'CST_INVALID_SUBELEMENT',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_SUBELEMENT'),1,240)
WHERE error_flag is null
AND ct.group_id = SEQ_NEXTVAL
AND (ct.resource_id is NOT NULL OR ct.resource_code is not null)
AND NOT EXISTS (select 1 from bom_resources bm
                WHERE NVL(ct.resource_id,bm.resource_id)=bm.resource_id
                AND NVL(ct.resource_code,bm.resource_code)=bm.resource_code
                AND ct.cost_element_id = bm.cost_element_id
                AND ct.organization_id = bm.organization_id
               );

l_stmt_no := 160;


Update CST_ITEM_CST_DTLS_INTERFACE ct
set ct.resource_id = (select bm.resource_id from bom_resources bm
                      WHERE ct.resource_code = bm.resource_code
                      AND bm.organization_id = ct.organization_id
                      AND ct.cost_element_id = bm.cost_element_id
                     )
WHERE ct.resource_id is null
AND ct.resource_code is not null
and ct.error_flag is null
and ct.group_id = SEQ_NEXTVAL;


l_stmt_no := 170;

fnd_file.put_line(fnd_file.log,'done checking for validity of resource_id and picking it up if it has not been supplied');

/* Checking for the validity of Activity ID  and Activity name if provided */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  error_flag = 'E',
  error_code = 'CST_INVALID_ACTIVITY',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ACTIVITY'),1,240)
WHERE group_id = SEQ_NEXTVAL
AND ((ct.activity_id is not null ) OR (ct.activity is not null))
AND error_flag is null
AND NOT EXISTS( Select 1 from cst_activities ca where
                NVL(ct.activity_id,ca.activity_id)= ca.activity_id                               AND NVL(ct.activity,ca.activity) = ca.activity
                AND ct.organization_id = NVL(ca.organization_id,ct.organization_id)
                AND NVL(ca.disable_date,sysdate +1) > sysdate
               );

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  ct.activity_id = (select ca.activity_id from cst_activities ca
                    where ca.activity = ct.activity
                    AND NVL(ca.organization_id,ct.organization_id) = ct.organization_id
                   )
WHERE ct.activity_id is NULL
AND ct.activity is not null
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for activity ID and assigning it');

l_stmt_no := 180;


/* Now start setting the resource id to corresponding default id */


Update CST_ITEM_CST_DTLS_INTERFACE ct set
resource_id = (Select Decode(ct.cost_element_id,1,mp.default_material_cost_id,null) from mtl_parameters mp  where mp.organization_id = ct.organization_id)
WHERE error_flag is null
AND ct.group_id = SEQ_NEXTVAL
AND (ct.resource_id is null AND ct.resource_code is null);

l_stmt_no := 190;

fnd_file.put_line(fnd_file.log,'done assigning default sub elements');

/* if the resource_id is still null,then that means the user has not provided
a default sub element that is necessary */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
 error_flag = 'E',
 error_code = 'CST_NULL_DEFSUBELEMENT',
 error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_DEFSUBELEMENT'),1,240)
WHERE error_flag is null
AND ct.group_id = SEQ_NEXTVAL
and resource_id is null;

l_stmt_no := 200;

/* check for the validity date for the sub elements */

Update CST_ITEM_CST_DTLS_INTERFACE ct
set ct.error_flag = 'E',
    ct.error_code = 'CST_EXP_SUBELEMENT',
    ct.error_explanation = substrb(fnd_message.get_string('BOM','CST_EXP_SUBELEMENT'),1,240)
where ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL
AND EXISTS (select 1 from BOM_RESOURCES bm
            where bm.organization_id = ct.organization_id
            AND bm.cost_element_id = ct.cost_element_id
            AND bm.resource_id = ct.resource_id
            AND ((sysdate >= NVL(bm.disable_date,sysdate+1)) OR (bm.allow_costs_flag = 2)));

fnd_file.put_line(fnd_file.log,'done checking for the disable_date  and allow_costs_flag for the resource');
l_stmt_no := 205;

/* at this point we have validated org_id,cost_type,cost element,resource
   ,inventory_item.We will now have to check if the functional currency flag =1
    for the resource and outside processing sub elements */

Update CST_ITEM_CST_DTLS_INTERFACE ct
set error_flag = 'E',
    error_code = 'CST_INVALID_FUNCCODE',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_FUNCCODE'),1,240)
WHERE error_flag is null
AND ct.group_id = SEQ_NEXTVAL
AND ct.cost_element_id IN (3,4)
AND NOT EXISTS (select 1 from bom_resources bm
                where bm.functional_currency_flag = 1
                AND bm.resource_id = ct.resource_id
                AND bm.cost_element_id = ct.cost_element_id
                AND bm.organization_id = ct.organization_id
               );

l_stmt_no := 210;

fnd_file.put_line(fnd_file.log,'done checking for functional currency flag');


/* set The process_flag to 2 */

Update CST_ITEM_CST_DTLS_INTERFACE set
process_flag = 3 where
      group_id=SEQ_NEXTVAL
      AND error_flag is null
      AND process_flag = 2;

l_stmt_no := 230;

fnd_file.put_line(fnd_file.log,'done with validations for first phase of CICDI');

COMMIT;

EXCEPTION

    when others then
      rollback;
      CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',(fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')));
      fnd_file.put_line(fnd_file.log,'CICDI validate_phase1(' || to_char(l_stmt_no) || '),' || to_char(SQLCODE) || ',' || substr(SQLERRM,1,180));
     Error_number := 1;

END validate_phase1;


PROCEDURE validate_phase2 (Error_number OUT NOCOPY NUMBER,i_group_id IN NUMBER) as

SEQ_NEXTVAL NUMBER := 0;
l_stmt_no NUMBER := 0;
CONC_REQUEST BOOLEAN;
BEGIN

Error_number := 0;

fnd_file.put_line(fnd_file.log,'------------Start of the second phase for CICDI-----------');


SEQ_NEXTVAL := i_group_id;
/* This statement will check for the rollup_source_type flag to be 1 */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  Error_flag = 'E',
  error_code = 'CST_INVALID_ROLLUP_SRC_TYPE',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ROLLUP_SRC_TYPE'),1,240)
where rollup_source_type <> 1
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;


l_stmt_no := 10;

/* This statement will check up for the level_type = 1(THIS level only) */

UPDATE CST_ITEM_CST_DTLS_INTERFACE ct set
  Error_flag = 'E',
  error_code = 'CST_INVALID_LEVELTYPE',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_LEVELTYPE'),1,240)
where level_type <> 1
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for level_type flag to be 1 ');

l_stmt_no := 11;

/* checking for the Usage rate or amount to be not null */
UPDATE CST_ITEM_CST_DTLS_INTERFACE ct set
  Error_flag = 'E',
  error_code = 'CST_NULL_USAGERTORAMT',
  Error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_USAGERTORAMT'),1,240)
where error_flag is null
AND Usage_rate_or_amount is null
AND group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for null usage rate');

/*This statement checks for the validity of basis types.
FOr any other basis type other than material overhead, the only basis types allowed are item and lot.
But for material Overhead all 6 basis types allowed.This is inkeeping with the way the form works today.
 */

l_stmt_no := 12;

Update CST_ITEM_CST_DTLS_INTERFACE ct set
 Error_flag = 'E',
 error_code = 'CST_INVALID_BASISTYPE',
 error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_BASISTYPE'),1,240)
where ((ct.cost_element_id IN (1,3,4,5,6) AND ct.basis_type NOT IN (1,2)) OR (ct.cost_element_id = 2 AND (ct.basis_type <= 0 OR ct.basis_type > 6)))
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for basis types');

/* If the basis type is activity, then check if the item_units and activity_units are provided */

l_stmt_no := 13;

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  Error_flag = 'E',
  error_code ='CST_NO_ITORACUNITS',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_NO_ITORACUNITS'),1,240)
where ct.basis_type = 6
AND (ct.activity_units is null OR ct.item_units is null OR ct.item_units = 0)
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for item units and activity units');

l_stmt_no := 14;
/*this statement checks for the shrinkage rate value to be between 0 and 1 */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  error_flag = 'E',
  error_code = 'CST_INVALID_SHRRATE',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_SHRRATE'),1,240)
where (ct.shrinkage_rate < 0 OR ct.shrinkage_rate >= 1)
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for shrinkage rate to be between 0 and 1');
l_stmt_no := 15;

/* check for the lot_size to be > 0 */
Update CST_ITEM_CST_DTLS_INTERFACE ct set
  error_flag = 'E',
  error_code = 'CST_ZERO_LOTSIZE',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_ZERO_LOTSIZE'),1,240)
where error_flag is null
AND group_id = SEQ_NEXTVAL
AND ct.lot_size <= 0;

/*this checks for the based on rollup flag to be 1 or 2 */
Update CST_ITEM_CST_DTLS_INTERFACE ct set
   error_flag = 'E',
   error_code = 'CST_INVALID_BASEDONRLP',
   error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_BASEDONRLP'),1,240)
where ct.based_on_rollup_flag NOT IN (1,2)
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

l_stmt_no := 16;
fnd_file.put_line(fnd_file.log,'done checking for based on rollup flag');

/* this checks for the inventory asset flag to be 1 or 2 */
Update CST_ITEM_CST_DTLS_INTERFACE  ct set
  error_flag = 'E',
  error_code = 'CST_INVALID_INVASSETFLG',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_INVASSETFLG'),1,240)
where ct.inventory_asset_flag NOT IN (1,2)
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

l_stmt_no := 18;
fnd_file.put_line(fnd_file.log,'done checking for inv asset flag to be 1 or 2');

UPDATE CST_ITEM_CST_DTLS_INTERFACE set
  error_flag = 'E',
  error_code = 'CST_INVALID_RESRATE',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_RESRATE'),1,240)
where error_flag is null
AND group_id = SEQ_NEXTVAL
AND ((resource_rate <> 1) AND (resource_rate is not null));

fnd_file.put_line(fnd_file.log, 'done checking for resource rate to be 1 or null');

/* this statement checks for the based_on_rollup flag to be set if there is a shrinkage rate mentioned*/

Update CST_ITEM_CST_DTLS_INTERFACE ct set
   error_flag = 'E',
   error_code = 'CST_INVALID_BUYITEM',
   error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_BUYITEM'),1,240)
where ct.based_on_rollup_flag <> 1
AND ct.shrinkage_rate <> 0
AND ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for the based on rollup flag and shrinkage rate');

l_stmt_no := 20;
/* this statement checks for the same "based_on_rollup_flag, shrinkage_rate,inventory_asset_flag" to be populated for all the rows of the same item,org,cost type combo */

Update CST_ITEM_CST_DTLS_INTERFACE ct1 set
  Error_flag = 'E',
  error_code = 'CST_INVALID_CICFLAGS',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_CICFLAGS'),1,240)
where EXISTS (select 1 from CST_ITEM_CST_DTLS_INTERFACE ct2 where
              ((NVL(ct1.based_on_rollup_flag,-1)<> NVL(ct2.based_on_rollup_flag,-1))
              OR (NVL(ct1.shrinkage_rate,-1) <> NVL(ct2.shrinkage_rate,-1))
              OR (NVL(ct1.inventory_asset_flag,-1) <> NVL(ct2.inventory_asset_flag,-1))
              OR (NVL(ct1.lot_size,-1) <> NVL(ct2.lot_size,-1)))
              AND ct1.organization_id = ct2.organization_id
              AND ct1.inventory_item_id = ct2.inventory_item_id
              AND ct1.cost_type_id = ct2.cost_type_id
              AND ct2.group_id = SEQ_NEXTVAL
              AND ct1.rowid <> ct2.rowid
             )
AND ct1.group_id = SEQ_NEXTVAL
AND ct1.error_flag is null;

l_stmt_no := 30;

fnd_file.put_line(fnd_file.log,'done checking for the 4 flags to match for all the rows of the same item,org,cost type combo');

/* Error out all those rows for that particular item,org,cost type combination
that already have rows that are errored out */


Update CST_ITEM_CST_DTLS_INTERFACE ct1
set ERROR_FLAG ='E',
    error_code = 'CST_INVALID_ROWS',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ROWS'),1,240)
WHERE EXISTS ( select 1 from CST_ITEM_CST_DTLS_INTERFACE ct2
               WHERE ct1.organization_id = ct2.organization_id
               AND ct1.inventory_item_id = ct2.inventory_item_id
               AND ct1.cost_type_id = ct2.cost_type_id
               AND ct2.error_flag = 'E'
               AND ct2.group_id = SEQ_NEXTVAL)
AND ct1.error_flag is null
AND ct1.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done erroring out rows for the same item,org,cost type combo if even one of them has errored out');

l_stmt_no := 40;

Update CST_ITEM_CST_DTLS_INTERFACE set
process_flag = 4 where
      group_id=SEQ_NEXTVAL
      AND error_flag is null
      AND process_flag = 3;

COMMIT;

EXCEPTION

  when others then
      rollback;
      fnd_file.put_line(fnd_file.log,'CICDI table validate_phase2(' || to_char(l_stmt_no) || '),' || to_char(SQLCODE) || ',' || substr(SQLERRM,1,180));

      CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',(fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')));
   Error_number := 1;

END  validate_phase2;

Procedure insert_csttype_and_def(Error_number OUT NOCOPY NUMBER
                                 ,i_new_csttype IN Varchar2
                                 ,i_group_id IN NUMBER
                                 ) is

l_stmt_no NUMBER := 0;
l_def_cost_type_id NUMBER;
l_cost_type_id NUMBER;
SEQ_NEXTVAL NUMBER;
i_count NUMBER := 0;
CONC_REQUEST BOOLEAN;
BEGIN

SEQ_NEXTVAL := i_group_id;
l_stmt_no := 10;

Error_number := 0;

fnd_file.put_line(fnd_file.log,'-------------at the start of insert_csttype_and_def procedure-----------');

Select default_cost_type_id  into l_def_cost_type_id from cst_cost_types
where cost_type = i_new_csttype;

select cost_type_id into l_cost_type_id
from CST_COST_TYPES
where cost_type = i_new_csttype;

l_stmt_no := 20;

/* Now update all the rows of the interface table with the new cost type id */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  ct.cost_type_id = l_cost_type_id,
  ct.cost_type = i_new_csttype
where error_flag is null
and group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done updating the interface table with the new cost type');
l_stmt_no := 30;

/*check for the default cost type to be valid for all the or/item combo */
Update CST_ITEM_CST_DTLS_INTERFACE ct set
   error_flag ='E',
   error_code = 'CST_INVALID_DEFCSTTYPE',
   error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_DEFCSTTYPE'),1,240)
where
   ct.error_flag is null
   and ct.group_id = SEQ_NEXTVAL
   and NOT EXISTS (select 1 from cst_item_costs cic where
                   ct.organization_id = cic.organization_id
                   and cic.cost_type_id = l_def_cost_type_id
                   and ct.inventory_item_id = cic.inventory_item_id)
   AND (ct.lot_size is null OR ct.based_on_rollup_flag is null OR shrinkage_rate is null OR inventory_asset_flag is null) ;

fnd_file.put_line(fnd_file.log,'done checking for the default cost type to be valid');
l_stmt_no := 40;

/* now set the defaults for rollup_src_type,basis_type,resource_rate and level_type */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
   rollup_source_type = NVL(ct.rollup_source_type,1),
   basis_type = NVL(basis_type,1),
   resource_rate = NVL(resource_rate,1),
   level_type = NVL(ct.level_type,1)
where error_flag is null
and group_id= SEQ_NEXTVAL
and (rollup_source_type is null OR basis_type is null OR resource_rate is null OR level_type is null);

fnd_file.put_line(fnd_file.log,'done setting the defaults for the first level ');
l_stmt_no := 50;

/* now set the defaults from cic for the CIC columns */

Update CST_ITEM_CST_DTLS_INTERFACE ct set
  (lot_size,based_on_rollup_flag,shrinkage_rate,inventory_asset_flag) =
  (Select  NVL(ct.lot_size,cic.lot_size),
           NVL(ct.based_on_rollup_flag,cic.based_on_rollup_flag),
           NVL(ct.shrinkage_rate,cic.shrinkage_rate),
           NVL(ct.inventory_asset_flag,cic.inventory_asset_flag)
   FROM CST_ITEM_COSTS cic
   WHERE cic.organization_id = ct.organization_id
   AND cic.cost_type_id = l_def_cost_type_id
   AND cic.inventory_item_id = ct.inventory_item_id )
WHERE ct.error_flag is null
AND ct.group_id = SEQ_NEXTVAL
AND (ct.lot_size is null OR ct.based_on_rollup_flag is null OR ct.inventory_asset_flag is null OR ct.shrinkage_rate is null);

fnd_file.put_line(fnd_file.log,'done setting the defaults for the CIC columns');

EXCEPTION
  when others then
    rollback;
    fnd_file.put_line(fnd_file.log,'CICDI insert_csttype_and_def('|| to_char(l_stmt_no) || '),' || to_char(SQLCODE) || ',' || substr(SQLERRM,1,180));

      CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',(fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')));
 Error_number := 1;

END insert_csttype_and_def;

Procedure insert_cic_cicd(Error_number OUT NOCOPY NUMBER,
                          i_group_id IN NUMBER,
                          i_del_option IN NUMBER,
                          i_run_option IN NUMBER) is

SEQ_NEXTVAL NUMBER;
l_stmt_no NUMBER := 0;
l_count NUMBER := 0;
CONC_REQUEST BOOLEAN;
BEGIN

SEQ_NEXTVAL := i_group_id;
l_stmt_no := 10;

Error_number := 0;

 /*first get the net_yield and basis_factor and update the interface tables */

fnd_file.put_line(fnd_file.log,'---------------entered the insert_cic_cicd procedure-----------------');

/* The following statement sets the basis factor and net_yield_or_shrinkage_factor.
   The basis factor will be set to values like the form does today in the applications */

Update CST_ITEM_CST_DTLS_INTERFACE set
    basis_factor = Decode(basis_type,1,1,2,(1/lot_size),6,(Activity_units/item_units))
where error_flag is null
and group_id = SEQ_NEXTVAL
and basis_type IN (1,2,6);

l_stmt_no := 11;

fnd_file.put_line(fnd_file.log,'done setting the basis factor for basis type 1,2 and 6');

/* Updating the basis factor for mat overhead cost element, sub element "resource unit"*/

Update CST_ITEM_CST_DTLS_INTERFACE cicdi1 set
 cicdi1.basis_factor = (select NVL(SUM(cicdi2.usage_rate_or_amount * cicdi2.basis_factor),0) from CST_ITEM_CST_DTLS_INTERFACE cicdi2
                        WHERE cicdi2.organization_id = cicdi1.organization_id
                        AND   cicdi2.inventory_item_id = cicdi1.inventory_item_id
                        AND  cicdi2.cost_type_id = cicdi1.cost_type_id
                        AND cicdi2.cost_element_id in (3,4)
                        AND cicdi2.error_flag is null
                        AND cicdi2.group_id = SEQ_NEXTVAL
                        AND EXISTS (select 1 from CST_RESOURCE_OVERHEADS cro
                                    WHERE cro.cost_type_id = cicdi1.cost_type_id
                                    AND cro.organization_id = cicdi1.organization_id
                                    AND cro.overhead_id = cicdi1.resource_id
                                    AND cro.resource_id = cicdi2.resource_id))
WHERE cicdi1.error_flag is null
AND cicdi1.group_id = SEQ_NEXTVAL
AND cicdi1.basis_type = 3
AND cicdi1.cost_element_id=2;

l_stmt_no := 12;

fnd_file.put_line(fnd_file.log,'done setting the basis factor for basis type of 3 (resource unit)');


Update CST_ITEM_CST_DTLS_INTERFACE CICDI set
   net_yield_or_shrinkage_factor = Decode(basis_type,1,(1/(1-shrinkage_rate)),2,(1/(1-shrinkage_rate)),3,(1/(1-shrinkage_rate)),1)
where error_flag is null
and group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done setting shrinkage factor');
l_stmt_no :=20;

/* now calculate the item cost for each row for basis */

Update CST_ITEM_CST_DTLS_INTERFACE set
  item_cost = NVL(usage_rate_or_amount,0) * NVL(basis_factor,1) * NVL(net_yield_or_shrinkage_factor,1) * NVL(resource_rate,1)
where basis_type IN (1,2,3,6)
AND error_flag is null
and group_id = SEQ_NEXTVAL;

l_stmt_no := 22;

fnd_file.put_line(fnd_file.log,'done setting the item cost for basis types 1,2,3 and 6');

/*Now calculate the basis factor and item cost for resource value */

Update CST_ITEM_CST_DTLS_INTERFACE cicdi1
set (cicdi1.basis_factor,cicdi1.item_cost) = (
       select  NVL(SUM(cicdi2.item_cost),0),(cicdi1.usage_rate_or_amount * NVL(SUM(cicdi2.item_cost),0)) from CST_ITEM_CST_DTLS_INTERFACE cicdi2
       WHERE cicdi2.inventory_item_id = cicdi1.inventory_item_id
       AND cicdi2.organization_id = cicdi1.organization_id
       AND cicdi2.cost_type_id = cicdi1.cost_type_id
       AND cicdi2.error_flag is null
       AND cicdi2.group_id = SEQ_NEXTVAL
       AND cicdi2.cost_element_id IN (3,4)
       AND EXISTS ( select 1 from CST_RESOURCE_OVERHEADS cro
                    WHERE cro.organization_id = cicdi2.organization_id
                    AND cro.cost_type_id = cicdi2.cost_type_id
                    AND cro.overhead_id = cicdi1.resource_id
                    AND cro.resource_id = cicdi2.resource_id))
 WHERE cicdi1.error_flag is null
 AND cicdi1.group_id = SEQ_NEXTVAL
 AND cicdi1.basis_type = 4
 AND cicdi1.cost_element_id = 2;

l_stmt_no := 23;
fnd_file.put_line(fnd_file.log,'done setting the basis factor and item cost for basis type resource value ');

/* Now calculate the basis factor and item cost for total value based */

Update CST_ITEM_CST_DTLS_INTERFACE cicdi1
set (cicdi1.basis_factor,cicdi1.item_cost) = (
      select /*+ INDEX(cicdi2 CST_ITEM_CST_DTLS_INTERFACE_N1)*/
      NVL(SUM(cicdi2.item_cost),0),(cicdi1.usage_rate_or_amount * NVL(SUM(cicdi2.item_cost),0)) from CST_ITEM_CST_DTLS_INTERFACE cicdi2
      WHERE cicdi2.organization_id = cicdi1.organization_id
      AND cicdi2.inventory_item_id = cicdi1.inventory_item_id
      AND cicdi2.cost_type_id = cicdi1.cost_type_id
      AND cicdi2.error_flag is null
      AND cicdi2.group_id = SEQ_NEXTVAL
      AND cicdi2.cost_element_id <> 2)
 WHERE cicdi1.error_flag is null
 AND cicdi1.group_id = SEQ_NEXTVAL
 AND cicdi1.basis_type = 5
 AND cicdi1.cost_element_id = 2;


fnd_file.put_line(fnd_file.log,'done calculating the item cost and basis factor for total value basis type');
l_stmt_no := 30;
/* Now insert first into cst_item_costs */

/* here we check for the run option.If it is insert only mode, we error out those rows for which rows already exist in CIC for the same item,org,cost type combo.For rem and replace mode, we just delete off all the existing rows and proceed */

IF i_run_option = 2 then
  delete from cst_item_costs cic
  WHERE (ORGANIZATION_ID,INVENTORY_ITEM_ID,COST_TYPE_ID) in
   (Select ORGANIZATION_ID,INVENTORY_ITEM_ID,COST_TYPE_ID
	   from CST_ITEM_CST_DTLS_INTERFACE ct
	   WHERE ct.error_flag is null
	         AND ct.group_id = SEQ_NEXTVAL);

  delete from cst_item_cost_details cicd
  WHERE (ORGANIZATION_ID,INVENTORY_ITEM_ID,COST_TYPE_ID) in
    (Select ORGANIZATION_ID,INVENTORY_ITEM_ID,COST_TYPE_ID
	   from CST_ITEM_CST_DTLS_INTERFACE ct
	   WHERE ct.error_flag is null
	         AND ct.group_id = SEQ_NEXTVAL);


ELSIF i_run_option = 1  then

   UPDATE CST_ITEM_CST_DTLS_INTERFACE ct set
      ct.error_flag ='E',
      ct.error_code = 'CST_CANT_INSERT',
      ct.error_explanation = substrb(fnd_message.get_string('BOM','CST_CANT_INSERT'),1,240)
   WHERE ct.error_flag is null
   AND ct.group_id = SEQ_NEXTVAL
   AND EXISTS(Select 1 from cst_item_costs cic
               WHERE ct.organization_id = cic.organization_id
               AND ct.cost_type_id = cic.cost_type_id
               AND ct.inventory_item_id = cic.inventory_item_id);
END IF;

fnd_file.put_line(fnd_file.log,'done checking for the run option and deleting or erroring out rows accordingly');

l_stmt_no := 35;

Insert into CST_ITEM_COSTS (Inventory_item_id,
                            organization_id,
                            cost_type_id,
                            Last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            Inventory_asset_flag,
                            lot_size,
                            based_on_rollup_flag,
                            shrinkage_rate,
                            defaulted_flag,
                            Pl_material,
                            pl_material_overhead,
                            pl_resource,
                            pl_outside_processing,
                            pl_overhead,
                            tl_material,
                            tl_material_overhead,
                            tl_resource,
                            tl_outside_processing,
                            tl_overhead,
                            material_cost,
                            material_overhead_cost,
                            resource_cost,
                            outside_processing_cost,
                            overhead_cost,
                            pl_item_cost,
                            tl_item_cost,
                            item_cost,
                            unburdened_cost,
                            burden_cost,
                            request_id,
                            program_application_id,
                            program_id,
                            program_update_date)
                   Select Inventory_item_id,
                          organization_id,
                          cost_type_id,
                          sysdate,
                          FND_GLOBAL.USER_ID,
                          sysdate,
                          FND_GLOBAL.USER_ID,
                          inventory_asset_flag,
                          lot_size,
                          based_on_rollup_flag,
                          shrinkage_rate,
                          2,
                          0,
                          0,
                          0,
                          0,
                          0,
                          SUM(decode(ct.cost_element_id,1,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,2,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,3,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,4,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,5,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,1,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,2,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,3,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,4,ct.item_cost,null)),
                          SUM(decode(ct.cost_element_id,5,ct.item_cost,null)),
                          0,
                          SUM(item_cost),
                          SUM(item_cost),
                          (SUM(item_cost) - SUM(decode(ct.cost_element_id,2,ct.item_cost,0))),
                          SUM(decode(ct.cost_element_id,2,ct.item_cost,null)),
                          FND_GLOBAL.CONC_REQUEST_ID,
                          FND_GLOBAL.PROG_APPL_ID,
                          FND_GLOBAL.CONC_PROGRAM_ID,
                          sysdate
                          FROM CST_ITEM_CST_DTLS_INTERFACE ct
                          WHERE error_flag is null
                          AND group_id = SEQ_NEXTVAL
                          group by organization_id,inventory_item_id,cost_type_id,based_on_rollup_flag,shrinkage_rate,lot_size,inventory_asset_flag;

fnd_file.put_line(fnd_file.log,'after the insert into CIC');
fnd_file.put_line(fnd_file.log,'sucessfully completed inserting ' || to_char(SQL%ROWCOUNT)|| ' rows into cic');
l_stmt_no :=  40;

/* Now insert into CICD */

INSERT INTO CST_ITEM_COST_DETAILS(Inventory_item_id,
                                  organization_id,
                                  cost_type_id,
                                  last_update_date,
                                  last_updated_by,
                                  creation_date,
                                  created_by,
                                  level_type,
                                  activity_id,
                                  resource_id,
                                  resource_rate,
                                  item_units,
                                  activity_units,
                                  usage_rate_or_amount,
                                  basis_type,
                                  basis_factor,
                                  net_yield_or_shrinkage_factor,
                                  item_cost,
                                  cost_element_id,
                                  rollup_source_type,
                                  activity_context,
                                  Request_id,
                                  program_application_id,
                                  program_id,
                                  program_update_date,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15)
                           SELECT inventory_item_id,
                                  organization_id,
                                  cost_type_id,
                                  sysdate,
                                  FND_GLOBAL.USER_ID,
                                  sysdate,
                                  FND_GLOBAL.USER_ID,
                                  level_type,
                                  activity_id,
                                  resource_id,
                                  resource_rate,
                                  item_units,
                                  activity_units,
                                  usage_rate_or_amount,
                                  basis_type,
                                  basis_factor,
                                  net_yield_or_shrinkage_factor,
                                  item_cost,
                                  cost_element_id,
                                  rollup_source_type,
                                  activity_context,
                                  FND_GLOBAL.CONC_REQUEST_ID,
                                  FND_GLOBAL.PROG_APPL_ID,
                                  FND_GLOBAL.CONC_PROGRAM_ID,
                                  sysdate,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15
                     FROM CST_ITEM_CST_DTLS_INTERFACE ct
                     WHERE ct.error_flag is null
                     and ct.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'sucessfully completed inserting ' || to_char(SQL%ROWCOUNT)|| ' rows into cicd');

l_stmt_no := 50;

Update CST_ITEM_CST_DTLS_INTERFACE ct set
 process_flag = 5
WHERE error_flag is null
AND group_id = SEQ_NEXTVAL
AND process_flag = 4;

fnd_file.put_line(fnd_file.log,'after updating the process flag to 5');


IF i_del_option = 1 then
  delete from CST_ITEM_CST_DTLS_INTERFACE
  WHERE error_flag is null
  AND process_flag = 5
  AND group_id = SEQ_NEXTVAL;
 fnd_file.put_line(fnd_file.log,'done deleting ' || to_char(SQL%ROWCOUNT) || ' processed rows');
END IF;

commit;

EXCEPTION
    when others then
       rollback;
       fnd_file.put_line(fnd_file.log,'CICD/CICDI table insert_cic_cicd(' || to_char(l_stmt_no) || '),' || to_char(SQLCODE) || ',' || substr(SQLERRM,1,180));

      CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',(fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')));
Error_number := 1;

END insert_cic_cicd;



/* This procedure Start_item_cost_import_process is the starting point in the
   whole program.This procedure calls the validation procedures in the order
   after verifying the number of rows to process */


Procedure Start_item_cost_import_process(Error_number OUT NOCOPY NUMBER,
                                         i_next_value IN VARCHAR2,
                                         i_grp_id IN  NUMBER,
                                         i_del_option IN NUMBER,
                                         i_cost_type IN VARCHAR2,
                                         i_run_option IN NUMBER) is

Err NUMBER;
i_count NUMBER;
l_cicdi_count NUMBER := 0;
CONC_REQUEST BOOLEAN;
CST_STOP_EXCEPTION EXCEPTION;
BEGIN
Error_number := 0;

IF i_next_value is null then
    Update CST_ITEM_CST_DTLS_INTERFACE
    SET group_id = i_grp_id
    where process_flag = 1
    AND error_flag is null;
END IF;


Select count(*) into l_cicdi_count
from CST_ITEM_CST_DTLS_INTERFACE cicdi
WHERE cicdi.group_id = i_grp_id
AND cicdi.error_flag is null
AND cicdi.process_flag = 1
AND rownum = 1;

If l_cicdi_count = 0 then
  fnd_file.put_line(fnd_file.log,'no rows to process in CST_ITEM_CST_DTLS_INTERFACE,quitting....');
  return;
end If;

validate_phase1(Err,i_cost_type,i_grp_id);

IF Err = 1 then
 raise CST_STOP_EXCEPTION;
END IF;

validate_phase2(Err,i_grp_id);

IF Err = 1 then
 raise CST_STOP_EXCEPTION;
END IF;

insert_cic_cicd(Err,i_grp_id,i_del_option,i_run_option);

IF Err = 1 then
 raise CST_STOP_EXCEPTION;
END IF;

select count(*) into i_count from CST_ITEM_CST_DTLS_INTERFACE
where group_id = i_grp_id
and error_flag = 'E';

If (i_count > 0) then
     fnd_file.put_line(fnd_file.log,(fnd_message.get_string('BOM','CST_MSG_CICDI')));
      CONC_REQUEST := fnd_concurrent.set_completion_status('WARNING',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));
END IF;

fnd_file.put_line(fnd_file.log,'done with item costs import, quitting');
EXCEPTION
 when others then
  rollback;
 fnd_file.put_line(fnd_file.log,'Start_item_cost_import_process(), Invalid Exception Occured');

      CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));
Error_number := 1;
END Start_item_cost_import_process;

END CST_ITEM_COST_IMPORT_INTERFACE;

/
