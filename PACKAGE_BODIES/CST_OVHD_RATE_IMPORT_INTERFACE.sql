--------------------------------------------------------
--  DDL for Package Body CST_OVHD_RATE_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_OVHD_RATE_IMPORT_INTERFACE" as
/* $Header: CSTOIMPB.pls 120.0 2005/05/25 04:01:09 appldev noship $ */

Procedure Validate_Department_overheads(Error_number OUT NOCOPY NUMBER
                                        ,i_new_csttype IN VARCHAR2
                                        ,i_group_id IN NUMBER
                                        ,i_del_option IN NUMBER
                                        ,i_run_option IN NUMBER) IS

l_org_id NUMBER := 0;
SEQ_NEXTVAL NUMBER;
l_cost_type_id NUMBER;
l_stmt_no NUMBER;
l_row_count NUMBER;
i_count NUMBER;
l_cdoi_count NUMBER := 0;
CONC_REQUEST BOOLEAN;
BEGIN

SEQ_NEXTVAL := i_group_id;
l_stmt_no := 10;
Error_number := 0;

/* First check if there are any rows to process */

Select count(*) into l_cdoi_count
from CST_DEPT_OVERHEADS_INTERFACE cdoi
WHERE cdoi.group_id = SEQ_NEXTVAL
AND cdoi.error_flag is null
AND cdoi.process_flag = 1
AND rownum = 1;

If l_cdoi_count = 0 then
 fnd_file.put_line(fnd_file.log,'no rows to process in CST_DEPT_OVERHEADS_INTERFACE, quiting....');
 return;
end If;

fnd_file.put_line(fnd_file.log,'---------at the start of validating CST_DEPT_OVERHEADS_INTERFACE-------------');

/* check for both the organization_id and code to be null */
Update CST_DEPT_OVERHEADS_INTERFACE cdoi
SET error_flag = 'E',
    error_code = 'CST_NULL_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_ORGANIZATION'),1,240)
where (Organization_id is null AND organization_code is null)
AND cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL;

l_stmt_no:=20;
fnd_file.put_line(fnd_file.log,'done checking for null org id and code');

/* check to see if the input organization_id or code is valid */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
SET error_flag = 'E',
    error_code = 'CST_INVALID_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ORGANIZATION'),1,240)
WHERE cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from mtl_parameters mp
                where NVL(cdoi.organization_id,mp.organization_id) = mp.organization_id
                AND NVL(cdoi.organization_code,mp.organization_code) = mp.organization_code);

l_stmt_no := 30;
fnd_file.put_line(fnd_file.log,'done checking for invalid org id and code ');

/*Get the Organization_id from the code */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
SET organization_id = (select organization_id
                       FROM mtl_parameters mp
                       WHERE mp.organization_code = cdoi.organization_code
                       AND cdoi.error_flag is null
                       )
WHERE cdoi.organization_id is null
AND cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL;

/* OPM INVCONV project to bypass all process orgs in Discrete programs
** umoogala  09-nov-2004 Bug# 3980701
**/

l_stmt_no := 30;

Update CST_DEPT_OVERHEADS_INTERFACE ct
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
fnd_file.put_line(fnd_file.log,'done getting the org_id from the code if it is not provided');

/* Set the unique transaction_id for each row */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
SET transaction_id = CST_ITEM_CST_DTLS_INTERFACE_S.NEXTVAL,
    request_id = FND_GLOBAL.CONC_REQUEST_ID,
    error_code = null,
    error_explanation = null,
    program_application_id = FND_GLOBAL.PROG_APPL_ID,
    program_id = FND_GLOBAL.CONC_PROGRAM_ID,
    program_update_date = sysdate,
    process_flag = 2
where cdoi.group_id=SEQ_NEXTVAL
AND cdoi.process_flag = 1
AND cdoi.error_flag is null;

COMMIT;

l_stmt_no := 60;
fnd_file.put_line(fnd_file.log,'done setting the transaction_id');

/* Now check for the organization to be a costing org */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
set cdoi.error_flag = 'E',
    cdoi.error_code = 'CST_NOT_COSTINGORG',
    cdoi.error_explanation = substrb(fnd_message.get_string('BOM','CST_NOT_COSTINGORG'),1,240)
