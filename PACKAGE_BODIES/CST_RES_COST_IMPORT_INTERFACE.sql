--------------------------------------------------------
--  DDL for Package Body CST_RES_COST_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_RES_COST_IMPORT_INTERFACE" as
/* $Header: CSTRIMPB.pls 120.0 2005/05/25 05:20:23 appldev noship $ */

PROCEDURE Validate_resource_costs (Error_number OUT NOCOPY NUMBER
                                   ,i_group_id IN NUMBER
                                   ,i_new_csttype IN VARCHAR2
                                   ,i_del_option IN NUMBER
                                   ,i_run_option IN NUMBER
                                   ) as

l_org_id NUMBER := 0;
SEQ_NEXTVAL NUMBER :=0;
l_stmt_no NUMBER := 0;
i_count NUMBER := 0;
l_count NUMBER := 0;
l_cost_type_id NUMBER;
CONC_REQUEST BOOLEAN;
BEGIN

SEQ_NEXTVAL := i_group_id;
Error_number := 0;
/* check for both the organization_id and code to be null */
fnd_file.put_line(fnd_file.log,'--------entering the validate_resource_costs procedure----------');

Update CST_RESOURCE_COSTS_INTERFACE crci
SET error_flag = 'E',
    error_code = 'CST_NULL_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_ORGANIZATION'),1,240)
where (Organization_id is null AND organization_code is null)
AND error_flag is null
AND crci.group_id = SEQ_NEXTVAL;

l_stmt_no := 10;
fnd_file.put_line(fnd_file.log,'done checking for null organization ID and code ');

/* check to see if the input organization_id or code is valid */

Update CST_RESOURCE_COSTS_INTERFACE crci
SET error_flag = 'E',
    error_code = 'CST_INVALID_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ORGANIZATION'),1,240)
WHERE crci.error_flag is null
AND crci.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from mtl_parameters mp
                where NVL(crci.organization_id,mp.organization_id) = mp.organization_id
                AND NVL(crci.organization_code,mp.organization_code) = mp.organization_code
                );

l_stmt_no := 20;
fnd_file.put_line(fnd_file.log,'done checking for the organization to be invalid');

/* Get the organization_id from the code */

Update CST_RESOURCE_COSTS_INTERFACE crci
SET organization_id = (select organization_id
                       FROM mtl_parameters mp
                       WHERE mp.organization_code = crci.organization_code
                       )
WHERE crci.organization_id is null
AND crci.error_flag is null
AND crci.group_id = SEQ_NEXTVAL;

/* OPM INVCONV project to bypass all process orgs in Discrete programs
** umoogala  09-nov-2004 Bug# 3980701
**/

l_stmt_no := 30;

Update CST_RESOURCE_COSTS_INTERFACE ct
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

l_stmt_no := 30;
fnd_file.put_line(fnd_file.log,'done getting the organization_id from the code if it has not been provided');

/* Set the unique transaction_id for each row */

Update CST_RESOURCE_COSTS_INTERFACE crci
SET transaction_id = CST_ITEM_CST_DTLS_INTERFACE_S.NEXTVAL,
    error_code =null,
    error_explanation = null,
    request_id = FND_GLOBAL.CONC_REQUEST_ID,
    program_application_id = FND_GLOBAL.PROG_APPL_ID,
    program_id = FND_GLOBAL.CONC_PROGRAM_ID,
    program_update_date = sysdate,
    process_flag = 2
where group_id=SEQ_NEXTVAL
AND error_flag is null
AND process_flag = 1;


l_stmt_no := 50;
fnd_file.put_line(fnd_file.log,'done assiging unique transaction_id to every row');
COMMIT;

/* check for the organization to be a costing org */

UPDATE CST_RESOURCE_COSTS_INTERFACE crci
set crci.Error_flag = 'E',
    crci.Error_code = 'CST_NOT_COSTINGORG',
    crci.Error_explanation = substrb(fnd_message.get_string('BOM','CST_NOT_COSTINGORG'),1,240)
WHERE crci.group_id = SEQ_NEXTVAL
AND crci.error_flag is null
AND EXISTS ( Select 1 from mtl_parameters mp
             WHERE mp.cost_organization_id <> mp.organization_id
             AND mp.organization_id = crci.organization_id);

l_stmt_no := 55;
fnd_file.put_line(fnd_file.log,'done checking for costing org or not');


/* now set teh cost type and cost type id */

Update CST_RESOURCE_COSTS_INTERFACE crci
SET crci.cost_type_id = (select cost_type_id from CST_COST_TYPES cct
                    WHERE cct.cost_type =  i_new_csttype
                    ),
    crci.cost_type = i_new_csttype
WHERE crci.group_id = SEQ_NEXTVAL
AND crci.error_flag is null;


l_stmt_no := 80;


/* check for resource_id and resource_code to be null */

