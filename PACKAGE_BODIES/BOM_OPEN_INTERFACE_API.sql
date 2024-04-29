--------------------------------------------------------
--  DDL for Package Body BOM_OPEN_INTERFACE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OPEN_INTERFACE_API" AS
/* $Header: BOMPBOIB.pls 120.6.12010000.3 2010/03/24 23:43:02 umajumde ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMPBOIB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Open_Interface_Api
--
--  NOTES
--
--  HISTORY
--
--  22-NOV-02   Vani Hymavathi    Initial Creation
--  06-May-05   Abhishek Rudresh  Common BOM Attr Update
--  01-JUN-05   Bhavnesh Patel    Added Batch Id
--  13-JUL-06   Bhavnesh Patel    Added support for Structure Type
***************************************************************************/

l_bom_header_rec         Bom_Bo_Pub.bom_Head_Rec_Type;
l_bom_revision_tbl       Bom_Bo_Pub.Bom_Revision_Tbl_Type;
l_bom_component_tbl      Bom_Bo_pub.Bom_Comps_Tbl_Type;
l_bom_ref_designator_tbl Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
l_bom_sub_component_tbl  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
l_bom_comp_ops_tbl       Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;

--for updating interface tables
l_bom_revision_rec          Bom_Bo_Pub.Bom_Revision_Rec_Type;
l_bom_component_rec         Bom_Bo_Pub.Bom_Comps_Rec_Type;
l_bom_ref_designator_rec    Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
l_bom_sub_component_rec     Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
l_bom_comp_ops_rec          Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;

Function Update_Interface_tables (
    err_text   IN OUT NOCOPY  VARCHAR2)
return integer;


FUNCTION Delete_Bom_OI (
        err_text    IN OUT NOCOPY VARCHAR2,
        p_batch_id  IN	NUMBER
)return integer;

/*--------------------------Import_BOM----------------------------------------

NAME
   Import_BOM
DESCRIPTION
    Import Bill, Components, Substitute Components, Reference Designators
    and Component Operations for null batch id .
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Import_BOM
(org_id IN  NUMBER ,
all_org IN  NUMBER:=1,
user_id IN  NUMBER:=-1,
login_id  IN  NUMBER:=-1,
prog_appid  IN  NUMBER:=-1,
prog_id IN  NUMBER:=-1,
req_id  IN  NUMBER:=-1,
del_rec_flag  IN  NUMBER:=1,
err_text  IN OUT NOCOPY VARCHAR2)
  return integer
IS
  l_return_status INTEGER := 0;
BEGIN

  --call the import_bom with null batch id.
  l_return_status := Import_BOM
                      (org_id => org_id,
                      all_org => all_org,
                      user_id => user_id,
                      login_id => login_id,
                      prog_appid => prog_appid,
                      prog_id => prog_id,
                      req_id => req_id,
                      del_rec_flag => del_rec_flag,
                      err_text => err_text,
                      p_batch_id  => NULL);

  RETURN l_return_status;
END;


/*--------------------------Import_BOM----------------------------------------

NAME
   Import_BOM
DESCRIPTION
    Import Bill, Components, Substitute Components, Reference Designators
    and Component Operations for given batch id .
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Import_BOM
(org_id IN  NUMBER ,
all_org IN  NUMBER:=1,
user_id IN  NUMBER:=-1,
login_id  IN  NUMBER:=-1,
prog_appid  IN  NUMBER:=-1,
prog_id IN  NUMBER:=-1,
req_id  IN  NUMBER:=-1,
del_rec_flag  IN  NUMBER:=1,
err_text  IN OUT NOCOPY VARCHAR2,
p_batch_id  IN	NUMBER)
return integer IS

cursor get_bills is
select * from BOM_BILL_OF_MTLS_INTERFACE
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
)
order by alternate_bom_designator DESC;

bill_rec get_bills%ROWTYPE;

cursor get_comps (cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_des varchar2) is
select /*+ index(a BOM_INV_COMPS_INTERFACE_N6) */ * from BOM_INVENTORY_COMPS_INTERFACE A  /*Bug 8213562: Added hint*/
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and   assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and (alternate_bom_designator is NULL or
(alternate_bom_designator is not Null and
alternate_bom_designator= cp_alt_des))
and transaction_id is not null
and change_notice is null --added for bug 9447664
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

comp_rec get_comps%ROWTYPE;

cursor get_orphan_comps is
select * from BOM_INVENTORY_COMPS_INTERFACE
where process_flag = 1
and all_org = 1
and transaction_id is not null
and change_notice is null --added for bug 9447664
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
)
and rownum = 1
UNION ALL
SELECT * FROM BOM_INVENTORY_COMPS_INTERFACE
WHERE process_flag = 1
AND all_org = 2 and organization_id = org_id
AND transaction_id is not null
and change_notice is null --added for bug 9447664
AND rownum =1
AND
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

orp_cmp_rec get_orphan_comps%ROWTYPE;

cursor get_revs (cp_ass_item_name varchar2, cp_org_code varchar2) is
select * from mtl_item_revisions_interface
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and   item_number = cp_ass_item_name
and organization_code = cp_org_code
and transaction_id is not null
and change_notice is null --added for bug 9447664
and set_process_id = nvl(p_batch_id,0); -- Replace NULL batch id with 0 - table level default for set_process_id

rev_rec get_revs%ROWTYPE;

cursor get_orphan_revs is
select * from mtl_item_revisions_interface
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and transaction_id is not null
and change_notice is null --added for bug 9447664
and set_process_id = nvl(p_batch_id,0);

orp_rev_rec get_orphan_revs%ROWTYPE;