WHERE cdoi.group_id = SEQ_NEXTVAL
AND cdoi.error_flag is null
AND EXISTS (select 1 from MTL_PARAMETERS mp
            WHERE mp.cost_organization_id <> mp.organization_id
            AND mp.organization_id = cdoi.organization_id);

l_stmt_no := 65;
fnd_file.put_line(fnd_file.log,'done checking for the org to be a costing org');



Update CST_DEPT_OVERHEADS_INTERFACE cdoi
SET cdoi.cost_type_id = (select cost_type_id from CST_COST_TYPES cct
                         where cct.cost_type = i_new_csttype
                        ),
    cdoi.cost_type = i_new_csttype
WHERE cdoi.group_id = SEQ_NEXTVAL
AND cdoi.error_flag is null;

l_stmt_no := 70;
fnd_file.put_line(fnd_file.log,'done setting the cost type ');

/* check for both department and department_id to be null */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
SET cdoi.error_flag = 'E',
    cdoi.error_code = 'CST_NULL_DEPARTMENT',
    cdoi.error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_DEPARTMENT'),1,240)
WHERE cdoi.error_flag is null
AND cdoi.group_id =  SEQ_NEXTVAL
AND (cdoi.department_id is null AND cdoi.department_code is null);

l_stmt_no := 80;
fnd_file.put_line(fnd_file.log,'done checking for null department ID and code');

/* check for overhead_id and overhead to be null */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
SET cdoi.error_flag = 'E',
    cdoi.error_code = 'CST_NULL_OVERHEAD',
    cdoi.error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_OVERHEAD'),1,240)
WHERE cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL
AND (cdoi.overhead_id is null AND cdoi.overhead is null);

l_stmt_no := 90;
fnd_file.put_line(fnd_file.log,'done checking for overhead Id and code to be null');

l_stmt_no := 110;

/* check for the entered department_id and department to be valid */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi set
  error_flag = 'E',
  error_code = 'CST_INVALID_DEPTS',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_DEPTS'),1,240)
WHERE cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from bom_departments bd
                WHERE NVL(cdoi.department_id,bd.department_id)=bd.department_id
                AND NVL(cdoi.department_code,bd.department_code)=bd.department_code
                AND cdoi.organization_id = bd.organization_id
               );

l_stmt_no := 120;
fnd_file.put_line(fnd_file.log,'done checking for invalid department Id and code ');

/* Get the department_id from the department_code */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
set cdoi.department_id = (select bd.department_id from bom_departments bd
                      WHERE cdoi.department_code = bd.department_code
                      AND bd.organization_id = cdoi.organization_id
                     )
Where cdoi.error_flag is null
      and cdoi.department_id is null
      and cdoi.group_id = SEQ_NEXTVAL;

l_stmt_no := 130;
fnd_file.put_line(fnd_file.log,'done setting the department ID from the department code if it has not been provided');

/* check if the entered overhead_id or code is actually valid */
Update CST_DEPT_OVERHEADS_INTERFACE cdoi set
  error_flag = 'E',
  error_code = 'CST_INVALID_OVERHEAD',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_OVERHEAD'),1,240)
WHERE cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from bom_resources bm
                WHERE NVL(cdoi.overhead_id,bm.resource_id)=bm.resource_id
                AND NVL(cdoi.overhead,bm.resource_code)=bm.resource_code
                AND (bm.cost_element_id = 5)
                AND cdoi.organization_id = bm.organization_id
               );

l_stmt_no := 140;
fnd_file.put_line(fnd_file.log,'done checking for invalid overhead ID and overhead');

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
set cdoi.overhead_id = (select bm.resource_id from bom_resources bm
                      WHERE cdoi.overhead = bm.resource_code
                      AND bm.organization_id = cdoi.organization_id
                      AND (bm.cost_element_id = 5)
                     )
WHERE cdoi.error_flag is null
      and cdoi.overhead_id is null
      and cdoi.group_id = SEQ_NEXTVAL;

l_stmt_no := 150;
fnd_file.put_line(fnd_file.log,'done setting the overhead ID from the code if it has not been provided');

/* check for the overhead_id to be within the validity date */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
set cdoi.error_flag = 'E',
    cdoi.error_code = 'CST_EXP_SUBELEMENT',
    cdoi.error_explanation = substrb(fnd_message.get_string('BOM','CST_EXP_SUBELEMENT'),1,240)