Update CST_RESOURCE_COSTS_INTERFACE crci
SET crci.error_flag = 'E',
    crci.error_code = 'CST_NULL_SUBELEMENT',
    crci.error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_SUBELEMENT'),1,240)
WHERE crci.error_flag is null
AND crci.group_id = SEQ_NEXTVAL
AND (crci.resource_id is null AND crci.resource_code is null);

l_stmt_no := 90;
fnd_file.put_line(fnd_file.log,'done checking for null sub element');

/* check if the entered resource_id or code is actually valid and also that functional currency flag is not = 1 */
Update CST_RESOURCE_COSTS_INTERFACE crci set
  error_flag = 'E',
  error_code = 'CST_INVALID_RESOURCE',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_RESOURCE'),1,240)
WHERE crci.error_flag is null
AND crci.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from bom_resources bm
                WHERE NVL(crci.resource_id,bm.resource_id)=bm.resource_id
                AND NVL(crci.resource_code,bm.resource_code)=bm.resource_code
                AND (bm.cost_element_id = 3 OR bm.cost_element_id = 4)
                AND bm.functional_currency_flag <> 1
                AND crci.organization_id = bm.organization_id
               );


l_stmt_no := 100;


Update CST_RESOURCE_COSTS_INTERFACE crci set
   crci.resource_id = (select bm.resource_id from bom_resources bm
                       WHERE bm.resource_code = crci.resource_code
                       AND (bm.cost_element_id = 3 or bm.cost_element_id = 4)
                       AND bm.functional_currency_flag <> 1
                       AND bm.organization_id = crci.organization_id)
WHERE crci.error_flag is null
AND crci.resource_id is null
AND  crci.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done setting the resource_id if it has not been provided');
l_stmt_no := 105;

/* check for the validity date of the resource_id */

Update CST_RESOURCE_COSTS_INTERFACE crci
set crci.error_flag = 'E',
    crci.error_code = 'CST_EXP_SUBELEMENT',
    crci.error_explanation = substrb(fnd_message.get_string('BOM','CST_EXP_SUBELEMENT'),1,240)
where crci.error_flag is null
AND crci.group_id = SEQ_NEXTVAL
AND EXISTS ( select 1 from BOM_RESOURCES bm
             WHERE bm.organization_id = crci.organization_id
             AND (bm.cost_element_id = 3 OR bm.cost_element_id = 4)
             AND bm.resource_id = crci.resource_id
             AND ((sysdate >= NVL(bm.disable_date,sysdate+1)) OR (bm.allow_costs_flag = 2)));

fnd_file.put_line(fnd_file.log,'done checking for the validity date and allow costs flag of resource id');
l_stmt_no := 106;


/* check for the resource rate that is provided to be not null */

UPDATE CST_RESOURCE_COSTS_INTERFACE crci
set error_flag = 'E',
    error_code = 'CST_NULL_RESRT',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_RESRT'),1,240)
where crci.resource_rate is null
and crci.error_flag is null
and crci.group_id = SEQ_NEXTVAL;


Update CST_RESOURCE_COSTS_INTERFACE crci
set process_flag = 3
WHERE process_flag = 2
AND group_id = SEQ_NEXTVAL
AND error_flag is null;

COMMIT;

/* check for the duplicate rows in the interface table*/

  Update cst_resource_costs_interface crci
  set crci.error_flag = 'E',
      crci.error_code = 'CST_DUPL_ROWS',
      crci.error_explanation = substrb(fnd_message.get_string('BOM','CST_DUPL_ROWS'),1,240)
  where crci.error_flag is null
  AND crci.group_id = SEQ_NEXTVAL
  AND EXISTS (select 1 from cst_resource_costs_interface crci2
              WHERE  crci.resource_id = crci2.resource_id
              AND crci.organization_id = crci2.organization_id
              AND crci.cost_type_id = crci2.cost_type_id
              AND crci.rowid <> crci2.rowid
              AND crci2.group_id = SEQ_NEXTVAL);

fnd_file.put_line(fnd_file.log,'done checking for duplicate rows');

Update CST_RESOURCE_COSTS_INTERFACE crci
set process_flag = 4
WHERE crci.process_flag = 3
AND crci.error_flag is null
AND crci.group_id = SEQ_NEXTVAL;

COMMIT;

l_stmt_no := 110;

/* Now begin inserting rows into CST_RESOURCE_COSTS */

