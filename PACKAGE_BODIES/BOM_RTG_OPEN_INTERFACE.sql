--------------------------------------------------------
--  DDL for Package Body BOM_RTG_OPEN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_OPEN_INTERFACE" AS
/* $Header: BOMPROIB.pls 120.8.12010000.2 2011/12/06 10:39:41 rambkond ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMPROIB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_RTG_OPEN_INTERFACE
--
--  NOTES
--
--  HISTORY
--
--  12-DEC-02   Deepak Jebar    Initial Creation
--  15-JUN-05   Abhishek Bhardwaj Added Batch Id
--
***************************************************************************/

g_UserId        number := -1;
g_LoginId       number;
g_RequestId     number;
g_ProgramId     number;
g_ApplicationId number;
g_rtg_header_rec	Bom_Rtg_Pub.Rtg_Header_Rec_Type;
g_rtg_revs_tbl		Bom_Rtg_Pub.Rtg_Revision_Tbl_Type;
g_op_tbl		Bom_Rtg_Pub.Operation_Tbl_Type;
g_op_res_tbl		Bom_Rtg_Pub.Op_Resource_Tbl_Type;
g_sub_op_res_tbl	Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
g_nwk_tbl		Bom_Rtg_Pub.Op_Network_Tbl_Type;

--for updating interface tables
g_rtg_revision_rec	Bom_Rtg_Pub.Rtg_Revision_Rec_Type;
g_op_rec		Bom_Rtg_Pub.Operation_Rec_Type;
g_op_res_rec		Bom_Rtg_Pub.Op_Resource_Rec_Type;
g_sub_op_res_rec	Bom_Rtg_Pub.Sub_Resource_Rec_Type;
g_nwk_rec		Bom_Rtg_Pub.Op_Network_Rec_Type;


FUNCTION Update_Rtg_Interface_Tables(
		x_err_text   IN OUT NOCOPY  VARCHAR2)
return integer;

FUNCTION Delete_Rtg_OI (
		x_err_text   IN OUT NOCOPY  VARCHAR2
		, p_batch_id IN	 NUMBER)		-- Added parameter p_batch_id for Batch Import
return integer;

-- Overloaded IMPORT_RTG for Batch Import
FUNCTION IMPORT_RTG
(  p_organization_id    IN  NUMBER
   , p_all_org   	IN  NUMBER
   , p_delete_rows 	IN  NUMBER
   , x_err_text		IN OUT NOCOPY VARCHAR2
) RETURN INTEGER
IS
  l_return_status INTEGER := 0;
BEGIN
  l_return_status := IMPORT_RTG
                      (p_organization_id => p_organization_id,
                      p_all_org => p_all_org,
                      p_delete_rows => p_delete_rows,
                      x_err_text => x_err_text,
                      p_batch_id  => NULL);
  RETURN l_return_status;
END;

FUNCTION IMPORT_RTG
(  p_organization_id	IN  NUMBER
   , p_all_org		IN  NUMBER
   , p_delete_rows	IN  NUMBER
   , x_err_text		IN OUT NOCOPY VARCHAR2
   , p_batch_id         IN  NUMBER
) RETURN INTEGER IS

cursor get_rtg_header is
select * from BOM_OP_ROUTINGS_INTERFACE
Where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
)
order by alternate_routing_designator desc; -- bug 3684819, we need primary routings to be processed first
rtg_header_rec get_rtg_header%ROWTYPE;

cursor get_rtg_revs (cp_ass_item_name varchar2, cp_org_code varchar2) is
select * from MTL_RTG_ITEM_REVS_INTERFACE
Where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and inventory_item_number = cp_ass_item_name
and organization_code = cp_org_code
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
)
order by process_revision; -- bug fix 3693102 we need to prorcess revs in alpha numeric sort order

rtg_revs_rec get_rtg_revs%ROWTYPE;

cursor get_orphan_revs is
select * from MTL_RTG_ITEM_REVS_INTERFACE
Where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);

orphan_revs_rec get_orphan_revs%ROWTYPE;

cursor get_op_seqs(cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_rtg_des varchar2) is
select * from BOM_OP_SEQUENCES_INTERFACE A
Where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and nvl(alternate_routing_designator, '##$$') = nvl(cp_alt_rtg_des,'##$$')
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
)
order by operation_type desc;

op_seqs_rec get_op_seqs%ROWTYPE;

/* Modified cursor for bug 4350033 */
cursor get_orphan_op_seqs is
select * from BOM_OP_SEQUENCES_INTERFACE A
Where process_flag = 1
and p_all_org = 1
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
)
and rownum = 1
UNION ALL
SELECT * from BOM_OP_SEQUENCES_INTERFACE A
Where process_flag = 1
and p_all_org = 2 and organization_Id = p_organization_id
and transaction_id is not null
and rownum = 1
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);



orphan_op_seqs_rec get_orphan_op_seqs%ROWTYPE;

cursor get_op_nwk(cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_rtg_des varchar2) is
select * from BOM_OP_NETWORKS_INTERFACE
Where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and nvl(alternate_routing_designator, '##$$') = nvl(cp_alt_rtg_des,'##$$')
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);
op_nwk_rec get_op_nwk%ROWTYPE;

cursor get_orphan_op_nwk is
select * from BOM_OP_NETWORKS_INTERFACE
Where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);

orphan_op_nwk_rec get_orphan_op_nwk%ROWTYPE;

cursor get_op_resources(cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_rtg_des varchar2) is
select * from BOM_OP_RESOURCES_INTERFACE A
where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and nvl(alternate_routing_designator, '##$$') = nvl(cp_alt_rtg_des,'##$$')
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);
op_res_rec get_op_resources%ROWTYPE;

cursor get_orphan_op_resources is
select * from BOM_OP_RESOURCES_INTERFACE
where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);
orphan_op_res_rec get_orphan_op_resources%ROWTYPE;

cursor get_sub_op_resources(cp_ass_item_name varchar2, cp_org_code varchar2, cp_alt_rtg_des varchar2) is
select * from BOM_SUB_OP_RESOURCES_INTERFACE
where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and assembly_item_number = cp_ass_item_name
and organization_code = cp_org_code
and nvl(alternate_routing_designator, '##$$') = nvl(cp_alt_rtg_des,'##$$')
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);
sub_op_res_rec get_sub_op_resources%ROWTYPE;

cursor get_orphan_sub_op_resources is
select * from BOM_SUB_OP_RESOURCES_INTERFACE
where process_flag = 1
and (p_all_org = 1 or (p_all_org = 2 and organization_id = p_organization_id))
and transaction_id is not null
and
(
    ( (p_batch_id is null) and (batch_id is null) )
    or ( p_batch_id = batch_id )
);
orphan_sub_op_res_rec get_orphan_sub_op_resources%ROWTYPE;

  i NUMBER;
  stmt_num NUMBER;
  debug_on Varchar2(1) := 'Y';
  l_msg_count NUMBER;
  ret_status  Varchar2(1);
  l_return_status  INTEGER;
  l_func_ret_status INTEGER;