WHERE cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL
AND EXISTS (select 1 from BOM_RESOURCES bm
            where bm.organization_id = cdoi.organization_id
            AND bm.resource_id = cdoi.overhead_id
            AND ((sysdate >= NVL(bm.disable_date,sysdate+1)) OR (bm.allow_costs_flag = 2)));


fnd_file.put_line(fnd_file.log,'done checking for the validity date  and allow costs flag of the overhead');

l_stmt_no := 155;

/* check for the basis type to be between 1 and 6 */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
set error_flag = 'E',
    error_code = 'CST_INVALID_BASISTYPE',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_BASISTYPE'),1,240)
where error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL
AND (cdoi.basis_type < 1  OR cdoi.basis_type > 4);

l_stmt_no := 160;
fnd_file.put_line(fnd_file.log,'done checking for the basis type flag to be valid');

Update CST_DEPT_OVERHEADS_INTERFACE cdoi set
 error_flag = 'E',
 error_code = 'CST_INVALID_RESRATE',
 error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_RESRATE'),1,240)
where error_flag is null
and cdoi.group_id = SEQ_NEXTVAL
and  cdoi.rate_or_amount is null;

l_stmt_no := 170;
fnd_file.put_line(fnd_file.log,'done checking for null resource rates');

/* checking for the validity of activity id and name if provided */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi set
   error_flag = 'E',
   error_code = 'CST_INVALID_ACTIVITY',
   error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ACTIVITY'),1,240)
where group_id = SEQ_NEXTVAL
AND (cdoi.activity_id is not null OR cdoi.activity is not null)
AND error_flag is null
AND NOT EXISTS(select 1 from cst_activities ca where
               NVL(cdoi.activity_id,ca.activity_id) = ca.activity_id
               AND NVL(cdoi.activity,ca.activity) = ca.activity
               AND cdoi.organization_id = NVL(ca.organization_id,cdoi.organization_id)
               AND NVL(ca.disable_date,sysdate + 1) > sysdate
               );

Update CST_DEPT_OVERHEADS_INTERFACE cdoi set
   cdoi.activity_id = (select ca.activity_id from cst_activities ca
                       where ca.activity = cdoi.activity
                       AND NVL(ca.organization_id,cdoi.organization_id) = cdoi.organization_id
                      )
where cdoi.activity_id is null
and cdoi.activity is not null
and cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL;

fnd_file.put_line(fnd_file.log,'done checking for validity of activity id');
l_stmt_no := 180;


Update CST_DEPT_OVERHEADS_INTERFACE
set process_flag = 3
where process_flag = 2
and error_flag is null
and group_id = SEQ_NEXTVAL;

COMMIT;

/* Now check for the duplicate rows for the same dep/cost type/overhead combo */

Update CST_DEPT_OVERHEADS_INTERFACE cdoi
set cdoi.error_flag = 'E',
    cdoi.error_code = 'CST_DUPL_ROWS',
    cdoi.error_explanation = substrb(fnd_message.get_string('BOM','CST_DUPL_ROWS'),1,240)
where cdoi.error_flag is null
AND cdoi.group_id = SEQ_NEXTVAL
AND EXISTS( Select 1 from CST_DEPT_OVERHEADS_INTERFACE cdoi2
            where  cdoi2.organization_id = cdoi.organization_id
             AND   cdoi2.department_id = cdoi.department_id
             AND   cdoi2.cost_type_id = cdoi.cost_type_id
             AND   cdoi2.overhead_id = cdoi.overhead_id
             AND   cdoi2.group_id = SEQ_NEXTVAL
             AND   cdoi2.rowid <> cdoi.rowid);

fnd_file.put_line(fnd_file.log,'done checking for duplicate rows');

Update CST_DEPT_OVERHEADS_INTERFACE
set process_flag = 4
where process_flag = 3
and error_flag is null
and group_id = SEQ_NEXTVAL;

COMMIT;

l_stmt_no := 190;


/* Now start inserting rows into CST_DEPARTMENT_OVERHEADS table */