cursor get_ref_desg (cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_des varchar2) is
select * from BOM_REF_DESGS_INTERFACE
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and   assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and (alternate_bom_designator is NULL or
(alternate_bom_designator is not Null and
alternate_bom_designator= cp_alt_des))
and transaction_id is not null
and change_notice is null --added for bug 9447664
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

ref_rec get_ref_desg%ROWTYPE;

cursor get_orphan_ref_desg is
SELECT *
FROM BOM_REF_DESGS_INTERFACE
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and transaction_id is not null
and change_notice is null --added for bug 9447664
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

orp_ref_rec get_orphan_ref_desg%ROWTYPE;

cursor get_sub_comps (cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_des varchar2) is
select * from bom_sub_comps_interface
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and   assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and (alternate_bom_designator is NULL or
(alternate_bom_designator is not Null and
alternate_bom_designator= cp_alt_des))
and transaction_id is not null
and change_notice is null --added for bug 9447664
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

sub_rec get_sub_comps%ROWTYPE;

cursor get_orphan_sub_comps is
SELECT * FROM BOM_SUB_COMPS_INTERFACE
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and transaction_id is not null
and change_notice is null --added for bug 9447664
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

orp_sub_rec get_orphan_sub_comps%ROWTYPE;

cursor get_comp_ops (cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_des varchar2) is
SELECT *  FROM BOM_COMPONENT_OPS_INTERFACE
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and   assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and (alternate_bom_designator is NULL or
(alternate_bom_designator is not Null and
alternate_bom_designator= cp_alt_des))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

ops_rec get_comp_ops%ROWTYPE;

cursor get_orphan_comp_ops is
SELECT * FROM BOM_COMPONENT_OPS_INTERFACE
where process_flag = 1
and (all_org = 1 or (all_org = 2 and organization_id = org_id))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
or  ( p_batch_id = batch_id )
);

orp_ops_rec get_orphan_comp_ops%ROWTYPE;

  l_return_status       Varchar2(100);
  l_func_ret_status     INTEGER;
  l_msg_count           Number;
  l_bills_exists Varchar2(3) := 'YES';
  l_comps_exists Varchar2(3) := 'YES';
  l_revs_exists Varchar2(3) := 'YES';
  l_ref_desgs_exists Varchar2(3) :='YES';
  l_sub_comps_exists Varchar2(3) :='YES';
  l_comp_ops_exists  Varchar2(3) :='YES';
--  l_assembly_item_name Varchar2(81);
  l_assembly_item_name Varchar2(240); -- bug 2947642
  l_organization_code Varchar2(3);
  l_alternate_designator Varchar2(10);
  i NUMBER;
  stmt_num NUMBER;
  debug_on Varchar2(1) := 'Y';
  empty_bo Varchar2(3) := 'YES';
BEGIN
    l_func_ret_status := 0;
stmt_num := 0;
   IF FND_PROFILE.VALUE('MRP_DEBUG') = 'Y' then
     debug_on := 'Y';
   else
     debug_on :='N';
   end if;

stmt_num := 1;
--commented by vhymavat for bug 3179687
/*
          fnd_global.apps_initialize
          (  user_id      => user_id,
             resp_id      =>FND_PROFILE.value('RESP_ID'),
             resp_appl_id => prog_appid
          );
*/
BOM_GLOBALS.G_BATCH_ID := p_batch_id;   -- Bug 4306013

stmt_num :=2;
          -- Initialize the error handling table
          ERROR_HANDLER.INITIALIZE ;

stmt_num :=3;

          -- Set the Global Variable to BOM Open Interface type.
                Error_Handler.set_bom_oi;