--  l_assembly_item_name Varchar2(81);
  l_assembly_item_name Varchar2(240); -- bug 2947642
  l_org_code Varchar2(3);
  l_alt_rtg_desig Varchar2(10);
  empty_bo Varchar2(1) := 'Y';
  l_rtg_header_exists Varchar2(1) := 'Y';
  l_revs_exists Varchar2(1) := 'Y';
  l_op_exists Varchar2(1) := 'Y';
  l_op_res_exists Varchar2(1) :='Y';
  l_sub_op_res_exists Varchar2(1) :='Y';
  l_nwk_exists  Varchar2(1) :='Y';

BEGIN
    l_func_ret_status := 0;
stmt_num := 0;
   IF FND_PROFILE.VALUE('MRP_DEBUG') = 'Y' then
     debug_on := 'Y';
   else
     debug_on :='N';
   end if;

stmt_num := 1;
          -- who columns
	  g_UserId := nvl(Fnd_Global.USER_ID, -1);
	  g_LoginId := Fnd_Global.LOGIN_ID;
	  g_RequestId := Fnd_Global.CONC_REQUEST_ID;
	  g_ProgramId := Fnd_Global.CONC_PROGRAM_ID;
	  g_ApplicationId := Fnd_Global.PROG_APPL_ID;
--commented by vhymavat for bug 3179687
/*
	 fnd_global.apps_initialize
          (  user_id      => g_UserId,
             resp_id      => FND_PROFILE.value('RESP_ID'),
             resp_appl_id => g_ApplicationId
          );
*/


	  --  Initialize API return status to success
	  l_return_status := 0;
	  -- Set the Global Variable to Routing Open Interface type.
	  Error_Handler.set_bom_oi;