/* first check for the run option and error out the rows or delete from the base tables */

 If i_run_option = 2 then
  delete from CST_DEPARTMENT_OVERHEADS cdo
  where exists (select 1 from CST_DEPT_OVERHEADS_INTERFACE cdoi
                where cdoi.department_id = cdo.department_id
                AND cdoi.cost_type_id = cdo.cost_type_id
                AND cdoi.overhead_id = cdo.overhead_id
                AND cdoi.organization_id = cdo.organization_id
                AND cdoi.error_flag is null
                AND cdoi.group_id = SEQ_NEXTVAL
               );

 elsif i_run_option = 1 then
  Update  CST_DEPT_OVERHEADS_INTERFACE cdoi
  set cdoi.error_flag = 'E',
      cdoi.error_code = 'CST_CANT_INSERT',
      cdoi.error_explanation = substrb(fnd_message.get_string('BOM','CST_CANT_INSERT'),1,240)
  where cdoi.error_flag is null
  AND cdoi.group_id = SEQ_NEXTVAL
  AND EXISTS (select 1 from CST_DEPARTMENT_OVERHEADS cdo
              where cdoi.organization_id = cdo.organization_id
              AND cdoi.cost_type_id = cdo.cost_type_id
              AND cdoi.overhead_id = cdo.overhead_id
              AND cdoi.department_id = cdo.department_id
              AND cdoi.error_flag is null
              AND cdoi.group_id = SEQ_NEXTVAL
             );
 end if;

 fnd_file.put_line(fnd_file.log,'done deleting or erroring out rows as per run option');

l_stmt_no := 195;

  INSERT INTO CST_DEPARTMENT_OVERHEADS(Department_id,
                                       cost_type_id,
                                       overhead_id,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       organization_id,
                                       basis_type,
                                       rate_or_amount,
                                       activity_id,
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
                                       attribute15,
                                       Request_id,
                                       program_application_id,
                                       program_id,
                                       program_update_date)
                                SELECT department_id,
                                       cost_type_id,
                                       overhead_id,
                                       sysdate,
                                       FND_GLOBAL.USER_ID,
                                       sysdate,
                                       FND_GLOBAL.USER_ID,
                                       organization_id,
                                       NVL(cdoi.basis_type,1),
                                       rate_or_amount,
                                       Activity_id,
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
                                       attribute15,
                                       FND_GLOBAL.CONC_REQUEST_ID,
                                       FND_GLOBAL.PROG_APPL_ID,
                                       FND_GLOBAL.CONC_PROGRAM_ID,
                                       sysdate
                      FROM CST_DEPT_OVERHEADS_INTERFACE cdoi
                      WHERE cdoi.error_flag is null
                      AND cdoi.group_id = SEQ_NEXTVAL;
fnd_file.put_line(fnd_file.log,'done inserting ' || to_char(SQL%ROWCOUNT) || ' rows into the base table CST_DEPARTMENT_OVERHEADS');

l_stmt_no := 200;

Update CST_DEPT_OVERHEADS_INTERFACE set
 process_flag = 5
where process_flag = 4
AND error_flag is null
AND group_id = SEQ_NEXTVAL;

IF i_del_option = 1 then
 delete from CST_DEPT_OVERHEADS_INTERFACE
 WHERE error_flag is null
 AND group_id = SEQ_NEXTVAL
 AND process_flag = 5;

fnd_file.put_line(fnd_file.log,'done deleting ' || to_char(SQL%ROWCOUNT) ||' rows that were sucessfully processed');
END IF;

COMMIT;

EXCEPTION
    when others then
      rollback;
      fnd_file.put_line(fnd_file.log,'Validate_department_overheads('|| to_char(l_stmt_no) || '),'|| to_char(SQLCODE) || ',' || substr(SQLERRM,1.180));

 CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));
  Error_number := 1;
END Validate_Department_overheads;


Procedure Validate_Resource_overheads(Error_number OUT NOCOPY NUMBER
                                       ,i_new_csttype VARCHAR2
                                       ,i_group_id IN NUMBER
                                       ,i_del_option IN NUMBER
                                       ,i_run_option IN NUMBER) AS

l_org_id  NUMBER := 0;
SEQ_NEXTVAL NUMBER;
l_count NUMBER;
l_def_cost_type_id NUMBER;
l_cost_type_id NUMBER;
l_stmt_no NUMBER;
i_count NUMBER;
l_croi_count NUMBER := 0;
CONC_REQUEST BOOLEAN;
BEGIN