/* first check the run option */

 if i_run_option = 2 then
 l_stmt_no := 115;

 Delete from CST_RESOURCE_COSTS crc
 where EXISTS (select 1 from CST_RESOURCE_COSTS_INTERFACE crci
               where crci.organization_id = crc.organization_id
               AND crci.cost_type_id = crc.cost_type_id
               AND crci.resource_id = crc.resource_id
               AND crci.error_flag is null
               AND crci.group_id = SEQ_NEXTVAL);

 elsif i_run_option = 1 then

 UPDATE CST_RESOURCE_COSTS_INTERFACE crci set
 error_flag ='E',
 error_code = 'CST_CANT_INSERT',
 error_explanation = substrb(fnd_message.get_string('BOM','CST_CANT_INSERT'),1,240)
 where crci.error_flag is null
 AND crci.group_id = SEQ_NEXTVAL
 AND EXISTS (Select 1 from CST_RESOURCE_COSTS crc
             where crc.organization_id = crci.organization_id
             AND crc.cost_type_id = crci.cost_type_id
             AND crc.resource_id = crci.resource_id
             );
 fnd_file.put_line(fnd_file.log,'done deleting or erroring out rows as per run option');
 end if;

l_stmt_no := 117;


INSERT INTO CST_RESOURCE_COSTS(Resource_id,
                               cost_type_id,
                               last_update_date,
                               last_updated_by,
                               creation_date,
                               created_by,
                               organization_id,
                               Resource_rate,
                               request_id,
                               program_application_id,
                               program_id,
                               program_update_date,
                               Attribute_category,
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
                        SELECT resource_id,
                               cost_type_id,
                               sysdate,
                               FND_GLOBAL.USER_ID,
                               sysdate,
                               FND_GLOBAL.USER_ID,
                               organization_id,
                               resource_rate,
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
                          FROM CST_RESOURCE_COSTS_INTERFACE
                          WHERE error_flag is null
                          AND group_id = SEQ_NEXTVAL;
fnd_file.put_line(fnd_file.log,'done inserting ' || to_char(SQL%ROWCOUNT) ||' rows into CST_RESOURCE_COSTS');

l_stmt_no := 120;

UPDATE CST_RESOURCE_COSTS_INTERFACE
 set process_flag = 5
 where process_flag = 4
 and error_flag is null
 and group_id = SEQ_NEXTVAL;

IF i_del_option = 1 then
 delete from CST_RESOURCE_COSTS_INTERFACE
 WHERE process_flag = 5
 AND error_flag is null
 AND group_id = SEQ_NEXTVAL;

 fnd_file.put_line(fnd_file.log,'done deleting ' || to_char(SQL%ROWCOUNT) || ' rows that were  successfully processed ');
END IF;
COMMIT;

fnd_file.put_line(fnd_file.log,'--------done , exiting Validate_resource_costs--------');
EXCEPTION

       when others then
          rollback;
          fnd_file.put_line(fnd_file.log,'Validate_resource_costs(' || to_char(l_stmt_no) ||'),' || to_char(SQLCODE) || ',' || substr(SQLERRM,1,180));
 Error_number := 1;
 CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));

END Validate_resource_costs;

/*This procedure Start_res_cost_import_process is the Starting point for the process and calls the appropriate procedures after verifying that there are rows to process in the interface table */


Procedure Start_res_cost_import_process(Error_number OUT NOCOPY NUMBER
                                        ,i_Next_value IN VARCHAR2
                                        ,i_grp_id IN NUMBER
                                        ,i_cst_type IN VARCHAR2
                                        ,i_del_option IN NUMBER
                                        ,i_run_option IN NUMBER) is

Err NUMBER := 0;
CONC_REQUEST BOOLEAN;
l_crci_count NUMBER := 0;
CST_STOP_EXCEPTION EXCEPTION;
i_count NUMBER;
BEGIN
 IF i_Next_value is null then
    UPDATE CST_RESOURCE_COSTS_INTERFACE crci
    SET group_id = i_grp_id
    where process_flag = 1
    AND error_flag is null;
 END IF;

Select count(*) into l_crci_count
FROM CST_RESOURCE_COSTS_INTERFACE crci
where  crci.group_id = i_grp_id
AND crci.error_flag is null
AND crci.process_flag = 1
AND rownum =1;

If l_crci_count = 0 then
 fnd_file.put_line(fnd_file.log,'no rows to process in CST_RESOURCE_COSTS_INTERFACE,quitting.....');
 return;
end If;

Validate_resource_costs(Err,i_grp_id,i_cst_type,i_del_option,i_run_option);

IF Err = 1 then
 Error_number := 1;
 raise CST_STOP_EXCEPTION;
END IF;

select count(*) into i_count from CST_RESOURCE_COSTS_INTERFACE
where group_id = i_grp_id
and error_flag ='E';

IF i_count > 0 then
 CONC_REQUEST := fnd_concurrent.set_completion_status('WARNING',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));
fnd_file.put_line(fnd_file.log,(fnd_message.get_string('BOM','CST_MSG_CRCI')));
END IF;

EXCEPTION
 when others then
   rollback;
   fnd_file.put_line(fnd_file.log,'CST_RES_IMPORT_PROCESS.Start_res_cost_import_process() Exception occured');
 CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));


END Start_res_cost_import_process;


END CST_RES_COST_IMPORT_INTERFACE;

/