stmt_num :=4;
          -- Convert the Derived columns to User friendly columns

    l_return_status :=   Bom_Open_Interface_Utl.Process_Header_Info
                                (org_id,all_org,user_id,login_id,
                                prog_appid,prog_id,req_id,err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
    l_return_status :=   Bom_Open_Interface_Utl.Process_Comps_Info
                                (org_id,all_org,user_id,login_id,
                                prog_appid,prog_id,req_id,err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
     l_return_status :=   Bom_Open_Interface_Utl.Process_Ref_Degs_Info
                                (org_id,all_org,user_id,login_id,
                                prog_appid,prog_id,req_id,err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
      l_return_status :=   Bom_Open_Interface_Utl.Process_Sub_Comps_Info
                                (org_id,all_org,user_id,login_id,
                                prog_appid,prog_id,req_id,err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
      l_return_status :=   Bom_Open_Interface_Utl.Process_Comp_Ops_Info
                                (org_id,all_org,user_id,login_id,
                                prog_appid,prog_id,req_id,err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
      l_return_status :=   Bom_Open_Interface_Utl.Process_Revision_Info
                                (org_id,all_org,user_id,login_id,
                                prog_appid,prog_id,req_id,err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;

stmt_num :=5;

        OPEN get_bills;
        LOOP

              /* Initialize all the variables in business object */

              l_bom_header_rec         := Bom_Bo_Pub.G_MISS_BOM_HEADER_REC;
              l_bom_revision_tbl       := Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL;
              l_bom_component_tbl      := Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
              l_bom_ref_designator_tbl := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL;
              l_bom_sub_component_tbl  := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL;
              l_bom_comp_ops_tbl       := Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL;
              l_assembly_item_name := NULL;
              l_organization_code  := NULL;
              l_alternate_designator := NULL;
              empty_bo :='YES';

              /* Get the parent header information  l_assembly_item_name
              l_organization_code, l_alternate_bom_designator */

        If (l_bills_exists = 'YES') then
                FETCH get_bills into bill_rec;
                If (get_bills %NOTFOUND) then
                        l_bills_exists := 'NO';
                        CLOSE get_bills;
                else
                        l_bills_exists :='YES';
                        l_assembly_item_name := bill_rec.item_number;
                        l_organization_code :=bill_rec.organization_code;
                        l_alternate_designator :=bill_rec.alternate_bom_designator;
                END IF; -- get_bills%notfound

        ELSIF (l_comps_exists ='YES') then
                OPEN get_orphan_comps;
                FETCH get_orphan_comps into orp_cmp_rec;
                If (get_orphan_comps%NOTFOUND) then
                        l_comps_exists := 'NO';
                else
                        l_comps_exists :='YES';
                        l_assembly_item_name := orp_cmp_rec.assembly_item_number;
                        l_organization_code :=orp_cmp_rec.organization_code;
                        l_alternate_designator :=orp_cmp_rec.alternate_bom_designator;

                end if; --get_orphan_comps%NOTFOUND
                CLOSE get_orphan_comps;
  ELSIF (l_revs_exists ='YES') then
                OPEN get_orphan_revs;
                FETCH get_orphan_revs into orp_rev_rec;
                If (get_orphan_revs%NOTFOUND) then
                        l_revs_exists := 'NO';
                else
                        l_revs_exists :='YES';
                        l_assembly_item_name := orp_rev_rec.item_number;
                        l_organization_code :=orp_rev_rec.organization_code;
                        --l_alternate_designator :=orp_rev_rec.alternate_bom_designator;

                end if; --get_orphan_revs%NOTFOUND
                CLOSE get_orphan_revs;

        ELSIF (l_ref_desgs_exists ='YES')  then
                OPEN get_orphan_ref_desg;
                FETCH get_orphan_ref_desg into orp_ref_rec;

                If (get_orphan_ref_desg%NOTFOUND) then
                        l_ref_desgs_exists  := 'NO';
                else
                        l_ref_desgs_exists  :='YES';
                        l_assembly_item_name := orp_ref_rec.assembly_item_number;
                        l_organization_code :=orp_ref_rec.organization_code;
                        l_alternate_designator :=orp_ref_rec.alternate_bom_designator;
                end if; --get_orphan_ref_desg %NOTFOUND
                CLOSE get_orphan_ref_desg;

        ELSIF (l_sub_comps_exists  ='YES')  then
                OPEN get_orphan_sub_comps;
                FETCH get_orphan_sub_comps into orp_sub_rec;

                If (get_orphan_sub_comps%NOTFOUND) then
                        l_sub_comps_exists   := 'NO';
                else
                        l_sub_comps_exists   :='YES';
                        l_assembly_item_name := orp_sub_rec.assembly_item_number;
                        l_organization_code :=orp_sub_rec.organization_code;
                        l_alternate_designator :=orp_sub_rec.alternate_bom_designator;

                end if; --get_orphan_sub_comps %NOTFOUND
                CLOSE get_orphan_sub_comps;
        ELSIF (l_comp_ops_exists  ='YES')  then
                OPEN get_orphan_comp_ops;
                FETCH get_orphan_comp_ops into orp_ops_rec;

                If (get_orphan_comp_ops%NOTFOUND) then
                        l_comp_ops_exists  := 'NO';
                        EXIT ; -- MAIN LOOP
                else
                        l_comp_ops_exists  :='YES';
                        l_assembly_item_name := orp_ops_rec.assembly_item_number;
                        l_organization_code :=orp_ops_rec.organization_code;
                        l_alternate_designator :=orp_ops_rec.alternate_bom_designator;

                end if; --get_orphan_comp_ops%NOTFOUND
                CLOSE get_orphan_comp_ops;
        END IF; -- l_bills_exists,l_comp_exists,l_ref_desgs_exists,l_sub_comps_exists,l_comp_ops_exists
               /* Populate the interface records into the BO variables and call BO */

stmt_num :=6;
       IF ( l_assembly_item_name IS NOT NULL and l_organization_code is not null) then

        If (l_bills_exists = 'YES' ) then
                empty_bo := 'NO';

        IF(bill_rec.Transaction_Type <> 'NO_OP')
         THEN
                l_bom_header_rec.Assembly_item_name      := bill_rec.item_number;
                l_bom_header_rec.Organization_Code       := bill_rec.Organization_Code;
                l_bom_header_rec.Alternate_Bom_Code      := bill_rec.ALTERNATE_BOM_DESIGNATOR;
                l_bom_header_rec.Common_Assembly_Item_Name := bill_rec.COMMON_ITEM_NUMBER;
                l_bom_header_rec.Common_Organization_Code := bill_rec.COMMON_ORG_CODE;
                l_bom_header_rec.Assembly_Comment         := bill_rec.SPECIFIC_ASSEMBLY_COMMENT;
                l_bom_header_rec.Assembly_Type      := nvl( bill_rec.Assembly_Type,1);
                l_bom_header_rec.Transaction_Type   := bill_rec.Transaction_Type;
                l_bom_header_rec.Return_Status      := '';
                l_bom_header_rec.Attribute_category := bill_rec.Attribute_category;
                l_bom_header_rec.Attribute1  := bill_rec.Attribute1;
                l_bom_header_rec.Attribute2  := bill_rec.Attribute2;
                l_bom_header_rec.Attribute3 := bill_rec.Attribute3;
                l_bom_header_rec.Attribute4  := bill_rec.Attribute4;
                l_bom_header_rec.Attribute5  := bill_rec.Attribute5 ;
                l_bom_header_rec.Attribute6  := bill_rec.Attribute6;
                l_bom_header_rec.Attribute7  := bill_rec.Attribute7;
                l_bom_header_rec.Attribute8  := bill_rec.Attribute8;
                l_bom_header_rec.Attribute9  := bill_rec.Attribute9;
                l_bom_header_rec.Attribute10 := bill_rec.Attribute10;
                l_bom_header_rec.Attribute11 := bill_rec.Attribute11;
                l_bom_header_rec.Attribute12 := bill_rec.Attribute12;
                l_bom_header_rec.Attribute13 := bill_rec.Attribute13;
                l_bom_header_rec.Attribute14 := bill_rec.Attribute14;
                l_bom_header_rec.Attribute15 := bill_rec.Attribute15;
                l_bom_header_rec.Original_System_Reference:= bill_rec.Original_System_Reference;
                l_bom_header_rec.Delete_Group_Name   := bill_rec.Delete_Group_Name;
                l_bom_header_rec.DG_Description      := bill_rec.DG_Description;
                l_bom_header_rec.bom_implementation_date  := bill_rec.IMPLEMENTATION_DATE;
                l_bom_header_rec.row_identifier := bill_rec.transaction_id;
                l_bom_header_rec.enable_attrs_update := bill_rec.enable_attrs_update;
                l_bom_header_rec.Structure_Type_Name := bill_rec.Structure_Type_Name;
        END IF;

stmt_num:=7;
        END IF;

        If (l_bills_exists = 'YES' or l_comps_exists = 'YES' or l_revs_exists = 'YES') then

                OPEN get_revs (l_assembly_item_name, l_organization_code);
                i := 0;
                LOOP
                FETCH get_revs into rev_rec;
                EXIT WHEN get_revs%NOTFOUND;

                i:=i+1;
                if (i=1) then empty_bo := 'NO'; end if;
                l_bom_revision_tbl(i).Organization_Code     := l_organization_code ;
                l_bom_revision_tbl(i).Assembly_Item_Name     :=l_assembly_item_name ;
                l_bom_revision_tbl(i).Alternate_BOM_Code   := l_alternate_designator;
                l_bom_revision_tbl(i).Revision  := rev_rec.Revision;
                l_bom_revision_tbl(i).Revision_Label  := rev_rec.Revision_Label;
                l_bom_revision_tbl(i).Revision_Reason  := rev_rec.Revision_Reason;
                l_bom_revision_tbl(i).Start_Effective_Date  := rev_rec.Effectivity_Date;
                l_bom_revision_tbl(i).Description  :=  rev_rec.Description;
                l_bom_revision_tbl(i).Attribute_category :=rev_rec.Attribute_category;
                l_bom_revision_tbl(i).Attribute1  := rev_rec.Attribute1;
                l_bom_revision_tbl(i).Attribute2  := rev_rec.Attribute2;
                l_bom_revision_tbl(i).Attribute3  := rev_rec.Attribute3;
                l_bom_revision_tbl(i).Attribute4  := rev_rec.Attribute4;
                l_bom_revision_tbl(i).Attribute5  := rev_rec.Attribute5;
                l_bom_revision_tbl(i).Attribute6  := rev_rec.Attribute6;
                l_bom_revision_tbl(i).Attribute7  := rev_rec.Attribute7;
                l_bom_revision_tbl(i).Attribute8  := rev_rec.Attribute8;
                l_bom_revision_tbl(i).Attribute9  := rev_rec.Attribute9;
                l_bom_revision_tbl(i).Attribute10 := rev_rec.Attribute10;
                l_bom_revision_tbl(i).Attribute11 := rev_rec.Attribute11;
                l_bom_revision_tbl(i).Attribute12 := rev_rec.Attribute12;
                l_bom_revision_tbl(i).Attribute13 := rev_rec.Attribute13;
                l_bom_revision_tbl(i).Attribute14 := rev_rec.Attribute14;
                l_bom_revision_tbl(i).Attribute15 := rev_rec.Attribute15;
                l_bom_revision_tbl(i).Return_Status  := '';
                l_bom_revision_tbl(i).Transaction_Type  := rev_rec.Transaction_Type;
                --l_bom_revision_tbl(i).Original_System_Reference:= rev_rec.Original_System_Reference;
    l_bom_revision_tbl(i).row_identifier := rev_rec.transaction_id;

                END LOOP;
                CLOSE get_revs;
stmt_num:=8;
                OPEN get_comps (l_assembly_item_name, l_organization_code, l_alternate_designator);

                i := 0;
                LOOP
                FETCH get_comps  into comp_rec;
                EXIT WHEN get_comps%NOTFOUND;

                i:=i+1;
                if (i=1) then empty_bo := 'NO'; end if;
                l_bom_component_tbl(i).Organization_Code     :=  l_organization_code ;
                l_bom_component_tbl(i).Assembly_Item_Name     :=l_assembly_item_name;
/* commented for bug3242208
                l_bom_component_tbl(i).Alternate_BOM_Code   := l_alternate_designator;
*/
                l_bom_component_tbl(i).Alternate_BOM_Code   := comp_rec.alternate_bom_designator;
                l_bom_component_tbl(i).Start_Effective_Date  := comp_rec.Effectivity_Date;
                l_bom_component_tbl(i).Disable_Date     :=comp_rec.Disable_Date;
                l_bom_component_tbl(i).Operation_Sequence_Number    :=  comp_rec.OPERATION_SEQ_NUM;
                l_bom_component_tbl(i).Component_Item_Name   := comp_rec.Component_Item_Number;
                l_bom_component_tbl(i).New_Effectivity_Date  := comp_rec.New_Effectivity_Date;
                l_bom_component_tbl(i).New_Operation_Sequence_Number   := comp_rec.New_Operation_Seq_Num;
                l_bom_component_tbl(i).Item_Sequence_Number   :=  comp_rec.ITEM_NUM;
                l_bom_component_tbl(i).Basis_Type    := comp_rec.BASIS_TYPE;
                l_bom_component_tbl(i).Quantity_Per_Assembly  := comp_rec.COMPONENT_QUANTITY;
                l_bom_component_tbl(i).Inverse_Quantity  := comp_rec.Inverse_Quantity;
                l_bom_component_tbl(i).Planning_Percent  := comp_rec.Planning_Factor;
                l_bom_component_tbl(i).Projected_Yield     :=  comp_rec.COMPONENT_YIELD_FACTOR;
                l_bom_component_tbl(i).Include_In_Cost_Rollup := comp_rec.Include_In_Cost_Rollup;
                l_bom_component_tbl(i).Wip_Supply_Type     := comp_rec.Wip_Supply_Type;
                l_bom_component_tbl(i).So_Basis     :=comp_rec.So_Basis;
                l_bom_component_tbl(i).Optional     := comp_rec.Optional;
                l_bom_component_tbl(i).Mutually_Exclusive     :=  comp_rec.Mutually_Exclusive_options;
                l_bom_component_tbl(i).Check_Atp     :=comp_rec.Check_Atp;
                l_bom_component_tbl(i).Shipping_Allowed     := comp_rec.Shipping_Allowed;
                l_bom_component_tbl(i).Required_To_Ship     := comp_rec.Required_To_Ship;
                l_bom_component_tbl(i).Required_For_Revenue  :=  comp_rec.Required_For_Revenue;
                l_bom_component_tbl(i).Include_On_Ship_Docs  := comp_rec.Include_On_Ship_Docs;
                l_bom_component_tbl(i).Quantity_Related     :=  comp_rec.Quantity_Related;
                l_bom_component_tbl(i).Supply_Subinventory   :=comp_rec.Supply_Subinventory;
                l_bom_component_tbl(i).Location_Name     := comp_rec.Location_Name;
                l_bom_component_tbl(i).Minimum_Allowed_Quantity :=   comp_rec.low_Quantity;
                l_bom_component_tbl(i).Maximum_Allowed_Quantity     := comp_rec.high_Quantity;
                l_bom_component_tbl(i).Comments     := comp_rec.Component_remarks;
                l_bom_component_tbl(i).Attribute_category     := comp_rec.Attribute_category;
                l_bom_component_tbl(i).Attribute1  :=comp_rec.Attribute1;
                l_bom_component_tbl(i).Attribute2  := comp_rec.Attribute2;
                l_bom_component_tbl(i).Attribute3  := comp_rec.Attribute3;
                l_bom_component_tbl(i).Attribute4  :=comp_rec.Attribute4;
                l_bom_component_tbl(i).Attribute5  := comp_rec.Attribute5;
                l_bom_component_tbl(i).Attribute6  := comp_rec.Attribute6;
                l_bom_component_tbl(i).Attribute7  := comp_rec.Attribute7;
                l_bom_component_tbl(i).Attribute8  :=comp_rec.Attribute8;
                l_bom_component_tbl(i).Attribute9  := comp_rec.Attribute9;
                l_bom_component_tbl(i).Attribute10 :=comp_rec.Attribute10;
                l_bom_component_tbl(i).Attribute11 :=comp_rec.Attribute11;
                l_bom_component_tbl(i).Attribute12 := comp_rec.Attribute12;
                l_bom_component_tbl(i).Attribute13 := comp_rec.Attribute13;
                l_bom_component_tbl(i).Attribute14 := comp_rec.Attribute14;
                l_bom_component_tbl(i).Attribute15 :=comp_rec.Attribute15;
                l_bom_component_tbl(i).From_End_Item_Unit_Number    :=comp_rec.From_End_Item_Unit_Number;
                l_bom_component_tbl(i).New_From_End_Item_Unit_Number    :=  comp_rec.New_From_End_Item_Unit_Number;
                l_bom_component_tbl(i).To_End_Item_Unit_Number     := comp_rec.To_End_Item_Unit_Number;
                l_bom_component_tbl(i).Suggested_Vendor_Name     := comp_rec.Suggested_Vendor_Name; --- Deepu
--                l_bom_component_tbl(i).Vendor_Id   := comp_rec.Vendor_Id; --- Deepu
                l_bom_component_tbl(i).Unit_Price  := comp_rec.Unit_Price; --- Deepu
                l_bom_component_tbl(i).Return_Status     := '';
                l_bom_component_tbl(i).Transaction_Type     :=  comp_rec.Transaction_Type;
                l_bom_component_tbl(i).Original_System_Reference     := comp_rec.Original_System_Reference;
                l_bom_component_tbl(i).Delete_Group_Name     :=comp_rec.Delete_Group_Name;
                l_bom_component_tbl(i).DG_Description     := comp_rec.DG_Description;
    		l_bom_component_tbl(i).row_identifier := comp_rec.transaction_id;
    		l_bom_component_tbl(i).Enforce_Int_Requirements := comp_rec.ENFORCE_INT_REQUIREMENTS;
		l_bom_component_tbl(i).Auto_Request_Material    := comp_rec.Auto_request_Material; -- Bug 5257896(5252452)

                END LOOP;
                CLOSE get_comps;
stmt_num:=9;
        END IF; -- l_bills_exists or l_comps_exists

                OPEN get_ref_desg (l_assembly_item_name, l_organization_code, l_alternate_designator);
                i := 0;
                LOOP
                FETCH get_ref_desg into ref_rec;
                EXIT WHEN get_ref_desg%NOTFOUND;
                i:=i+1;

                if (i=1) then empty_bo := 'NO'; end if;
                l_bom_ref_designator_tbl(i).Organization_Code    :=  l_organization_code ;
                l_bom_ref_designator_tbl(i).Assembly_Item_Name   := l_assembly_item_name ;
                l_bom_ref_designator_tbl(i).Start_Effective_Date := ref_rec.EFFECTIVITY_DATE;
                l_bom_ref_designator_tbl(i).Operation_Sequence_Number  :=  ref_rec.OPERATION_SEQ_NUM;
                l_bom_ref_designator_tbl(i).Component_Item_Name  := ref_rec.Component_Item_Number;
                l_bom_ref_designator_tbl(i).Alternate_BOM_Code   :=l_alternate_designator;
                l_bom_ref_designator_tbl(i).Reference_Designator_Name :=ref_rec.COMPONENT_REFERENCE_DESIGNATOR;
                l_bom_ref_designator_tbl(i).Ref_Designator_Comment := ref_rec.REF_DESIGNATOR_COMMENT;
                l_bom_ref_designator_tbl(i).Attribute_category     := ref_rec.Attribute_category;
                l_bom_ref_designator_tbl(i).Attribute1  := ref_rec.Attribute1;
                l_bom_ref_designator_tbl(i).Attribute2  := ref_rec.Attribute2;
                l_bom_ref_designator_tbl(i).Attribute3  := ref_rec.Attribute3;
                l_bom_ref_designator_tbl(i).Attribute4  := ref_rec.Attribute4;
                l_bom_ref_designator_tbl(i).Attribute5  := ref_rec.Attribute5;
                l_bom_ref_designator_tbl(i).Attribute6  := ref_rec.Attribute6;
                l_bom_ref_designator_tbl(i).Attribute7  := ref_rec.Attribute7;
                l_bom_ref_designator_tbl(i).Attribute8  := ref_rec.Attribute8;
                l_bom_ref_designator_tbl(i).Attribute9  := ref_rec.Attribute9;
                l_bom_ref_designator_tbl(i).Attribute10 := ref_rec.Attribute10;
                l_bom_ref_designator_tbl(i).Attribute11 := ref_rec.Attribute11;
                l_bom_ref_designator_tbl(i).Attribute12 := ref_rec.Attribute12;
                l_bom_ref_designator_tbl(i).Attribute13 := ref_rec.Attribute13;
                l_bom_ref_designator_tbl(i).Attribute14 := ref_rec.Attribute14;
                l_bom_ref_designator_tbl(i).Attribute15 := ref_rec.Attribute15;
                l_bom_ref_designator_tbl(i).From_End_Item_Unit_Number   := ref_rec.From_End_Item_Unit_Number;
                l_bom_ref_designator_tbl(i).New_Reference_Designator    :=  ref_rec.New_Designator;
                l_bom_ref_designator_tbl(i).Return_Status     :=   '';
                l_bom_ref_designator_tbl(i).Transaction_Type  :=  ref_rec.Transaction_Type;
                l_bom_ref_designator_tbl(i).Original_System_Reference   := ref_rec.Original_System_Reference;
    l_bom_ref_designator_tbl(i).row_identifier := ref_rec.transaction_id;
                END LOOP;
                CLOSE get_ref_desg;


                OPEN get_sub_comps(l_assembly_item_name, l_organization_code, l_alternate_designator);
                i := 0;
                LOOP
                FETCH get_sub_comps into sub_rec;
                EXIT WHEN get_sub_comps%NOTFOUND;
                i:=i+1;
                if (i=1) then empty_bo := 'NO'; end if;
                l_bom_sub_component_tbl(i).Organization_Code     := l_organization_code;
                l_bom_sub_component_tbl(i).Assembly_Item_Name     := l_assembly_item_name;
                l_bom_sub_component_tbl(i).Start_Effective_Date  := sub_rec.EFFECTIVITY_DATE;
                l_bom_sub_component_tbl(i).Operation_Sequence_Number    :=sub_rec.OPERATION_SEQ_NUM;
                l_bom_sub_component_tbl(i).Component_Item_Name   := sub_rec.COMPONENT_ITEM_NUMBER;
                l_bom_sub_component_tbl(i).Alternate_BOM_Code   := l_alternate_designator;
                l_bom_sub_component_tbl(i).Substitute_Component_Name   :=sub_rec.SUBSTITUTE_COMP_NUMBER;
                l_bom_sub_component_tbl(i).new_Substitute_Component_Name   :=sub_rec.new_SUB_COMP_NUMBER;
                l_bom_sub_component_tbl(i).Substitute_Item_Quantity  :=sub_rec.Substitute_Item_Quantity;
                l_bom_sub_component_tbl(i).Inverse_Quantity  := sub_rec.SUB_COMP_INVERSE_QUANTITY;
                l_bom_sub_component_tbl(i).Attribute_category     := sub_rec.Attribute_category;
                l_bom_sub_component_tbl(i).Attribute1  := sub_rec.Attribute1;
                l_bom_sub_component_tbl(i).Attribute2  := sub_rec.Attribute2;
                l_bom_sub_component_tbl(i).Attribute3  := sub_rec.Attribute3;
                l_bom_sub_component_tbl(i).Attribute4  := sub_rec.Attribute4;
                l_bom_sub_component_tbl(i).Attribute5  := sub_rec.Attribute5;
                l_bom_sub_component_tbl(i).Attribute6  := sub_rec.Attribute6;
                l_bom_sub_component_tbl(i).Attribute7  := sub_rec.Attribute7;
                l_bom_sub_component_tbl(i).Attribute8  := sub_rec.Attribute8;
                l_bom_sub_component_tbl(i).Attribute9  := sub_rec.Attribute9;
                l_bom_sub_component_tbl(i).Attribute10 := sub_rec.Attribute10;
                l_bom_sub_component_tbl(i).Attribute11 := sub_rec.Attribute11;
                l_bom_sub_component_tbl(i).Attribute12 := sub_rec.Attribute12;
                l_bom_sub_component_tbl(i).Attribute13 := sub_rec.Attribute13;
                l_bom_sub_component_tbl(i).Attribute14 := sub_rec.Attribute14;
                l_bom_sub_component_tbl(i).Attribute15 := sub_rec.Attribute15;
                l_bom_sub_component_tbl(i).From_End_Item_Unit_Number :=sub_rec.From_End_Item_Unit_Number;
                l_bom_sub_component_tbl(i).Return_Status:= '';
                l_bom_sub_component_tbl(i).Transaction_Type := sub_rec.Transaction_Type;
                l_bom_sub_component_tbl(i).Original_System_Reference:=sub_rec.Original_System_Reference;
    l_bom_sub_component_tbl(i).row_identifier :=sub_rec.transaction_id;
    l_bom_sub_component_tbl(i).Enforce_Int_Requirements :=sub_rec.Enforce_Int_Requirements;

                END LOOP;

                CLOSE get_sub_comps;


                OPEN get_comp_ops  (l_assembly_item_name, l_organization_code, l_alternate_designator);
                i := 0;
                LOOP
                FETCH get_comp_ops  into ops_rec;
                EXIT WHEN get_comp_ops%NOTFOUND;
                i:=i+1;
                if (i=1) then empty_bo := 'NO'; end if;
                l_bom_comp_ops_tbl(i).Organization_Code     := l_organization_code;
                l_bom_comp_ops_tbl(i).Assembly_Item_Name     := l_assembly_item_name ;
                l_bom_comp_ops_tbl(i).Start_Effective_Date  := ops_rec.EFFECTIVITY_DATE;
                l_bom_comp_ops_tbl(i).From_End_Item_Unit_Number    := ops_rec.From_End_Item_Unit_Number;
                l_bom_comp_ops_tbl(i).To_End_Item_Unit_Number    := ops_rec.To_End_Item_Unit_Number;
                l_bom_comp_ops_tbl(i).Operation_Sequence_Number    :=ops_rec.Operation_Seq_Num;
                l_bom_comp_ops_tbl(i).Component_Item_Name   :=ops_rec.Component_Item_Number;
                l_bom_comp_ops_tbl(i).Additional_Operation_Seq_Num    :=ops_rec.Additional_Operation_Seq_Num;
                l_bom_comp_ops_tbl(i).New_Additional_Op_Seq_Num    :=ops_rec.New_Additional_Op_Seq_Num;
                l_bom_comp_ops_tbl(i).Alternate_BOM_Code   := l_alternate_designator;
                l_bom_comp_ops_tbl(i).Attribute_category     := ops_rec.Attribute_category;
                l_bom_comp_ops_tbl(i).Attribute1  := ops_rec.Attribute1;
                l_bom_comp_ops_tbl(i).Attribute2  :=ops_rec.Attribute2;
                l_bom_comp_ops_tbl(i).Attribute3  :=ops_rec.Attribute3;
                l_bom_comp_ops_tbl(i).Attribute4  := ops_rec.Attribute4;
                l_bom_comp_ops_tbl(i).Attribute5  := ops_rec.Attribute5;
                l_bom_comp_ops_tbl(i).Attribute6  :=ops_rec.Attribute6;
                l_bom_comp_ops_tbl(i).Attribute7  := ops_rec.Attribute7;
                l_bom_comp_ops_tbl(i).Attribute8  :=ops_rec.Attribute8;
                l_bom_comp_ops_tbl(i).Attribute9  := ops_rec.Attribute9;
                l_bom_comp_ops_tbl(i).Attribute10 := ops_rec.Attribute10;
                l_bom_comp_ops_tbl(i).Attribute11 := ops_rec.Attribute11;
                l_bom_comp_ops_tbl(i).Attribute12 := ops_rec.Attribute12;
                l_bom_comp_ops_tbl(i).Attribute13 := ops_rec.Attribute13;
                l_bom_comp_ops_tbl(i).Attribute14 :=ops_rec.Attribute14;
                l_bom_comp_ops_tbl(i).Attribute15 := ops_rec.Attribute15;
                l_bom_comp_ops_tbl(i).Return_Status     :='';
                l_bom_comp_ops_tbl(i).Transaction_Type     :=ops_rec.Transaction_Type;
                l_bom_comp_ops_tbl(i).row_identifier :=ops_rec.transaction_id;


                END LOOP;
                CLOSE get_comp_ops;

stmt_num:=10;

         if (empty_bo ='NO') then
               bom_bo_pub.Process_Bom
              (  p_bo_identifier          => 'BOM'
               , p_api_version_number     => 1.0
               , p_init_msg_list          => TRUE
               , p_bom_header_rec         => l_bom_header_rec
               , p_bom_revision_tbl       => l_bom_revision_tbl
               , p_bom_component_tbl      => l_bom_component_tbl
               , p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
               , p_bom_sub_component_tbl  => l_bom_sub_component_tbl
               , p_bom_comp_ops_tbl       => l_bom_comp_ops_tbl
               , x_bom_header_rec         => l_bom_header_rec
               , x_bom_revision_tbl       => l_bom_revision_tbl
               , x_bom_component_tbl      => l_bom_component_tbl
               , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
               , x_bom_sub_component_tbl  => l_bom_sub_component_tbl
               , x_bom_comp_ops_tbl       => l_bom_comp_ops_tbl
               , x_return_status          => l_return_status
               , x_msg_count              => l_msg_count
               , p_debug                  => debug_on
               , p_output_dir             => 'none'
               , p_debug_filename         => 'none'
               );
        else
          if (debug_on = 'Y') then
            fnd_file.put_line (Which => FND_FILE.LOG,
                              buff => 'Data Error, Empty BO is getting passed') ;
          end if;
          EXIT;
        end if;

stmt_num:=11;
          -- Error_handling for the openInterface
          Error_handler.Write_To_ConcurrentLog;
          Error_handler.Write_To_InterfaceTable;
          -- Error handling for the openInterface

stmt_num :=12;
            l_return_status := Update_Interface_tables (err_text);
               IF ( l_return_status NOT IN (0,1) ) THEN
                  RETURN(l_return_status);
               ELSIF ( l_return_status = 1 ) THEN
                 l_func_ret_status := 1;
               END IF;


         COMMIT;
        END IF; --ASSEMBLY_ITEM_NUMBER AND ORGANIZATION_CODE NOT NULL.
      END LOOP;

                Error_Handler.unset_bom_oi;
stmt_num :=13;
         if(del_rec_flag = 1) then
            l_return_status := Delete_Bom_OI(err_text,p_batch_id);
               IF (l_return_status <> 0) THEN
                  RETURN(l_return_status);
               END IF;
  end if;

stmt_num :=14;
--check if the main cursor is open and then close it
  If (get_bills%ISOPEN) then
         close get_bills;
        end if;

--return (0);
  return (l_func_ret_status);
EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Open_Interface_Api :'||stmt_num||substrb(SQLERRM,1,500);
      Error_Handler.unset_bom_oi;
      RETURN(SQLCODE);
End;



Function Update_Interface_tables (err_text   IN OUT NOCOPY  VARCHAR2)
return Integer
Is
  l_process_flag Number;
  stmt_num  Number;
  l_ret_status NUMBER;
begin
  --bug:5235742 When import completes with one or more entities having errors, return 1.
  l_ret_status := 0;
  stmt_num :=0;
   if l_bom_header_rec.Return_Status IS NULL then
       l_process_flag := 1;
   elsif (l_bom_header_rec.Return_Status = 'S') then
       l_process_flag := 7;
   else
       l_process_flag := 3;
       l_ret_status := 1;
   end if;

      Update bom_bill_of_mtls_interface
      set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
      where  transaction_id = l_bom_header_rec.Row_Identifier;

stmt_num :=1;
     FOR I IN 1..l_bom_revision_tbl.COUNT LOOP

      l_bom_revision_rec := l_bom_revision_tbl(I);

      if l_bom_revision_rec.Return_Status IS NULL then
         l_process_flag := 1;
      elsif (l_bom_revision_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status := 1;
      end if;

       Update mtl_item_revisions_interface
       set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
       where  transaction_id = l_bom_revision_rec.row_identifier;
     END LOOP;

stmt_num :=2;
     FOR I IN 1..l_bom_component_tbl.COUNT LOOP

      l_bom_component_rec := l_bom_component_tbl(I);

  if l_bom_component_rec.Return_Status IS NULL then
         l_process_flag := 1;
      elsif (l_bom_component_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status := 1;
      end if;

      Update bom_inventory_comps_interface
      set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
      where  transaction_id = l_bom_component_rec.row_identifier;
     END LOOP;

stmt_num :=3;
     FOR I IN 1..l_bom_ref_designator_tbl.COUNT LOOP

   l_bom_ref_designator_rec := l_bom_ref_designator_tbl(I);

     if l_bom_ref_designator_rec.Return_Status IS NULL then
          l_process_flag := 1;
      elsif (l_bom_ref_designator_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status := 1;
      end if;

       Update bom_ref_desgs_interface
       set   process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
       where  transaction_id = l_bom_ref_designator_rec.row_identifier;
     END LOOP;

stmt_num :=4;
     FOR I IN 1..l_bom_sub_component_tbl.COUNT LOOP
     l_bom_sub_component_rec := l_bom_sub_component_tbl(I);

     if l_bom_sub_component_rec.Return_Status IS NULL then
          l_process_flag := 1;
      elsif (l_bom_sub_component_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status := 1;
      end if;

     Update BOM_SUB_COMPS_INTERFACE
     set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
     where  transaction_id = l_bom_sub_component_rec.row_identifier;
     END LOOP;

stmt_num :=5;
     FOR I IN 1..l_bom_comp_ops_tbl.COUNT LOOP
     l_bom_comp_ops_rec := l_bom_comp_ops_tbl(I);

    if l_bom_comp_ops_rec.Return_Status IS NULL
        then  l_process_flag := 1;
      elsif (l_bom_comp_ops_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status := 1;
      end if;

     Update BOM_COMPONENT_OPS_INTERFACE
     set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
     where  transaction_id = l_bom_comp_ops_rec.row_identifier;
     END LOOP;

return (l_ret_status);

EXCEPTION
   WHEN others THEN
      err_text := 'Update_Interface_Tables'||stmt_num||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);

end Update_Interface_tables;



FUNCTION Delete_Bom_OI (
        err_text    IN OUT NOCOPY VARCHAR2,
        p_batch_id  IN	NUMBER
)
    return INTEGER
IS
    stmt_num    NUMBER;
BEGIN

stmt_num := 1;
loop
DELETE FROM BOM_BILL_OF_MTLS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
OR  ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 2;
loop
DELETE FROM BOM_INVENTORY_COMPS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
OR  ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 3;
loop
DELETE FROM BOM_REF_DESGS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
OR  ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 4;
loop
DELETE FROM BOM_COMPONENT_OPS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
OR  ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 5;
loop
DELETE FROM BOM_SUB_COMPS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
OR  ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 6;
loop
DELETE FROM MTL_ITEM_REVISIONS_INTERFACE
WHERE PROCESS_FLAG = 7
AND SET_PROCESS_ID = NVL(p_batch_id,0)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

return(0);

EXCEPTION
    when OTHERS THEN
        err_text := 'delete_bom_oi(' || stmt_num || ')' || substrb(SQLERRM,1,240);
        return(SQLCODE);
END Delete_Bom_OI;


END BOM_OPEN_INTERFACE_API;

/