SEQ_NEXTVAL := i_group_id;
l_stmt_no := 10;
Error_number := 0;

/* First check if there are rows to process */
select count(*) into l_croi_count
from CST_RES_OVERHEADS_INTERFACE croi
where croi.group_id = SEQ_NEXTVAL
AND croi.error_flag is null
AND croi.process_flag = 1
AND rownum = 1;

If l_croi_count = 0 then
  fnd_file.put_line(fnd_file.log,'no rows to process in CST_RES_OVERHEADS_INTERFACE, quitting.........');
  return;
end IF;

/* check for both the organization_id and code to be null */

fnd_file.put_line(fnd_file.log,'--------at the start of validating CST_RES_OVERHEADS_INTERFACE table-------');

Update CST_RES_OVERHEADS_INTERFACE croi
SET error_flag = 'E',
    error_code = 'CST_NULL_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_ORGANIZATION'),1,240)
where (Organization_id is null AND organization_code is null)
AND error_flag is null
AND croi.group_id = SEQ_NEXTVAL;

l_stmt_no := 20;
fnd_file.put_line(fnd_file.log,'done checking for null org Id and code ');

/* check to see if the input organization_id or code is valid */

Update CST_RES_OVERHEADS_INTERFACE croi
SET error_flag = 'E',
    error_code = 'CST_INVALID_ORGANIZATION',
    error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_ORGANIZATION'),1,240)
WHERE croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from mtl_parameters mp
                where NVL(croi.organization_id,mp.organization_id) = mp.organization_id
                AND NVL(croi.organization_code,mp.organization_code) = mp.organization_code);

l_stmt_no := 30;
fnd_file.put_line(fnd_file.log,'done checking for invalid organization ID and code');

/*Get the Organization_id from the code */

Update CST_RES_OVERHEADS_INTERFACE croi
SET organization_id = (select organization_id
                       FROM mtl_parameters mp
                       WHERE mp.organization_code = croi.organization_code
                       AND croi.error_flag is null
                       )
WHERE croi.organization_id is null
AND croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAL;

l_stmt_no := 40;
fnd_file.put_line(fnd_file.log,'done setting the organization_ID from the code if it has not been set already');

/* Set the unique transaction_id for each row */

Update CST_RES_OVERHEADS_INTERFACE croi
SET transaction_id = CST_ITEM_CST_DTLS_INTERFACE_S.NEXTVAL,
    request_id = FND_GLOBAL.CONC_REQUEST_ID,
    error_code = null,
    error_explanation = null,
    program_application_id = FND_GLOBAL.PROG_APPL_ID,
    program_id = FND_GLOBAL.CONC_PROGRAM_ID,
    program_update_date = sysdate,
    process_flag = 2
where error_flag is null
AND croi.process_flag = 1
AND group_id=SEQ_NEXTVAL;

l_stmt_no := 70;
fnd_file.put_line(fnd_file.log,'done setting the transaction ID');

COMMIT;
l_stmt_no := 75;
/* Now check for the organization to be a costing org */

Update CST_RES_OVERHEADS_INTERFACE croi
set croi.error_flag = 'E',
    croi.error_code = 'CST_NOT_COSTINGORG',
    croi.error_explanation = substrb(fnd_message.get_string('BOM','CST_NOT_COSTINGORG'),1,240)
WHERE croi.group_id = SEQ_NEXTVAL
AND croi.error_flag is null
AND EXISTS (select 1 from MTL_PARAMETERS mp
            WHERE mp.cost_organization_id <> mp.organization_id
            AND mp.organization_id = croi.organization_id);

/* Insert the new cost type into cst_cost_types and assign the new cost types to all the rows */

l_stmt_no := 77;
fnd_file.put_line(fnd_file.log,'done checking for the org to be costing org or not');


Update CST_RES_OVERHEADS_INTERFACE croi
SET croi.cost_type_id = (select cost_type_id from CST_COST_TYPES cct
                         where cct.cost_type = i_new_csttype
                        ),
    croi.cost_type = i_new_csttype
WHERE croi.group_id = SEQ_NEXTVAL
AND croi.error_flag is null;

l_stmt_no := 80;
fnd_file.put_line(fnd_file.log,'done setting the cost type');