stmt_num := 2;
          -- Convert the Derived columns to User friendly columns
	  l_return_status :=   BOM_RTG_OI_UTIL.Process_Rtg_Header
                                (p_organization_id,p_all_org,g_UserId,g_LoginId,
                                g_ApplicationId,g_ProgramId,g_RequestId,x_err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
	  l_return_status :=   BOM_RTG_OI_UTIL.Process_Op_Seqs
                                (p_organization_id,p_all_org,g_UserId,g_LoginId,
                                g_ApplicationId,g_ProgramId,g_RequestId,x_err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
  	  l_return_status :=   BOM_RTG_OI_UTIL.Process_Op_Nwks
                                (p_organization_id,p_all_org,g_UserId,g_LoginId,
                                g_ApplicationId,g_ProgramId,g_RequestId,x_err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
  	  l_return_status :=   BOM_RTG_OI_UTIL.Process_Op_Resources
                                (p_organization_id,p_all_org,g_UserId,g_LoginId,
                                g_ApplicationId,g_ProgramId,g_RequestId,x_err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
  	  l_return_status :=   BOM_RTG_OI_UTIL.Process_Sub_Op_Resources
                                (p_organization_id,p_all_org,g_UserId,g_LoginId,
                                g_ApplicationId,g_ProgramId,g_RequestId,x_err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;
	  l_return_status :=   BOM_RTG_OI_UTIL.Process_Rtg_Revisions
                                (p_organization_id,p_all_org,g_UserId,g_LoginId,
                                g_ApplicationId,g_ProgramId,g_RequestId,x_err_text,p_batch_id);
          IF (l_return_status <> 0) THEN
                RETURN(l_return_status);
          END IF;

stmt_num :=3;
        OPEN get_rtg_header;
        LOOP

              /* Initialize all the variables in business object */

              g_rtg_header_rec		:= Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC;
              g_rtg_revs_tbl		:= Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL;
              g_op_tbl			:= Bom_Rtg_Pub.G_MISS_OPERATION_TBL;
              g_op_res_tbl		:= Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL;
              g_sub_op_res_tbl		:= Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL;
              g_nwk_tbl			:= Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL;
              l_assembly_item_name	:= NULL;
              l_org_code		:= NULL;
              l_alt_rtg_desig		:= NULL;
              empty_bo :='Y';

              /* Get the parent header information  l_assembly_item_name
              l_org_code, l_alt_rtg_desig */

        If (l_rtg_header_exists = 'Y') then
                FETCH get_rtg_header into rtg_header_rec;
                If (get_rtg_header%NOTFOUND) then
                        l_rtg_header_exists := 'N';
                        CLOSE get_rtg_header;
                else
                        l_rtg_header_exists :='Y';
                        l_assembly_item_name := rtg_header_rec.assembly_item_number;
                        l_org_code := rtg_header_rec.organization_code;
                        l_alt_rtg_desig := rtg_header_rec.alternate_routing_designator;
                END IF; -- get_rtg_header%notfound
	ELSIF (l_revs_exists ='Y') then
                OPEN get_orphan_revs;
                FETCH get_orphan_revs into orphan_revs_rec;
                If (get_orphan_revs%NOTFOUND) then
                        l_revs_exists := 'N';
                else
                        l_revs_exists :='Y';
                        l_assembly_item_name := orphan_revs_rec.INVENTORY_ITEM_NUMBER;
                        l_org_code := orphan_revs_rec.organization_code;
                end if; --get_orphan_revs%NOTFOUND
                CLOSE get_orphan_revs;
        ELSIF (l_op_exists ='Y') then
                OPEN get_orphan_op_seqs;
                FETCH get_orphan_op_seqs into orphan_op_seqs_rec;
                If (get_orphan_op_seqs%NOTFOUND) then
                        l_op_exists := 'N';
                else
                        l_op_exists :='Y';
                        l_assembly_item_name := orphan_op_seqs_rec.assembly_item_number;
                        l_org_code := orphan_op_seqs_rec.organization_code;
                        l_alt_rtg_desig := orphan_op_seqs_rec.alternate_routing_designator;
                end if; --get_orphan_op_seqs%NOTFOUND
                CLOSE get_orphan_op_seqs;
        ELSIF (l_op_res_exists ='Y')  then
                OPEN get_orphan_op_resources;
                FETCH get_orphan_op_resources into orphan_op_res_rec;

                If (get_orphan_op_resources%NOTFOUND) then
                        l_op_res_exists  := 'N';
                else
                        l_op_res_exists  :='Y';
                        l_assembly_item_name := orphan_op_res_rec.assembly_item_number;
                        l_org_code := orphan_op_res_rec.organization_code;
                        l_alt_rtg_desig := orphan_op_res_rec.alternate_routing_designator;
                end if; -- get_orphan_op_resources%NOTFOUND
                CLOSE get_orphan_op_resources;
        ELSIF (l_sub_op_res_exists  ='Y')  then
                OPEN get_orphan_sub_op_resources;
                FETCH get_orphan_sub_op_resources into orphan_sub_op_res_rec;

                If (get_orphan_sub_op_resources%NOTFOUND) then
                        l_sub_op_res_exists   := 'N';
                else
                        l_sub_op_res_exists   :='Y';
                        l_assembly_item_name := orphan_sub_op_res_rec.assembly_item_number;
                        l_org_code := orphan_sub_op_res_rec.organization_code;
                        l_alt_rtg_desig := orphan_sub_op_res_rec.alternate_routing_designator;
                end if; -- get_orphan_sub_op_resources%NOTFOUND
                CLOSE get_orphan_sub_op_resources;
        ELSIF (l_nwk_exists  ='Y')  then
                OPEN get_orphan_op_nwk;
                FETCH get_orphan_op_nwk into orphan_op_nwk_rec;

                If (get_orphan_op_nwk%NOTFOUND) then
                        l_nwk_exists  := 'N';
                        EXIT ; -- MAIN LOOP
                else
			l_nwk_exists  :='Y';
                        l_assembly_item_name := orphan_op_nwk_rec.assembly_item_number;
                        l_org_code := orphan_op_nwk_rec.organization_code;
                        l_alt_rtg_desig := orphan_op_nwk_rec.alternate_routing_designator;
                end if; --get_orphan_op_nwk%NOTFOUND
                CLOSE get_orphan_op_nwk;
        END IF;

               /* Populate the interface records into the BO variables and call BO */
stmt_num := 4;
       IF (l_assembly_item_name IS NOT NULL and l_org_code is not null) THEN

        If (l_rtg_header_exists = 'Y' ) THEN
                empty_bo := 'N';

       IF ( rtg_header_rec.TRANSACTION_TYPE <> 'NO_OP' )
          THEN   -- Bug 3411601

          g_rtg_header_rec.Assembly_Item_Name		:= l_assembly_item_name;--rtg_header_rec.ASSEMBLY_ITEM_NUMBER
	  g_rtg_header_rec.Organization_Code		:= l_org_code;--rtg_header_rec.ORGANIZATION_CODE
	  g_rtg_header_rec.Alternate_Routing_Code	:= l_alt_rtg_desig;--rtg_header_rec.ALTERNATE_ROUTING_DESIGNATOR
	  IF rtg_header_rec.ROUTING_TYPE = 1 THEN-- 2=Engineering routing 1=Manufacturing routing
		g_rtg_header_rec.Eng_Routing_Flag	:= 2;
	  ELSIF rtg_header_rec.ROUTING_TYPE = 2 THEN
		g_rtg_header_rec.Eng_Routing_Flag	:= 1;
	  END IF;
	  g_rtg_header_rec.Common_Assembly_Item_Name	:= rtg_header_rec.COMMON_ITEM_NUMBER;
	  g_rtg_header_rec.Routing_Comment		:= rtg_header_rec.ROUTING_COMMENT;
	  g_rtg_header_rec.Completion_Subinventory	:= rtg_header_rec.COMPLETION_SUBINVENTORY;
	  g_rtg_header_rec.Completion_Location_Name	:= rtg_header_rec.LOCATION_NAME;
	  g_rtg_header_rec.Line_Code			:= rtg_header_rec.LINE_CODE;
	  g_rtg_header_rec.CFM_Routing_Flag		:= rtg_header_rec.CFM_ROUTING_FLAG;
	  g_rtg_header_rec.Mixed_Model_Map_Flag		:= rtg_header_rec.MIXED_MODEL_MAP_FLAG;
	  g_rtg_header_rec.Priority			:= rtg_header_rec.PRIORITY;
	  g_rtg_header_rec.Total_Cycle_Time		:= rtg_header_rec.TOTAL_PRODUCT_CYCLE_TIME;
	  g_rtg_header_rec.CTP_Flag			:= rtg_header_rec.CTP_FLAG;
	  g_rtg_header_rec.Attribute_category		:= rtg_header_rec.ATTRIBUTE_CATEGORY;
	  g_rtg_header_rec.Attribute1			:= rtg_header_rec.ATTRIBUTE1;
	  g_rtg_header_rec.Attribute2			:= rtg_header_rec.ATTRIBUTE2;
	  g_rtg_header_rec.Attribute3			:= rtg_header_rec.ATTRIBUTE3;
	  g_rtg_header_rec.Attribute4			:= rtg_header_rec.ATTRIBUTE4;
	  g_rtg_header_rec.Attribute5			:= rtg_header_rec.ATTRIBUTE5;
	  g_rtg_header_rec.Attribute6			:= rtg_header_rec.ATTRIBUTE6;
	  g_rtg_header_rec.Attribute7			:= rtg_header_rec.ATTRIBUTE7;
	  g_rtg_header_rec.Attribute8			:= rtg_header_rec.ATTRIBUTE8;
	  g_rtg_header_rec.Attribute9			:= rtg_header_rec.ATTRIBUTE9;
	  g_rtg_header_rec.Attribute10			:= rtg_header_rec.ATTRIBUTE10;
	  g_rtg_header_rec.Attribute11			:= rtg_header_rec.ATTRIBUTE11;
	  g_rtg_header_rec.Attribute12			:= rtg_header_rec.ATTRIBUTE12;
	  g_rtg_header_rec.Attribute13			:= rtg_header_rec.ATTRIBUTE13;
	  g_rtg_header_rec.Attribute14			:= rtg_header_rec.ATTRIBUTE14;
	  g_rtg_header_rec.Attribute15			:= rtg_header_rec.ATTRIBUTE15;
	  g_rtg_header_rec.Original_System_Reference	:= rtg_header_rec.ORIGINAL_SYSTEM_REFERENCE; -- newly added
	  g_rtg_header_rec.Transaction_Type		:= rtg_header_rec.TRANSACTION_TYPE;
	  g_rtg_header_rec.Delete_Group_Name		:= rtg_header_rec.DELETE_GROUP_NAME; -- newly added
	  g_rtg_header_rec.DG_Description		:= rtg_header_rec.DG_DESCRIPTION; -- newly added
	  g_rtg_header_rec.Ser_Start_Op_Seq		:= rtg_header_rec.SERIALIZATION_START_OP; -- newly added
	  g_rtg_header_rec.Row_Identifier		:= rtg_header_rec.TRANSACTION_ID; -- newly added
          g_rtg_header_rec.Return_Status      := '';

        END IF;
       END IF;
stmt_num := 5;

        If (l_rtg_header_exists = 'Y' or l_op_exists = 'Y' or l_revs_exists = 'Y') THEN

                OPEN get_rtg_revs (l_assembly_item_name, l_org_code);
                i := 0;
                LOOP
                FETCH get_rtg_revs into rtg_revs_rec;
                EXIT WHEN get_rtg_revs%NOTFOUND;

                i:=i+1;
                if (i=1) then empty_bo := 'N';
		end if;

                -- Bug 5970070. Added nvl condition for start_effective_date
		g_rtg_revs_tbl(i).Assembly_Item_Name	:= l_assembly_item_name; --rtg_revs_rec.ITEM_NUMBER
		g_rtg_revs_tbl(i).Organization_Code	:= l_org_code; --rtg_revs_rec.ORGANIZATION_CODE
		g_rtg_revs_tbl(i).Alternate_Routing_Code := l_alt_rtg_desig; --rtg_revs_rec.
		g_rtg_revs_tbl(i).Revision		:= rtg_revs_rec.PROCESS_REVISION;
		g_rtg_revs_tbl(i).Start_Effective_Date  := nvl(rtg_revs_rec.EFFECTIVITY_DATE, sysdate + 1/1440);
		g_rtg_revs_tbl(i).Attribute_category	:= rtg_revs_rec.ATTRIBUTE_CATEGORY;
		g_rtg_revs_tbl(i).Attribute1		:= rtg_revs_rec.ATTRIBUTE1;
		g_rtg_revs_tbl(i).Attribute2		:= rtg_revs_rec.ATTRIBUTE2;
		g_rtg_revs_tbl(i).Attribute3		:= rtg_revs_rec.ATTRIBUTE3;
		g_rtg_revs_tbl(i).Attribute4		:= rtg_revs_rec.ATTRIBUTE4;
		g_rtg_revs_tbl(i).Attribute5		:= rtg_revs_rec.ATTRIBUTE5;
		g_rtg_revs_tbl(i).Attribute6		:= rtg_revs_rec.ATTRIBUTE6;
		g_rtg_revs_tbl(i).Attribute7		:= rtg_revs_rec.ATTRIBUTE7;
		g_rtg_revs_tbl(i).Attribute8		:= rtg_revs_rec.ATTRIBUTE8;
		g_rtg_revs_tbl(i).Attribute9		:= rtg_revs_rec.ATTRIBUTE9;
		g_rtg_revs_tbl(i).Attribute10		:= rtg_revs_rec.ATTRIBUTE10;
		g_rtg_revs_tbl(i).Attribute11		:= rtg_revs_rec.ATTRIBUTE11;
		g_rtg_revs_tbl(i).Attribute12		:= rtg_revs_rec.ATTRIBUTE12;
		g_rtg_revs_tbl(i).Attribute13		:= rtg_revs_rec.ATTRIBUTE13;
		g_rtg_revs_tbl(i).Attribute14		:= rtg_revs_rec.ATTRIBUTE14;
		g_rtg_revs_tbl(i).Attribute15		:= rtg_revs_rec.ATTRIBUTE15;
		g_rtg_revs_tbl(i).Original_System_Reference := rtg_revs_rec.ORIGINAL_SYSTEM_REFERENCE;
		g_rtg_revs_tbl(i).Transaction_Type	:= rtg_revs_rec.TRANSACTION_TYPE;
		g_rtg_revs_tbl(i).Row_Identifier	:= rtg_revs_rec.TRANSACTION_ID;
		g_rtg_revs_tbl(i).Return_Status:='';

                END LOOP;
                CLOSE get_rtg_revs;
stmt_num:= 6;
		OPEN get_op_seqs (l_assembly_item_name, l_org_code, l_alt_rtg_desig);

                i := 0;
                LOOP
                FETCH get_op_seqs  into op_seqs_rec;
		EXIT WHEN get_op_seqs%NOTFOUND;

                i:=i+1;
                if (i=1) then empty_bo := 'N';
		end if;

		g_op_tbl(i).Assembly_Item_Name		:= l_assembly_item_name; --op_seqs_rec.ASSEMBLY_ITEM_NUMBER
		g_op_tbl(i).Organization_Code		:= l_org_code; --op_seqs_rec.ORGANIZATION_CODE
		g_op_tbl(i).Alternate_Routing_Code	:= l_alt_rtg_desig; --op_seqs_rec.ALTERNATE_ROUTING_DESIGNATOR
		g_op_tbl(i).Operation_Sequence_Number	:= op_seqs_rec.OPERATION_SEQ_NUM;
		g_op_tbl(i).Operation_Type		:= op_seqs_rec.OPERATION_TYPE;
		g_op_tbl(i).Start_Effective_Date	:= op_seqs_rec.EFFECTIVITY_DATE;
		g_op_tbl(i).New_Operation_Sequence_Number := op_seqs_rec.NEW_OPERATION_SEQ_NUM;
		g_op_tbl(i).New_Start_Effective_Date	:= op_seqs_rec.NEW_EFFECTIVITY_DATE;
		g_op_tbl(i).Standard_Operation_Code	:= op_seqs_rec.OPERATION_CODE;
		g_op_tbl(i).Department_Code		:= op_seqs_rec.DEPARTMENT_CODE;
		g_op_tbl(i).Op_Lead_Time_Percent	:= op_seqs_rec.OPERATION_LEAD_TIME_PERCENT;
		g_op_tbl(i).Minimum_Transfer_Quantity	:= op_seqs_rec.MINIMUM_TRANSFER_QUANTITY;
		g_op_tbl(i).Count_Point_Type		:= op_seqs_rec.COUNT_POINT_TYPE;
		g_op_tbl(i).Operation_Description	:= op_seqs_rec.OPERATION_DESCRIPTION;
		g_op_tbl(i).Disable_Date		:= op_seqs_rec.DISABLE_DATE;
		g_op_tbl(i).Backflush_Flag		:= op_seqs_rec.BACKFLUSH_FLAG;
		g_op_tbl(i).Option_Dependent_Flag	:= op_seqs_rec.OPTION_DEPENDENT_FLAG;
		g_op_tbl(i).Reference_Flag		:= op_seqs_rec.REFERENCE_FLAG;
		g_op_tbl(i).Process_Seq_Number		:= op_seqs_rec.PROCESS_SEQ_NUMBER; --newly added
		g_op_tbl(i).Process_Code		:= op_seqs_rec.PROCESS_CODE; --newly added
		g_op_tbl(i).Line_Op_Seq_Number		:= op_seqs_rec.LINE_OP_SEQ_NUMBER; --newly added
		g_op_tbl(i).Line_Op_Code		:= op_seqs_rec.LINE_OP_CODE; --newly added
		g_op_tbl(i).Yield			:= op_seqs_rec.YIELD;
		g_op_tbl(i).Cumulative_Yield		:= op_seqs_rec.CUMULATIVE_YIELD;
		g_op_tbl(i).Reverse_CUM_Yield		:= op_seqs_rec.REVERSE_CUMULATIVE_YIELD;
		g_op_tbl(i).User_Labor_Time		:= op_seqs_rec.LABOR_TIME_USER;
		g_op_tbl(i).User_Machine_Time		:= op_seqs_rec.MACHINE_TIME_USER;
		g_op_tbl(i).Net_Planning_Percent	:= op_seqs_rec.NET_PLANNING_PERCENT;
		g_op_tbl(i).Include_In_Rollup		:= op_seqs_rec.INCLUDE_IN_ROLLUP;
		g_op_tbl(i).Op_Yield_Enabled_Flag	:= op_seqs_rec.OPERATION_YIELD_ENABLED;
		g_op_tbl(i).Shutdown_Type		:= op_seqs_rec.SHUTDOWN_TYPE;  --newly added
		g_op_tbl(i).Attribute_category		:= op_seqs_rec.ATTRIBUTE_CATEGORY;
		g_op_tbl(i).Attribute1			:= op_seqs_rec.ATTRIBUTE1;
		g_op_tbl(i).Attribute2			:= op_seqs_rec.ATTRIBUTE2;
		g_op_tbl(i).Attribute3			:= op_seqs_rec.ATTRIBUTE3;
		g_op_tbl(i).Attribute4			:= op_seqs_rec.ATTRIBUTE4;
		g_op_tbl(i).Attribute5			:= op_seqs_rec.ATTRIBUTE5;
		g_op_tbl(i).Attribute6			:= op_seqs_rec.ATTRIBUTE6;
		g_op_tbl(i).Attribute7			:= op_seqs_rec.ATTRIBUTE7;
		g_op_tbl(i).Attribute8			:= op_seqs_rec.ATTRIBUTE8;
		g_op_tbl(i).Attribute9			:= op_seqs_rec.ATTRIBUTE9;
		g_op_tbl(i).Attribute10			:= op_seqs_rec.ATTRIBUTE10;
		g_op_tbl(i).Attribute11			:= op_seqs_rec.ATTRIBUTE11;
		g_op_tbl(i).Attribute12			:= op_seqs_rec.ATTRIBUTE12;
		g_op_tbl(i).Attribute13			:= op_seqs_rec.ATTRIBUTE13;
		g_op_tbl(i).Attribute14			:= op_seqs_rec.ATTRIBUTE14;
		g_op_tbl(i).Attribute15			:= op_seqs_rec.ATTRIBUTE15;
		g_op_tbl(i).Original_System_Reference	:= op_seqs_rec.ORIGINAL_SYSTEM_REFERENCE;  --newly added
		g_op_tbl(i).Transaction_Type		:= op_seqs_rec.TRANSACTION_TYPE;
		g_op_tbl(i).Delete_Group_Name		:= op_seqs_rec.DELETE_GROUP_NAME;  --newly added
		g_op_tbl(i).DG_Description		:= op_seqs_rec.DG_DESCRIPTION;  --newly added
		g_op_tbl(i).Long_Description		:= op_seqs_rec.LONG_DESCRIPTION;  --newly added
		g_op_tbl(i).Row_Identifier		:= op_seqs_rec.TRANSACTION_ID;  --newly added
                g_op_tbl(i).Return_Status:='';

                END LOOP;
                CLOSE get_op_seqs;
stmt_num:= 7;
        END IF; -- l_rtg_header_exists or l_op_exists or l_revs_exists

                OPEN get_op_resources (l_assembly_item_name, l_org_code, l_alt_rtg_desig);
                i := 0;
                LOOP
                FETCH get_op_resources into op_res_rec;
                EXIT WHEN get_op_resources%NOTFOUND;
                i:=i+1;

                if (i=1) then empty_bo := 'N';
		end if;

		g_op_res_tbl(i).Assembly_Item_Name	:= l_assembly_item_name; --op_res_rec.
		g_op_res_tbl(i).Organization_Code	:= l_org_code; --op_res_rec.
		g_op_res_tbl(i).Alternate_Routing_Code	:= l_alt_rtg_desig; --op_res_rec.
		g_op_res_tbl(i).Operation_Sequence_Number := op_res_rec.OPERATION_SEQ_NUM;
		g_op_res_tbl(i).Operation_Type		:= op_res_rec.OPERATION_TYPE;
		g_op_res_tbl(i).Op_Start_Effective_Date	:= op_res_rec.EFFECTIVITY_DATE;
		g_op_res_tbl(i).Resource_Sequence_Number := op_res_rec.RESOURCE_SEQ_NUM;
		g_op_res_tbl(i).Resource_Code		:= op_res_rec.RESOURCE_CODE;
		g_op_res_tbl(i).Activity		:= op_res_rec.ACTIVITY;
		g_op_res_tbl(i).Standard_Rate_Flag	:= op_res_rec.STANDARD_RATE_FLAG;
		g_op_res_tbl(i).Assigned_Units		:= op_res_rec.ASSIGNED_UNITS;
		g_op_res_tbl(i).Usage_Rate_Or_Amount	:= ROUND(op_res_rec.USAGE_RATE_OR_AMOUNT,6);
		g_op_res_tbl(i).Usage_Rate_Or_Amount_Inverse := ROUND(op_res_rec.USAGE_RATE_OR_AMOUNT_INVERSE,6);
		g_op_res_tbl(i).Basis_Type		:= op_res_rec.BASIS_TYPE;
		g_op_res_tbl(i).Schedule_Flag		:= op_res_rec.SCHEDULE_FLAG;
		g_op_res_tbl(i).Resource_Offset_Percent	:= op_res_rec.RESOURCE_OFFSET_PERCENT;
		g_op_res_tbl(i).Autocharge_Type		:= op_res_rec.AUTOCHARGE_TYPE;
		g_op_res_tbl(i).Schedule_Sequence_Number := op_res_rec.SCHEDULE_SEQ_NUM;
		g_op_res_tbl(i).Substitute_Group_Number := op_res_rec.SUBSTITUTE_GROUP_NUM;
		g_op_res_tbl(i).Principle_Flag		:= op_res_rec.PRINCIPLE_FLAG;
		g_op_res_tbl(i).Attribute_category	:= op_res_rec.ATTRIBUTE_CATEGORY;
		g_op_res_tbl(i).Attribute1		:= op_res_rec.ATTRIBUTE1;
		g_op_res_tbl(i).Attribute2		:= op_res_rec.ATTRIBUTE2;
		g_op_res_tbl(i).Attribute3		:= op_res_rec.ATTRIBUTE3;
		g_op_res_tbl(i).Attribute4 		:= op_res_rec.ATTRIBUTE4;
		g_op_res_tbl(i).Attribute5 		:= op_res_rec.ATTRIBUTE5;
		g_op_res_tbl(i).Attribute6 		:= op_res_rec.ATTRIBUTE6;
		g_op_res_tbl(i).Attribute7 		:= op_res_rec.ATTRIBUTE7;
		g_op_res_tbl(i).Attribute8 		:= op_res_rec.ATTRIBUTE8;
		g_op_res_tbl(i).Attribute9 		:= op_res_rec.ATTRIBUTE9;
		g_op_res_tbl(i).Attribute10 		:= op_res_rec.ATTRIBUTE10;
		g_op_res_tbl(i).Attribute11 		:= op_res_rec.ATTRIBUTE11;
		g_op_res_tbl(i).Attribute12		:= op_res_rec.ATTRIBUTE12;
		g_op_res_tbl(i).Attribute13 		:= op_res_rec.ATTRIBUTE13;
		g_op_res_tbl(i).Attribute14 		:= op_res_rec.ATTRIBUTE14;
		g_op_res_tbl(i).Attribute15 		:= op_res_rec.ATTRIBUTE15;
		g_op_res_tbl(i).Original_System_Reference := op_res_rec.ORIGINAL_SYSTEM_REFERENCE;
		g_op_res_tbl(i).Transaction_Type	:= op_res_rec.TRANSACTION_TYPE;
		g_op_res_tbl(i).Setup_Type		:= op_res_rec.SETUP_CODE;
		g_op_res_tbl(i).Row_Identifier		:= op_res_rec.TRANSACTION_ID;
		g_op_res_tbl(i).Return_Status := '';

                END LOOP;
                CLOSE get_op_resources;

stmt_num:= 8;

                OPEN get_sub_op_resources(l_assembly_item_name, l_org_code, l_alt_rtg_desig);
                i := 0;
                LOOP
                FETCH get_sub_op_resources into sub_op_res_rec;
                EXIT WHEN get_sub_op_resources%NOTFOUND;
                i:=i+1;
                if (i=1) then empty_bo := 'N';
		end if;

		g_sub_op_res_tbl(i).Assembly_Item_Name		:= l_assembly_item_name; --sub_op_res_rec.
		g_sub_op_res_tbl(i).Organization_Code		:= l_org_code; --sub_op_res_rec.
		g_sub_op_res_tbl(i).Alternate_Routing_Code	:= l_alt_rtg_desig; --sub_op_res_rec.
		g_sub_op_res_tbl(i).Operation_Sequence_Number	:= sub_op_res_rec.OPERATION_SEQ_NUM;
		g_sub_op_res_tbl(i).Operation_Type		:= sub_op_res_rec.OPERATION_TYPE;
		g_sub_op_res_tbl(i).Op_Start_Effective_Date	:= sub_op_res_rec.EFFECTIVITY_DATE;
		g_sub_op_res_tbl(i).Sub_Resource_Code		:= sub_op_res_rec.SUB_RESOURCE_CODE;
		g_sub_op_res_tbl(i).New_Sub_Resource_Code	:= sub_op_res_rec.NEW_SUB_RESOURCE_CODE;
		--g_sub_op_res_tbl(i).Schedule_Sequence_Number	:= nvl(sub_op_res_rec.SCHEDULE_SEQ_NUM, sub_op_res_rec.SUBSTITUTE_GROUP_NUM);

		g_sub_op_res_tbl(i).Schedule_Sequence_Number    := sub_op_res_rec.SCHEDULE_SEQ_NUM;
		g_sub_op_res_tbl(i).Substitute_Group_Number     := sub_op_res_rec.SUBSTITUTE_GROUP_NUM;
		g_sub_op_res_tbl(i).Replacement_Group_Number	:= sub_op_res_rec.REPLACEMENT_GROUP_NUM;
        g_sub_op_res_tbl(i).New_Replacement_Group_Number := sub_op_res_rec.NEW_REPLACEMENT_GROUP_NUM; -- bug 3741570
		g_sub_op_res_tbl(i).Activity			:= sub_op_res_rec.ACTIVITY;
		g_sub_op_res_tbl(i).Standard_Rate_Flag		:= sub_op_res_rec.STANDARD_RATE_FLAG;
		g_sub_op_res_tbl(i).Assigned_Units		:= sub_op_res_rec.ASSIGNED_UNITS;
		g_sub_op_res_tbl(i).Usage_Rate_Or_Amount	:= ROUND(sub_op_res_rec.USAGE_RATE_OR_AMOUNT,6);
		g_sub_op_res_tbl(i).Usage_Rate_Or_Amount_Inverse := ROUND(sub_op_res_rec.USAGE_RATE_OR_AMOUNT_INVERSE,6);
		g_sub_op_res_tbl(i).Basis_Type			:= sub_op_res_rec.BASIS_TYPE;
    g_sub_op_res_tbl(i).New_Basis_Type  := sub_op_res_rec.New_BASIS_TYPE; /*Added for bug 4689856 */
		g_sub_op_res_tbl(i).Schedule_Flag		:= sub_op_res_rec.SCHEDULE_FLAG;
    g_sub_op_res_tbl(i).New_Schedule_Flag                := sub_op_res_rec.NEW_SCHEDULE_FLAG; /* Added for bug 13005178 */
		g_sub_op_res_tbl(i).Resource_Offset_Percent	:= sub_op_res_rec.RESOURCE_OFFSET_PERCENT;
		g_sub_op_res_tbl(i).Autocharge_Type		:= sub_op_res_rec.AUTOCHARGE_TYPE;
		g_sub_op_res_tbl(i).Principle_Flag		:= sub_op_res_rec.PRINCIPLE_FLAG;
		g_sub_op_res_tbl(i).Attribute_category		:= sub_op_res_rec.ATTRIBUTE_CATEGORY;
		g_sub_op_res_tbl(i).Attribute1			:= sub_op_res_rec.ATTRIBUTE1;
		g_sub_op_res_tbl(i).Attribute2			:= sub_op_res_rec.ATTRIBUTE2;
		g_sub_op_res_tbl(i).Attribute3			:= sub_op_res_rec.ATTRIBUTE3;
		g_sub_op_res_tbl(i).Attribute4			:= sub_op_res_rec.ATTRIBUTE4;
		g_sub_op_res_tbl(i).Attribute5			:= sub_op_res_rec.ATTRIBUTE5;
		g_sub_op_res_tbl(i).Attribute6			:= sub_op_res_rec.ATTRIBUTE6;
		g_sub_op_res_tbl(i).Attribute7			:= sub_op_res_rec.ATTRIBUTE7;
		g_sub_op_res_tbl(i).Attribute8			:= sub_op_res_rec.ATTRIBUTE8;
		g_sub_op_res_tbl(i).Attribute9			:= sub_op_res_rec.ATTRIBUTE9;
		g_sub_op_res_tbl(i).Attribute10			:= sub_op_res_rec.ATTRIBUTE10;
		g_sub_op_res_tbl(i).Attribute11			:= sub_op_res_rec.ATTRIBUTE11;
		g_sub_op_res_tbl(i).Attribute12			:= sub_op_res_rec.ATTRIBUTE12;
		g_sub_op_res_tbl(i).Attribute13			:= sub_op_res_rec.ATTRIBUTE13;
		g_sub_op_res_tbl(i).Attribute14			:= sub_op_res_rec.ATTRIBUTE14;
		g_sub_op_res_tbl(i).Attribute15			:= sub_op_res_rec.ATTRIBUTE15;
		g_sub_op_res_tbl(i).Original_System_Reference	:= sub_op_res_rec.ORIGINAL_SYSTEM_REFERENCE;
		g_sub_op_res_tbl(i).Transaction_Type		:= sub_op_res_rec.TRANSACTION_TYPE;
		g_sub_op_res_tbl(i).Setup_Type			:= sub_op_res_rec.SETUP_CODE;
		g_sub_op_res_tbl(i).Row_Identifier		:= sub_op_res_rec.TRANSACTION_ID;
		g_sub_op_res_tbl(i).Return_Status := '';

                END LOOP;
                CLOSE get_sub_op_resources;

stmt_num:= 9;

                OPEN get_op_nwk(l_assembly_item_name, l_org_code, l_alt_rtg_desig);
                i := 0;
                LOOP
                FETCH get_op_nwk into op_nwk_rec;
                EXIT WHEN get_op_nwk%NOTFOUND;
                i:=i+1;
                if (i=1) then empty_bo := 'N';
		end if;

		g_nwk_tbl(i).Assembly_Item_Name		:= l_assembly_item_name;
		g_nwk_tbl(i).Organization_Code		:= l_org_code;
		g_nwk_tbl(i).Alternate_Routing_Code	:= l_alt_rtg_desig;
		g_nwk_tbl(i).Operation_Type		:= op_nwk_rec.OPERATION_TYPE;
		g_nwk_tbl(i).From_Op_Seq_Number		:= op_nwk_rec.FROM_OP_SEQ_NUMBER;
		g_nwk_tbl(i).From_X_Coordinate		:= op_nwk_rec.FROM_X_COORDINATE;
		g_nwk_tbl(i).From_Y_Coordinate		:= op_nwk_rec.FROM_Y_COORDINATE;
		g_nwk_tbl(i).From_Start_Effective_Date	:= op_nwk_rec.FROM_START_EFFECTIVE_DATE;
		g_nwk_tbl(i).To_Op_Seq_Number		:= op_nwk_rec.TO_OP_SEQ_NUMBER;
		g_nwk_tbl(i).To_X_Coordinate		:= op_nwk_rec.TO_X_COORDINATE;
		g_nwk_tbl(i).To_Y_Coordinate		:= op_nwk_rec.TO_Y_COORDINATE;
		g_nwk_tbl(i).To_Start_Effective_Date	:= op_nwk_rec.TO_START_EFFECTIVE_DATE;
		g_nwk_tbl(i).New_From_Op_Seq_Number	:= op_nwk_rec.NEW_FROM_OP_SEQ_NUMBER;
		g_nwk_tbl(i).New_From_Start_Effective_Date := op_nwk_rec.NEW_FROM_START_EFFECTIVE_DATE;
		g_nwk_tbl(i).New_To_Op_Seq_Number	:= op_nwk_rec.NEW_TO_OP_SEQ_NUMBER;
		g_nwk_tbl(i).New_To_Start_Effective_Date := op_nwk_rec.NEW_TO_START_EFFECTIVE_DATE;
		g_nwk_tbl(i).Connection_Type		:= op_nwk_rec.TRANSITION_TYPE;
		g_nwk_tbl(i).Planning_Percent		:= op_nwk_rec.PLANNING_PCT;
		g_nwk_tbl(i).Attribute_category		:= op_nwk_rec.ATTRIBUTE_CATEGORY;
		g_nwk_tbl(i).Attribute1			:= op_nwk_rec.ATTRIBUTE1;
		g_nwk_tbl(i).Attribute2			:= op_nwk_rec.ATTRIBUTE2;
		g_nwk_tbl(i).Attribute3			:= op_nwk_rec.ATTRIBUTE3;
		g_nwk_tbl(i).Attribute4			:= op_nwk_rec.ATTRIBUTE4;
		g_nwk_tbl(i).Attribute5			:= op_nwk_rec.ATTRIBUTE5;
		g_nwk_tbl(i).Attribute6			:= op_nwk_rec.ATTRIBUTE6;
		g_nwk_tbl(i).Attribute7			:= op_nwk_rec.ATTRIBUTE7;
		g_nwk_tbl(i).Attribute8			:= op_nwk_rec.ATTRIBUTE8;
		g_nwk_tbl(i).Attribute9			:= op_nwk_rec.ATTRIBUTE9;
		g_nwk_tbl(i).Attribute10		:= op_nwk_rec.ATTRIBUTE10;
		g_nwk_tbl(i).Attribute11		:= op_nwk_rec.ATTRIBUTE11;
		g_nwk_tbl(i).Attribute12		:= op_nwk_rec.ATTRIBUTE12;
		g_nwk_tbl(i).Attribute13		:= op_nwk_rec.ATTRIBUTE13;
		g_nwk_tbl(i).Attribute14		:= op_nwk_rec.ATTRIBUTE14;
		g_nwk_tbl(i).Attribute15		:= op_nwk_rec.ATTRIBUTE15;
		g_nwk_tbl(i).Original_System_Reference	:= op_nwk_rec.ORIGINAL_SYSTEM_REFERENCE;
		g_nwk_tbl(i).Transaction_Type		:= op_nwk_rec.TRANSACTION_TYPE;
		g_nwk_tbl(i).Row_Identifier		:= op_nwk_rec.TRANSACTION_ID;
		g_nwk_tbl(i).Return_Status := '';

                END LOOP;
                CLOSE get_op_nwk;

stmt_num:=10;

    SAVEPOINT osfm_rtg_check ;  --for osfm routings bug#3134027

      if (empty_bo ='N') then  -- Calling the RBO public API
	bom_rtg_pub.process_rtg
        ( p_bo_identifier	=> 'RTG'
        , p_api_version_number	=> 1.0
        , p_init_msg_list	=> TRUE
        , p_rtg_header_rec	=> g_rtg_header_rec
        , p_rtg_revision_tbl	=> g_rtg_revs_tbl
        , p_operation_tbl	=> g_op_tbl
        , p_op_resource_tbl	=> g_op_res_tbl
        , p_sub_resource_tbl	=> g_sub_op_res_tbl
        , p_op_network_tbl	=> g_nwk_tbl
        , x_rtg_header_rec	=> g_rtg_header_rec
        , x_rtg_revision_tbl	=> g_rtg_revs_tbl
        , x_operation_tbl	=> g_op_tbl
        , x_op_resource_tbl	=> g_op_res_tbl
        , x_sub_resource_tbl	=> g_sub_op_res_tbl
        , x_op_network_tbl	=> g_nwk_tbl
        , x_return_status	=> ret_status
        , x_msg_count		=> l_msg_count
        , p_debug		=> debug_on
        , p_output_dir		=> 'none'
        , p_debug_filename	=> 'none'
        );

      end if;
  --for osfm routings bug#3134027

   IF ret_status = 'E' AND BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_LOT_RTG
  THEN
  ROLLBACK TO osfm_rtg_check ;
  ELSE
/*Even if the BO has returned Error, some of the rows might be successfull.
All the sucessful rows will be commited since bo will not update errored rows*/
   COMMIT;
   END IF;
stmt_num:= 11;
          -- Error_handling for the openInterface
          Error_handler.Write_To_ConcurrentLog;
          Error_handler.Write_To_InterfaceTable;

stmt_num := 12;
            l_return_status := Update_Rtg_Interface_tables (x_err_text);
               IF (l_return_status NOT IN (0,1) ) THEN
                  RETURN(l_return_status);
               ELSIF ( l_return_status = 1 ) THEN
                 l_func_ret_status := 1;
               END IF;

         COMMIT;
        END IF; -- L_ASSEMBLY_ITEM_NUMBER AND L_ORG_CODE NOT NULL.
      END LOOP;

      -- Unset the Global Variable to Routing Open Interface type
	Error_Handler.unset_bom_oi;

stmt_num := 13;
         if(p_delete_rows = 1) then
            l_return_status := Delete_Rtg_OI(x_err_text, p_batch_id);
               IF (l_return_status <> 0) THEN
                  RETURN(l_return_status);
               END IF;
	end if;

stmt_num := 14;
-- check if the main cursor is open and then close it
	If (get_rtg_header%ISOPEN) then
         close get_rtg_header;
        end if;

--return (0);
    return (l_func_ret_status);

EXCEPTION
   WHEN OTHERS THEN
      x_err_text := 'IMPORT_RTG :'||stmt_num||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
End IMPORT_RTG;


Function Update_Rtg_Interface_tables (x_err_text   IN OUT NOCOPY  VARCHAR2)
return Integer
Is
  l_process_flag Number;
  stmt_num  Number;
  l_ret_status NUMBER;
begin
  --bug:5235742 When import completes with one or more entities having errors, return 1.
  l_ret_status := 0;
  stmt_num := 0;
   if g_rtg_header_rec.Return_Status IS NULL then
       l_process_flag := 1;
   elsif (g_rtg_header_rec.Return_Status = 'S') then
       l_process_flag := 7;
   else
       l_process_flag := 3;
       l_ret_status   := 1;
   end if;

      Update BOM_OP_ROUTINGS_INTERFACE
      set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
      where  transaction_id = g_rtg_header_rec.Row_Identifier;

stmt_num := 1;
     FOR I IN 1..g_rtg_revs_tbl.COUNT LOOP

      g_rtg_revision_rec := g_rtg_revs_tbl(I);

      if g_rtg_revision_rec.Return_Status IS NULL then
         l_process_flag := 1;
      elsif (g_rtg_revision_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status   := 1;
      end if;

       Update MTL_RTG_ITEM_REVS_INTERFACE
       set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
       where  transaction_id = g_rtg_revision_rec.row_identifier;
     END LOOP;

stmt_num := 2;
     FOR I IN 1..g_op_tbl.COUNT LOOP

      g_op_rec := g_op_tbl(I);

	if g_op_rec.Return_Status IS NULL then
         l_process_flag := 1;
      elsif (g_op_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status   := 1;
      end if;

      Update BOM_OP_SEQUENCES_INTERFACE
      set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
      where  transaction_id = g_op_rec.row_identifier;
     END LOOP;

stmt_num := 3;
     FOR I IN 1..g_op_res_tbl.COUNT LOOP

	 g_op_res_rec := g_op_res_tbl(I);

     if g_op_res_rec.Return_Status IS NULL then
          l_process_flag := 1;
      elsif (g_op_res_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status   := 1;
      end if;

       Update BOM_OP_RESOURCES_INTERFACE
       set   process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
       where  transaction_id = g_op_res_rec.row_identifier;
     END LOOP;

stmt_num := 4;
     FOR I IN 1..g_sub_op_res_tbl.COUNT LOOP
     g_sub_op_res_rec := g_sub_op_res_tbl(I);

     if g_sub_op_res_rec.Return_Status IS NULL then
          l_process_flag := 1;
      elsif (g_sub_op_res_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status   := 1;
      end if;

     Update BOM_SUB_OP_RESOURCES_INTERFACE
     set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
     where  transaction_id = g_sub_op_res_rec.row_identifier;
     END LOOP;

stmt_num := 5;
     FOR I IN 1..g_nwk_tbl.COUNT LOOP
     g_nwk_rec := g_nwk_tbl(I);

    if g_nwk_rec.Return_Status IS NULL then
	l_process_flag := 1;
      elsif (g_nwk_rec.Return_Status = 'S') then
        l_process_flag := 7;
      else
        l_process_flag := 3;
        l_ret_status   := 1;
      end if;

     Update BOM_OP_NETWORKS_INTERFACE
     set    process_flag = l_process_flag,
            REQUEST_ID =  Fnd_Global.Conc_Request_Id,
            PROGRAM_ID = Fnd_Global.Conc_program_Id,
            PROGRAM_APPLICATION_ID = Fnd_Global.prog_appl_id,
           PROGRAM_UPDATE_DATE = sysdate
     where  transaction_id = g_nwk_rec.row_identifier;
     END LOOP;

return (l_ret_status);

EXCEPTION
   WHEN OTHERS THEN
      x_err_text := 'Update_Rtg_Interface_Tables'||stmt_num||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);

end Update_Rtg_Interface_tables;

FUNCTION Delete_Rtg_OI (
        x_err_text    IN OUT NOCOPY VARCHAR2
	, p_batch_id  IN  NUMBER
)
    return INTEGER
IS
    stmt_num    NUMBER;
BEGIN
stmt_num := 1;
loop
DELETE FROM BOM_OP_ROUTINGS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
    OR ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 2;
loop
DELETE FROM BOM_OP_SEQUENCES_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
    OR ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 3;
loop
DELETE FROM BOM_OP_RESOURCES_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
    OR ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 4;
loop
DELETE FROM BOM_SUB_OP_RESOURCES_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
    OR ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 5;
loop
DELETE FROM BOM_OP_NETWORKS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
    OR ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

stmt_num := 6;
loop
DELETE FROM MTL_RTG_ITEM_REVS_INTERFACE
WHERE PROCESS_FLAG = 7
AND
(
    ( (p_batch_id IS NULL) AND (BATCH_ID IS NULL) )
    OR ( p_batch_id = BATCH_ID )
)
AND rownum < 500;
exit when SQL%NOTFOUND ;
commit;
end loop;

return(0);

EXCEPTION
    when OTHERS THEN
        x_err_text := 'DELETE_RTG_OI(' || stmt_num || ')' || substrb(SQLERRM,1,240);
        return(SQLCODE);
END Delete_Rtg_OI;

END BOM_RTG_OPEN_INTERFACE;

/