/* check for overhead_id and overhead to be null */

Update CST_RES_OVERHEADS_INTERFACE croi
SET croi.error_flag = 'E',
    croi.error_code = 'CST_NULL_OVERHEAD',
    croi.error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_OVERHEAD'),1,240)
WHERE croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAL
AND (croi.overhead_id is null AND croi.overhead is null);

l_stmt_no := 90;
fnd_file.put_line(fnd_file.log,'done checking for the overhead ID and code to be null');

/* check for resource_id and reource_codes to be null */

Update CST_RES_OVERHEADS_INTERFACE croi
SET croi.error_flag = 'E',
    croi.error_code = 'CST_NULL_SUBELEMENT',
    croi.error_explanation = substrb(fnd_message.get_string('BOM','CST_NULL_SUBELEMENT'),1,240)
WHERE croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAL
AND (croi.resource_id is null AND croi.resource_code is null);

l_stmt_no := 100;
fnd_file.put_line(fnd_file.log,'done checking for the subelement ID and code to be null');

/* check if the entered resource_id or code is actually valid */
Update CST_RES_OVERHEADS_INTERFACE croi set
  error_flag = 'E',
  error_code = 'CST_INVALID_SUBELEMENT',
  error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_SUBELEMENT'),1,240)
WHERE croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from bom_resources bm
                WHERE NVL(croi.resource_id,bm.resource_id)=bm.resource_id
                AND NVL(croi.resource_code,bm.resource_code)=bm.resource_code
                AND (bm.cost_element_id = 3 OR bm.cost_element_id = 4)
                AND croi.organization_id = bm.organization_id
               );

l_stmt_no := 130;
fnd_file.put_line(fnd_file.log,'done checking for the sub element to be valid or not');

/* Get the resource_id from the resource_code */

Update CST_RES_OVERHEADS_INTERFACE croi
set croi.resource_id = (select bm.resource_id from bom_resources bm
                      WHERE croi.resource_code = bm.resource_code
                      AND bm.organization_id = croi.organization_id
                      AND (bm.cost_element_id = 3 OR bm.cost_element_id = 4)
                     )
WHERE croi.error_flag is null
      and croi.resource_id is null
      and croi.group_id = SEQ_NEXTVAL;

l_stmt_no := 140;
fnd_file.put_line(fnd_file.log,'done setting the subelement ID from the code if it has not been provided');

/* check for the validty_date for the resource_id */
Update CST_RES_OVERHEADS_INTERFACE croi
set croi.error_flag = 'E',
    croi.error_code = 'CST_EXP_SUBELEMENT',
    croi.error_explanation = substrb(fnd_message.get_string('BOM','CST_EXP_SUBELEMENT'),1,240)
WHERE croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAl
AND exists (select 1 from BOM_RESOURCES bm
            WHERE bm.organization_id = croi.organization_id
            AND bm.resource_id = croi.resource_id
            AND ((sysdate >= NVL(bm.disable_date,sysdate+1)) OR (bm.allow_costs_flag = 2)));

fnd_file.put_line(fnd_file.log,'done checking for the validity date  and allow costs flag of resource ID');
l_stmt_no := 145;
/* check if the entered overhead_id or overhead is actually valid */
Update CST_RES_OVERHEADS_INTERFACE croi set
 error_flag = 'E',
 error_code = 'CST_INVALID_OVERHEAD',
 error_explanation = substrb(fnd_message.get_string('BOM','CST_INVALID_OVERHEAD'),1,240)
WHERE croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAL
AND NOT EXISTS (select 1 from bom_resources bm
                WHERE NVL(croi.overhead_id,bm.resource_id)=bm.resource_id
                AND NVL(croi.overhead,bm.resource_code)=bm.resource_code
                AND (bm.cost_element_id = 5 OR bm.cost_element_id = 2)
                AND croi.organization_id = bm.organization_id
               );

l_stmt_no := 150;
fnd_file.put_line(fnd_file.log,'done checking for invalid overhead');

/* Get the overhead_id from the overhead */

Update CST_RES_OVERHEADS_INTERFACE croi
set croi.overhead_id = (select bm.resource_id from bom_resources bm
                      WHERE croi.overhead = bm.resource_code
                      AND bm.organization_id = croi.organization_id
                      AND (bm.cost_element_id = 5 OR bm.cost_element_id = 2)
                     )
WHERE croi.error_flag is null
      and croi.overhead_id is null
      and croi.group_id = SEQ_NEXTVAL;

l_stmt_no := 160;
fnd_file.put_line(fnd_file.log,'done getting the overhead id from the overhead if it has not been provided');

/* now check for the validity date of the overhead */
Update CST_RES_OVERHEADS_INTERFACE croi
set croi.error_flag='E',
    croi.error_code = 'CST_EXP_SUBELEMENT',
    croi.error_explanation = substrb(fnd_message.get_string('BOM','CST_EXP_SUBELEMENT'),1,240)
WHERE croi.error_flag is null
AND croi.group_id = SEQ_NEXTVAL
AND exists (select 1 from BOM_RESOURCES bm
            WHERE bm.organization_id = croi.organization_id
            AND bm.resource_id = croi.overhead_id
            AND ((sysdate >= NVL(bm.disable_date,sysdate+1)) OR (bm.allow_costs_flag = 2))) ;

fnd_file.put_line(fnd_file.log,'done checking for the validity date  and allow costs flag of the overhead');
l_stmt_no := 165;
/*end of phase 1 so commit */

Update CST_RES_OVERHEADS_INTERFACE croi
set process_flag = 3
WHERE process_flag = 2
AND group_id = SEQ_NEXTVAL
AND error_flag is null;

COMMIT;

l_stmt_no := 170;

Update CST_RES_OVERHEADS_INTERFACE croi
set croi.error_flag = 'E',
    croi.error_code = 'CST_DUPL_ROWS',
    croi.error_explanation = substrb(fnd_message.get_string('BOM','CST_DUPL_ROWS'),1,240)
WHERE croi.error_flag  is null
AND croi.group_id = SEQ_NEXTVAL
AND EXISTS(select 1 from CST_RES_OVERHEADS_INTERFACE croi2
           WHERE croi2.resource_id = croi.resource_id
           AND croi2.cost_type_id = croi.cost_type_id
           AND croi2.organization_id = croi.organization_id
           AND croi2.overhead_id = croi.overhead_id
           AND croi2.rowid <> croi.rowid
           AND croi2.group_id = SEQ_NEXTVAL
           );

fnd_file.put_line(fnd_file.log,'done checking for the duplicate rows');

Update CST_RES_OVERHEADS_INTERFACE croi
 set croi.process_flag = 4
 where croi.process_flag = 3
 AND error_flag is null
 AND group_id = SEQ_NEXTVAL;


COMMIT;


/* Now start inserting rows into CST_RESOURCE_OVERHEADS table */

/* now check for the run option and delete or error out rows accordingly */
If i_run_option = 2 then
  delete from CST_RESOURCE_OVERHEADS cro
  where exists (select 1 from CST_RES_OVERHEADS_INTERFACE croi
                where croi.cost_type_id = cro.cost_type_id
                AND croi.resource_id = cro.resource_id
                AND croi.overhead_id = cro.overhead_id
                AND croi.organization_id = cro.organization_id
                AND croi.error_flag is null
                AND croi.group_id = SEQ_NEXTVAL
               );

 elsif i_run_option = 1 then
  Update  CST_RES_OVERHEADS_INTERFACE croi
  set croi.error_flag = 'E',
      croi.error_code = 'CST_CANT_INSERT',
      croi.error_explanation = substrb(fnd_message.get_string('BOM','CST_CANT_INSERT'),1,240)
  where croi.error_flag is null
  AND croi.group_id = SEQ_NEXTVAL
  AND EXISTS (select 1 from CST_RESOURCE_OVERHEADS cro
              where croi.organization_id = cro.organization_id
              AND croi.cost_type_id = cro.cost_type_id
              AND croi.overhead_id = cro.overhead_id
              AND croi.resource_id = cro.resource_id
              AND croi.error_flag is null
              AND croi.group_id = SEQ_NEXTVAL
             );
 end if;

 fnd_file.put_line(fnd_file.log,'done deleting or erroring out rows as per run option');

l_stmt_no := 175;

INSERT INTO CST_RESOURCE_OVERHEADS(cost_type_id,
                                   resource_id,
                                   overhead_id,
                                   last_update_date,
                                   last_updated_by,
                                   creation_date,
                                   created_by,
                                   organization_id,
                                   request_id,
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
                            SELECT cost_type_id,
                                   resource_id,
                                   overhead_id,
                                   sysdate,
                                   FND_GLOBAL.USER_ID,
                                   sysdate,
                                   FND_GLOBAL.USER_ID,
                                   organization_id,
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
         FROM CST_RES_OVERHEADS_INTERFACE croi
         where croi.error_flag is null
         AND group_id = SEQ_NEXTVAL;
fnd_file.put_line(fnd_file.log,'done inserting ' || to_char(SQL%ROWCOUNT) || ' rows into CST_RESOURCE_OVERHEADS');

l_stmt_no := 180;

Update CST_RES_OVERHEADS_INTERFACE croi
set process_flag = 5
where process_flag = 4
AND error_flag is null
AND group_id = SEQ_NEXTVAL;

IF i_del_option = 1 then
 delete from CST_RES_OVERHEADS_INTERFACE
 WHERE error_flag is null
 AND group_id = SEQ_NEXTVAL
 AND process_flag = 5;

fnd_file.put_line(fnd_file.log,'done deleting ' || to_char(SQL%ROWCOUNT) || ' row that were sucessfully processed' );
END IF;
COMMIT;

fnd_file.put_line(fnd_file.log,'-------done, quitting  validate resource overheads----------');

EXCEPTION
   when others then
       rollback;
       fnd_file.put_line(fnd_file.log,'Validate_resource_overheads('|| to_char(l_stmt_no)|| '),'||to_char(SQLCODE)||',' || substr(SQLERRM,1,180));
   Error_number := 1;

 CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));
END Validate_Resource_overheads;

/* This procedure Start_process is the starting point in the program.This
   Procedure actually decides which procedures need to be called */


Procedure Start_process(Error_number OUT NOCOPY NUMBER
                        ,i_cst_type IN VARCHAR2
                        ,i_Next_value IN  VARCHAR2
                        ,i_grp_id IN NUMBER
                        ,i_del_option IN NUMBER
                        ,i_run_option IN NUMBER) is

CST_ERR_EXCEPTION EXCEPTION;
Err NUMBER := 0;
CONC_REQUEST BOOLEAN;
i_count NUMBER;
BEGIN

Error_number := 0;
IF i_Next_value is null then
    UPDATE CST_DEPT_OVERHEADS_INTERFACE cdoi
    SET group_id = i_grp_id
    where process_flag = 1
    AND error_flag is null;


    UPDATE CST_RES_OVERHEADS_INTERFACE croi
    SET group_id = i_grp_id
    where process_flag = 1
    AND error_flag is null;
END IF;

Validate_department_overheads(Err,i_cst_type,i_grp_id,i_del_option,i_run_option);

IF Err = 1 then
 raise CST_ERR_EXCEPTION;
END IF;

Validate_resource_overheads(Err,i_cst_type,i_grp_id,i_del_option,i_run_option);

IF Err = 1 then
 raise CST_ERR_EXCEPTION;
END IF;

Select count(*) into i_count from CST_DEPT_OVERHEADS_INTERFACE
where group_id = i_grp_id
and error_flag = 'E';

if i_count > 0 then
fnd_file.put_line(fnd_file.log,(fnd_message.get_string('BOM','CST_MSG_CDOI')));
 CONC_REQUEST := fnd_concurrent.set_completion_status('WARNING',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));
END IF;

Select count(*) into i_count from CST_RES_OVERHEADS_INTERFACE
where group_id = i_grp_id
and error_flag = 'E';

if i_count > 0 then
fnd_file.put_line(fnd_file.log,(fnd_message.get_string('BOM','CST_MSG_CROI')));
CONC_REQUEST := fnd_concurrent.set_completion_status('WARNING',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));
END IF;

EXCEPTION
  when others then
    rollback;
    fnd_file.put_line(fnd_file.log,'Start_process() Exception Occured');
    Error_number := 1;

 CONC_REQUEST := fnd_concurrent.set_completion_status('ERROR',substrb((fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')),1,240));

END Start_process;

END CST_OVHD_RATE_IMPORT_INTERFACE;

/
