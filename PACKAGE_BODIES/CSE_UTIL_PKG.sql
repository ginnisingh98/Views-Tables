--------------------------------------------------------
--  DDL for Package Body CSE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_UTIL_PKG" as
-- $Header: CSEUTILB.pls 120.11 2006/05/31 07:30:59 brmanesh ship $

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');


l_Sysdate   DATE    := SYSDATE;
PROCEDURE Check_item_Trackable(
     p_inventory_item_id IN NUMBER,
     p_nl_trackable_flag OUT NOCOPY VARCHAR2
   )
IS
      -- Enter the procedure variables here. As shown below
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     yes_or_no VARCHAR2(2) := 'N';
     l_err_text          VARCHAR2(2000);
CURSOR NL_TRACK_CUR(P_Item_Id IN NUMBER) IS
       SELECT   DISTINCT 'Y'
       FROM     mtl_system_items
       WHERE    inventory_item_id = p_item_id
       AND      organization_id =
                (select organization_id
                 from   mtl_system_items
                 where inventory_item_id=P_inventory_item_id
                 and  rownum =1)
       AND      enabled_flag = 'Y'
       AND      nvl (start_date_active, l_sysdate) <= l_sysdate
       AND      nvl (end_date_active, l_sysdate+1) > l_sysdate
       AND      comms_nl_trackable_flag = 'Y';
BEGIN
        OPEN NL_Track_Cur(P_Inventory_Item_Id);
        FETCH  NL_Track_Cur INTO Yes_Or_No;
        CLOSE NL_Track_Cur;
        IF (yes_or_no = 'Y') THEN
                p_nl_trackable_flag := 'TRUE';
        ELSE
                p_nl_trackable_flag := 'FALSE';
        END IF;
EXCEPTION
  	WHEN OTHERS THEN
    		fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    		fnd_message.set_token('ERR_MSG', sqlerrm);
    		l_err_text := fnd_message.get;
--    		CSE_DEBUG_PUB.ADD('API CSE_UTIL_PKG.check_nl_trackable other exception: ' || l_err_text);
END check_item_trackable;

PROCEDURE check_lot_control(
     p_inventory_item_id IN NUMBER,
     p_organization_id IN NUMBER,
     p_lot_control OUT NOCOPY VARCHAR2
   )
IS
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     yes_or_no VARCHAR2(2) := 'N';
     l_err_text          VARCHAR2(2000);
CURSOR Lot_Cur (P_Item_ID IN NUMBER,
                P_Org_ID  IN NUMBER) IS
       SELECT   DISTINCT 'Y'
         FROM   mtl_system_items
        WHERE   inventory_item_id = P_item_id
          AND   organization_id = P_org_id
          AND   enabled_flag = 'Y'
          AND   nvl (start_date_active, l_sysdate) <= l_sysdate
          AND   nvl (end_date_active, l_sysdate+1) > l_sysdate
	      AND   lot_control_code <> 1;
BEGIN
        OPEN Lot_Cur(P_Inventory_Item_Id, P_Organization_ID);
        FETCH Lot_Cur INTO Yes_Or_No;
        CLOSE Lot_Cur;
        IF (yes_or_no = 'Y') THEN
                p_lot_control := 'TRUE';
        ELSIF (yes_or_no = 'N') THEN
                p_lot_control := 'FALSE';
        END IF;
EXCEPTION
        WHEN OTHERS THEN
    		fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    		fnd_message.set_token('ERR_MSG', sqlerrm);
    		l_err_text := fnd_message.get;
    		raise;
END check_lot_control;

PROCEDURE check_serial_control(
     p_inventory_item_id IN NUMBER,
     p_organization_id IN NUMBER,
     p_serial_control OUT NOCOPY VARCHAR2
   )
IS
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     yes_or_no VARCHAR2(2) := 'N';
     l_err_text          VARCHAR2(2000);
CURSOR Serial_CUR(P_Item_Id IN NUMBER,
                  P_Org_Id  IN NUMBER) IS
       SELECT   DISTINCT 'Y'
         FROM   mtl_system_items
        WHERE   inventory_item_id = p_item_id
          AND   organization_id = p_org_id
          AND   enabled_flag = 'Y'
          AND   nvl (start_date_active, l_sysdate) <= l_sysdate
          AND   nvl (end_date_active, l_sysdate+1) > l_sysdate
          AND   serial_number_control_code <> 1;
BEGIN
        OPEN  Serial_Cur(P_Inventory_Item_Id, P_Organization_ID);
        FETCH Serial_Cur INTO Yes_Or_No;
        CLOSE Serial_Cur;
        IF (yes_or_no = 'Y') THEN
                p_serial_control := 'TRUE';
        ELSIF (yes_or_no = 'N') THEN
                p_serial_control := 'FALSE';
        END IF;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
                p_serial_control := 'FALSE';
  	WHEN OTHERS THEN
    		fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    		fnd_message.set_token('ERR_MSG', sqlerrm);
    		l_err_text := fnd_message.get;
    		IF (l_debug = 'Y') THEN
       		cse_debug_pub.add('API CSE_UTIL_PKG.check_serial_control other exception: ' || l_err_text);
    		END IF;
    		raise;
END check_serial_control;

PROCEDURE check_depreciable_subinv(
     p_subinventory IN VARCHAR2,
     p_organization_id IN NUMBER,
     p_depreciable OUT NOCOPY VARCHAR2
   )
IS
      -- Enter the procedure variables here. As shown below
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     yes_or_no VARCHAR2(2) := 'N';
     l_err_text          VARCHAR2(2000);
CURSOR SubInv_Cur(P_Subinv IN VARCHAR2,
                  P_Org_Id IN NUMBER) IS
       SELECT   DISTINCT 'Y'
         FROM   mtl_secondary_inventories
	    WHERE   secondary_inventory_name = p_subinv
          AND   organization_id = p_org_id
          AND   disable_date IS NULL
          AND   depreciable_flag = 1;
BEGIN
        OPEN  SubInv_Cur(P_SubInventory, P_Organization_ID);
        FETCH SubInv_Cur INTO Yes_Or_No;
        CLOSE SubInv_Cur;
        IF (yes_or_no = 'Y') THEN
                p_depreciable := 'TRUE';
        ELSE
                p_depreciable := 'FALSE';
        END IF;
EXCEPTION
        WHEN OTHERS THEN
    		fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    		fnd_message.set_token('ERR_MSG', sqlerrm);
    		l_err_text := fnd_message.get;
                raise;
END check_depreciable_subinv;

PROCEDURE get_asset_creation_code(
     p_inventory_item_id IN NUMBER,
     p_asset_creation_code OUT NOCOPY VARCHAR2
   )
IS
      -- Enter the procedure variables here. As shown below
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     l_err_text          VARCHAR2(2000);
CURSOR Asset_CC_Cur (P_Item_Id IN NUMBER) IS
       SELECT   DISTINCT asset_creation_code
         FROM   mtl_system_items
        WHERE   inventory_item_id = p_inventory_item_id
          AND   organization_id =
                (select organization_id
                from   mtl_system_items
                where  inventory_item_id=p_inventory_item_id
                and rownum=1)
          AND   enabled_flag = 'Y'
          AND   nvl (start_date_active, l_sysdate) <= l_sysdate
          AND   nvl (end_date_active, l_sysdate+1) > l_sysdate;
BEGIN
 P_Asset_Creation_Code := NULL;
 OPEN Asset_CC_Cur(P_inventory_item_id);
 FETCH Asset_CC_Cur INTO P_Asset_Creation_Code;
  IF NOT Asset_CC_Cur%FOUND THEN
      P_Asset_Creation_Code := NULL;
  END IF;
 CLOSE Asset_CC_Cur;
EXCEPTION
  	WHEN OTHERS THEN
    		fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    		fnd_message.set_token('ERR_MSG', sqlerrm);
    		l_err_text := fnd_message.get;
                raise;
END get_asset_creation_code;

PROCEDURE check_depreciable(
     p_inventory_item_id IN NUMBER,
     p_depreciable OUT NOCOPY VARCHAR2
   )
IS
      -- Enter the procedure variables here. As shown below
      -- variable_name        datatype  NOT NULL DEFAULT default_value ;
     l_asset_creation_code VARCHAR2(1);
     l_err_text          VARCHAR2(2000);
BEGIN
	CSE_UTIL_PKG.Get_Asset_Creation_Code(
		p_inventory_item_id,
		l_asset_creation_code);
	IF l_asset_creation_code NOT IN ('1','Y') OR
		l_asset_creation_code IS NULL
 	THEN
		p_depreciable := 'N';
	ELSE
		p_depreciable := 'Y';
	END IF;
EXCEPTION
  	WHEN OTHERS THEN
    		fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    		fnd_message.set_token('ERR_MSG', sqlerrm);
    		l_err_text := fnd_message.get;
    		raise;
END check_depreciable;

PROCEDURE get_combine_segments(
		p_short_name		IN  VARCHAR2,
		p_flex_code		IN  VARCHAR2,
		p_concat_segments	IN  VARCHAR2,
		x_combine_segments OUT NOCOPY VARCHAR2,
	    x_Return_Status     OUT NOCOPY  VARCHAR2,
        x_Error_Message     OUT NOCOPY  VARCHAR2)

IS
struct_num       NUMBER := 101;
l_err_text          VARCHAR2(2000);
delimiter        VARCHAR2(1);
segs             FND_FLEX_EXT.SegmentArray;
nsegs            NUMBER;
concat_segments  varchar2(150);
temp_segs	 varchar2(150);
DLT_NOT_FOUND    EXCEPTION;
BEGIN

 X_Return_Status  := FND_API.G_RET_STS_SUCCESS;
 X_Error_Message  := Null;

  delimiter := fnd_flex_ext.get_delimiter(p_short_name, p_flex_code, struct_num);
  if delimiter is null then
    	raise DLT_NOT_FOUND;
  end if;
  nsegs :=  fnd_flex_ext.breakup_segments(p_concat_segments, delimiter, segs);
  for i in 1..nsegs
  loop
	temp_segs := RTRIM(LTRIM(temp_segs)) || segs(i);
  end loop;
  x_combine_segments := temp_segs;
EXCEPTION
  WHEN DLT_NOT_FOUND THEN

    fnd_message.set_name('CSE', 'CSE_DELIMITER_NOT_FOUND');
    l_err_text := fnd_message.get;
    IF (l_debug = 'Y') THEN
       cse_debug_pub.add('API CSE_UTIL_PKG.get_combine_segments Exception: ' || l_err_text);
    END IF;
    x_Error_Message  := l_err_text;
    x_Return_Status  := FND_API.G_RET_STS_ERROR;
  --  return;
  WHEN OTHERS THEN
    fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    fnd_message.set_token('ERR_MSG', sqlerrm);
    l_err_text := fnd_message.get;
    IF (l_debug = 'Y') THEN
       cse_debug_pub.add('API CSE_UTIL_PKG.get_combine_segments other exception: ' || l_err_text);
    END IF;
    x_Error_Message :=l_err_text;
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_combine_segments;

PROCEDURE get_concat_segments(
           p_short_name            IN  VARCHAR2,
           p_flex_code             IN  VARCHAR2,
	   p_combination_id	       IN  NUMBER,
           x_concat_segments       OUT NOCOPY  VARCHAR2,
           x_Return_Status         OUT NOCOPY  VARCHAR2,
           x_Error_Message         OUT NOCOPY  VARCHAR2)

IS
struct_num       NUMBER := 101;
l_err_text          VARCHAR2(2000);
delimiter        VARCHAR2(1);
segs             FND_FLEX_EXT.SegmentArray;
nsegs            NUMBER;
concat_segments  varchar2(150);
temp_segs        varchar2(150);
tf		 boolean DEFAULT TRUE;
DLT_NOT_FOUND    EXCEPTION;
SEGS_NOT_FOUND    EXCEPTION;
BEGIN
 X_Return_Status  := FND_API.G_RET_STS_SUCCESS;
 X_Error_Message  := Null;

  delimiter := fnd_flex_ext.get_delimiter(p_short_name, p_flex_code, struct_num);
  if delimiter is null then
        raise DLT_NOT_FOUND;
  end if;
  tf := fnd_flex_ext.get_segments(p_short_name, p_flex_code, struct_num, p_combination_id, nsegs, segs);

  if NOT tf then
    raise SEGS_NOT_FOUND;
  end if;

  x_concat_segments := fnd_flex_ext.concatenate_segments(nsegs, segs, delimiter);
EXCEPTION
  WHEN SEGS_NOT_FOUND THEN
    fnd_message.set_name('CSE', 'CSE_FLEX_SEGMENTS_NOT_FOUND');
    fnd_message.set_token('COMBINATION_ID',P_Combination_Id);
    l_err_text := fnd_message.get;
    IF (l_debug = 'Y') THEN
       cse_debug_pub.add('API CSE_UTIL_PKG.get_combine_segments Exception: ' || l_err_text);
    END IF;
    x_Return_Status  := FND_API.G_RET_STS_ERROR;
    X_Error_Message  :=l_err_text;
  WHEN DLT_NOT_FOUND THEN
    fnd_message.set_name('CSE', 'CSE_DELIMITER_NOT_FOUND');
    l_err_text := fnd_message.get;
    IF (l_debug = 'Y') THEN
       cse_debug_pub.add('API CSE_UTIL_PKG.get_combine_segments Exception: ' || l_err_text);
    END IF;
    x_Return_Status  := FND_API.G_RET_STS_ERROR;
    X_Error_Message  :=l_err_text;
  WHEN OTHERS THEN
    fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    fnd_message.set_token('ERR_MSG', sqlerrm);
    l_err_text := fnd_message.get;
    IF (l_debug = 'Y') THEN
       cse_debug_pub.add('API CSE_UTIL_PKG.get_combine_segments other exception: ' || l_err_text);
    END IF;
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    X_Error_Message  :=l_err_text;
END get_concat_segments;

FUNCTION is_eib_installed RETURN VARCHAR2
IS
l_eib_installed    VARCHAR2(1) := 'N' ;
dummy  VARCHAR2(40);
ret    BOOLEAN;
BEGIN
        IF (CSE_UTIL_PKG.x_cse_install is NULL)
        THEN
         ret := fnd_installation.get_app_info('CSE',
                  CSE_UTIL_PKG.x_cse_install, dummy, dummy);
        END IF;

        IF (CSE_UTIL_PKG.x_cse_install = 'I')
        THEN
         l_eib_installed := 'Y';
        ELSE
         l_eib_installed := 'N';
        END IF;
  RETURN l_eib_installed ;
END is_eib_installed ;


FUNCTION bypass_event_queue RETURN boolean
IS
 ret    BOOLEAN;
 l_flag VARCHAR2(1);

BEGIN
  IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL
  THEN
    csi_gen_utility_pvt.populate_install_param_rec;
  END IF;
   l_flag := NVL(csi_datastructures_pub.g_install_param_rec.sfm_queue_bypass_flag,'N');

  IF l_flag = 'Y'
  THEN
   ret := TRUE;
  ELSE
   ret:= FALSE;
  END IF;

 RETURN ret;
END bypass_event_queue;


FUNCTION get_neg_inv_code (p_org_id in NUMBER) RETURN NUMBER IS

l_neg_code    NUMBER := 0;

cursor c_code (pc_org_id in NUMBER) is
  SELECT negative_inv_receipt_Code
  FROM   mtl_parameters
  WHERE  organization_id = pc_org_id;

r_code     c_code%rowtype;

BEGIN
  OPEN c_code (p_org_id);
  FETCH c_code into r_code;
  IF c_code%found THEN
    l_neg_code := r_code.negative_inv_receipt_code;
  END IF;
  CLOSE c_code;
  RETURN l_neg_code ;
END get_neg_inv_code;

PROCEDURE get_destination_instance(
   P_Dest_Instance_tbl  IN   csi_datastructures_pub.instance_header_tbl,
   X_Instance_Rec OUT NOCOPY  csi_datastructures_pub.Instance_Rec,
   X_Return_Status      OUT NOCOPY  VARCHAR2,
   X_Error_Message      OUT NOCOPY  VARCHAR2) IS

   l_Api_Name CONSTANT       VARCHAR2(50) :='CSE_UTIL_PKG.GET_DESTINATION_INSTANCE';
   l_Active_Rec_Count        NUMBER:=0;
   l_Zero_Exp_Rec_Count      NUMBER:=0;
   l_Point_Active_Rec        VARCHAR2(1) DEFAULT  FND_API.G_FALSE;
   l_Point_Zero_Exp_Rec      VARCHAR2(1) DEFAULT  FND_API.G_FALSE;
   l_Dest_Instance_Found     VARCHAR2(1) DEFAULT  FND_API.G_FALSE;
   i                         PLS_INTEGER;
   Multiple_Active_Exp       EXCEPTION;
   a                         NUMBER := 0;
   l_instance_status_id      NUMBER;
   CURSOR inst_status_cur IS
     SELECT instance_status_id
     FROM csi_instance_statuses
     WHERE upper(name) ='CREATED';
   e_Nothing EXCEPTION;
BEGIN
 X_Return_Status         := FND_API.G_RET_STS_SUCCESS;
 X_Error_Message         := Null;
 X_Instance_Rec          := Null;
 --count active instances and expired instances with zero quantity
 IF P_Dest_Instance_Tbl.COUNT = 0
 THEN
 RAISE e_Nothing;
 END IF;
 FOR inst_status_cur_rec IN inst_status_cur
 LOOP
  l_instance_status_id := inst_status_cur_rec.instance_status_id;
 END LOOP;

  FOR  i IN P_Dest_Instance_Tbl.FIRST ..P_Dest_Instance_Tbl.LAST
   LOOP
    IF (P_Dest_Instance_Tbl(i).Active_End_Date IS  NULL )  THEN
      l_Active_Rec_Count:= (l_Active_Rec_Count +1);
    ELSIF((P_Dest_Instance_Tbl(i).Active_End_Date IS NOT NULL ) AND
         ( P_Dest_Instance_Tbl(i).Quantity = 0)) THEN
      l_Zero_Exp_Rec_Count:= (l_Zero_Exp_Rec_Count +1);
    END IF;
   END LOOP;

  --Raise exception if there exist multiple active destination instances

  IF(l_Active_Rec_Count>1)  THEN
    RAISE Multiple_Active_Exp;

  --Check if there exist active destination instance or expired dest instance
  --with zero quantity

    ELSIF(l_Active_Rec_Count=1)   THEN
     l_Point_Active_Rec      :=FND_API.G_TRUE;
     l_Dest_Instance_Found   :=FND_API.G_TRUE;

    ELSIF(l_Active_Rec_Count=0 AND l_Zero_Exp_Rec_Count>0)  THEN
     l_Point_Zero_Exp_Rec    :=FND_API.G_TRUE;
     l_Dest_Instance_Found   :=FND_API.G_TRUE;

    ELSIF(l_Active_Rec_Count=0 AND l_Zero_Exp_Rec_Count=0) THEN
     l_Dest_Instance_Found   :=FND_API.G_FALSE;

    END IF;

 -- get the record pointer

   FOR  i IN P_Dest_Instance_Tbl.FIRST ..P_Dest_Instance_Tbl.LAST
    LOOP
     IF ((l_Point_Active_Rec=FND_API.G_TRUE) AND
        (P_Dest_Instance_Tbl(i).Active_End_Date IS NULL)) THEN
         a := i;
      EXIT;
     ELSIF((l_Point_Zero_Exp_Rec=FND_API.G_TRUE) AND
          (P_Dest_Instance_Tbl(i).Active_End_Date IS NOT NULL  AND
           P_Dest_Instance_Tbl(i).Quantity = 0)) THEN
           a := i;
      EXIT;
    END IF;
   END LOOP;

 IF (l_Dest_Instance_Found =FND_API.G_TRUE) THEN

    X_Instance_Rec.INSTANCE_ID               := P_Dest_Instance_Tbl(a).INSTANCE_ID;
    X_Instance_Rec.INSTANCE_NUMBER           := P_Dest_Instance_Tbl(a).INSTANCE_NUMBER;
    X_Instance_Rec.EXTERNAL_REFERENCE        := P_Dest_Instance_Tbl(a).EXTERNAL_REFERENCE;
    X_Instance_Rec.INVENTORY_ITEM_ID         := P_Dest_Instance_Tbl(a).INVENTORY_ITEM_ID;
    X_Instance_Rec.INVENTORY_REVISION        := P_Dest_Instance_Tbl(a).INVENTORY_REVISION;
    X_Instance_Rec.INV_MASTER_ORGANIZATION_ID:= P_Dest_Instance_Tbl(a).INV_MASTER_ORGANIZATION_ID;
    X_Instance_Rec.SERIAL_NUMBER             := P_Dest_Instance_Tbl(a).SERIAL_NUMBER;
    X_Instance_Rec.MFG_SERIAL_NUMBER_FLAG    := P_Dest_Instance_Tbl(a).MFG_SERIAL_NUMBER_FLAG;
    X_Instance_Rec.LOT_NUMBER                := P_Dest_Instance_Tbl(a).LOT_NUMBER;
    X_Instance_Rec.QUANTITY                  := P_Dest_Instance_Tbl(a).QUANTITY;
    X_Instance_Rec.UNIT_OF_MEASURE           := P_Dest_Instance_Tbl(a).UNIT_OF_MEASURE;
    X_Instance_Rec.ACCOUNTING_CLASS_CODE     := P_Dest_Instance_Tbl(a).ACCOUNTING_CLASS_CODE;
    X_Instance_Rec.INSTANCE_CONDITION_ID     := P_Dest_Instance_Tbl(a).INSTANCE_CONDITION_ID;
    X_Instance_Rec.INSTANCE_USAGE_CODE       := P_Dest_Instance_Tbl(a).INSTANCE_USAGE_CODE;
    X_Instance_Rec.INSTANCE_STATUS_ID        := P_Dest_Instance_Tbl(a).INSTANCE_STATUS_ID;
    X_Instance_Rec.CUSTOMER_VIEW_FLAG        := P_Dest_Instance_Tbl(a).CUSTOMER_VIEW_FLAG ;
    X_Instance_Rec.MERCHANT_VIEW_FLAG        := P_Dest_Instance_Tbl(a).MERCHANT_VIEW_FLAG ;
    X_Instance_Rec.SELLABLE_FLAG             := P_Dest_Instance_Tbl(a).SELLABLE_FLAG;
    X_Instance_Rec.SYSTEM_ID                 := P_Dest_Instance_Tbl(a).SYSTEM_ID;
    X_Instance_Rec.INSTANCE_TYPE_CODE        := P_Dest_Instance_Tbl(a).INSTANCE_TYPE_CODE;
    X_Instance_Rec.ACTIVE_START_DATE         := P_Dest_Instance_Tbl(a).ACTIVE_START_DATE;
    X_Instance_Rec.ACTIVE_END_DATE           := Null;
    X_Instance_Rec.LOCATION_TYPE_CODE        := P_Dest_Instance_Tbl(a).LOCATION_TYPE_CODE;
    X_Instance_Rec.LOCATION_ID               := P_Dest_Instance_Tbl(a).LOCATION_ID;
    X_Instance_Rec.INV_ORGANIZATION_ID       := P_Dest_Instance_Tbl(a).INV_ORGANIZATION_ID;
    X_Instance_Rec.INV_SUBINVENTORY_NAME     := P_Dest_Instance_Tbl(a).INV_SUBINVENTORY_NAME;
    X_Instance_Rec.INV_LOCATOR_ID            := P_Dest_Instance_Tbl(a).INV_LOCATOR_ID;
    X_Instance_Rec.PA_PROJECT_ID             := P_Dest_Instance_Tbl(a).PA_PROJECT_ID;
    X_Instance_Rec.PA_PROJECT_TASK_ID        := P_Dest_Instance_Tbl(a).PA_PROJECT_TASK_ID;
    X_Instance_Rec.IN_TRANSIT_ORDER_LINE_ID  := P_Dest_Instance_Tbl(a).IN_TRANSIT_ORDER_LINE_ID;
    X_Instance_Rec.WIP_JOB_ID                := P_Dest_Instance_Tbl(a).WIP_JOB_ID ;
    X_Instance_Rec.PO_ORDER_LINE_ID          := P_Dest_Instance_Tbl(a).PO_ORDER_LINE_ID;
    X_Instance_Rec.LAST_OE_ORDER_LINE_ID     := P_Dest_Instance_Tbl(a).LAST_OE_ORDER_LINE_ID;
    X_Instance_Rec.LAST_OE_RMA_LINE_ID       := P_Dest_Instance_Tbl(a).LAST_OE_RMA_LINE_ID;
    X_Instance_Rec.LAST_PO_PO_LINE_ID        := P_Dest_Instance_Tbl(a).LAST_PO_PO_LINE_ID;
    X_Instance_Rec.LAST_OE_PO_NUMBER         := P_Dest_Instance_Tbl(a).LAST_OE_PO_NUMBER;
    X_Instance_Rec.LAST_PA_PROJECT_ID        := P_Dest_Instance_Tbl(a).LAST_PA_PROJECT_ID;
    X_Instance_Rec.LAST_PA_TASK_ID           := P_Dest_Instance_Tbl(a).LAST_PA_TASK_ID;
    X_Instance_Rec.LAST_OE_AGREEMENT_ID      := P_Dest_Instance_Tbl(a).LAST_OE_AGREEMENT_ID;
    X_Instance_Rec.INSTALL_DATE              := P_Dest_Instance_Tbl(a).INSTALL_DATE;
    X_Instance_Rec.MANUALLY_CREATED_FLAG     := P_Dest_Instance_Tbl(a).MANUALLY_CREATED_FLAG ;
    X_Instance_Rec.RETURN_BY_DATE            := P_Dest_Instance_Tbl(a).RETURN_BY_DATE;
    X_Instance_Rec.ACTUAL_RETURN_DATE        := P_Dest_Instance_Tbl(a).ACTUAL_RETURN_DATE;
    X_Instance_Rec.CREATION_COMPLETE_FLAG    := P_Dest_Instance_Tbl(a).CREATION_COMPLETE_FLAG;
    X_Instance_Rec.COMPLETENESS_FLAG         := P_Dest_Instance_Tbl(a).COMPLETENESS_FLAG;
 --   X_Instance_Rec.VERSION_LABEL             := P_Dest_Instance_Tbl(a).VERSION_LABEL;
 --   X_Instance_Rec.VERSION_LABEL_DESCRIPTION := P_Dest_Instance_Tbl(a).VERSION_LABEL_DESCRIPTION;
    X_Instance_Rec.CONTEXT                   := P_Dest_Instance_Tbl(a).CONTEXT ;
    X_Instance_Rec.ATTRIBUTE1                := P_Dest_Instance_Tbl(a).ATTRIBUTE1;
    X_Instance_Rec.ATTRIBUTE2                := P_Dest_Instance_Tbl(a).ATTRIBUTE2;
    X_Instance_Rec.ATTRIBUTE3                := P_Dest_Instance_Tbl(a).ATTRIBUTE3;
    X_Instance_Rec.ATTRIBUTE4                := P_Dest_Instance_Tbl(a).ATTRIBUTE4;
    X_Instance_Rec.ATTRIBUTE5                := P_Dest_Instance_Tbl(a).ATTRIBUTE5;
    X_Instance_Rec.ATTRIBUTE6                := P_Dest_Instance_Tbl(a).ATTRIBUTE6;
    X_Instance_Rec.ATTRIBUTE7                := P_Dest_Instance_Tbl(a).ATTRIBUTE7;
    X_Instance_Rec.ATTRIBUTE8                := P_Dest_Instance_Tbl(a).ATTRIBUTE8;
    X_Instance_Rec.ATTRIBUTE9                := P_Dest_Instance_Tbl(a).ATTRIBUTE9;
    X_Instance_Rec.ATTRIBUTE10               := P_Dest_Instance_Tbl(a).ATTRIBUTE10;
    X_Instance_Rec.ATTRIBUTE11               := P_Dest_Instance_Tbl(a).ATTRIBUTE11;
    X_Instance_Rec.ATTRIBUTE12               := P_Dest_Instance_Tbl(a).ATTRIBUTE12;
    X_Instance_Rec.ATTRIBUTE13               := P_Dest_Instance_Tbl(a).ATTRIBUTE13;
    X_Instance_Rec.ATTRIBUTE14               := P_Dest_Instance_Tbl(a).ATTRIBUTE14;
    X_Instance_Rec.ATTRIBUTE15               := P_Dest_Instance_Tbl(a).ATTRIBUTE15;
    X_Instance_Rec.OBJECT_VERSION_NUMBER     := P_Dest_Instance_Tbl(a).OBJECT_VERSION_NUMBER;


 END IF;
EXCEPTION
WHEN e_Nothing THEN
 NULL;
WHEN Multiple_Active_Exp THEN
    fnd_message.set_name('CSE','CSE_MULTIPLE_ACT_INST_FOUND');
    fnd_message.set_token('INV_ITEM',P_Dest_Instance_Tbl(1).INVENTORY_ITEM_ID);
    x_error_message := fnd_message.get;
    x_return_status :=FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
    fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
    fnd_message.set_token('API_NAME',l_api_name);
    fnd_message.set_token('SQL_ERROR',SQLERRM);
    x_error_message := fnd_message.get;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_destination_instance;

PROCEDURE get_hz_location (p_network_location_code   IN    VARCHAR2,
                           x_hz_location_id          OUT NOCOPY   NUMBER,
                           x_return_status           OUT NOCOPY   VARCHAR2,
                           x_error_message           OUT NOCOPY   VARCHAR2)
IS

cursor hz_loc is
  select location_id
  from hz_locations
  where clli_code=p_network_location_code;

l_api_name CONSTANT VARCHAR2(30) := 'GET_HZ_LOCATION';
l_loop_count  NUMBER:=0;
hz_loc_not_found EXCEPTION;

BEGIN
  x_return_status:=FND_API.G_RET_STS_SUCCESS;
  x_error_message:=null;

FOR hz_loc_rec in hz_loc
LOOP

 x_hz_location_id:=hz_loc_rec.location_id;
 l_loop_count:=l_loop_count+1;

END LOOP;

IF l_loop_count=0 THEN
  RAISE hz_loc_not_found;
END IF;

EXCEPTION
  WHEN hz_loc_not_found THEN
    fnd_message.set_name('CSE','CSE_HZ_LOC_ID_NOTFOUND');
    fnd_message.set_token('NETWORK_LOC_CODE',p_network_location_code);
    x_error_message := fnd_message.get;
    x_return_status :=FND_API.G_RET_STS_ERROR;
  WHEN others THEN
   fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
   fnd_message.set_token('ERR_MSG',l_Api_Name||'='|| SQLERRM);
   x_error_message := fnd_message.get;
   x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_hz_location;

PROCEDURE get_hz_location (p_party_site_id           IN    NUMBER,
                           x_hz_location_id          OUT NOCOPY   NUMBER,
                           x_return_status           OUT NOCOPY   VARCHAR2,
                           x_error_message           OUT NOCOPY   VARCHAR2)
IS

cursor hz_loc is
  select location_id
  from hz_party_sites
  where party_site_id=p_party_site_id;

l_api_name CONSTANT VARCHAR2(30) := 'GET_HZ_LOCATION';
l_loop_count  NUMBER:=0;
hz_loc_not_found EXCEPTION;

BEGIN
  x_return_status:=FND_API.G_RET_STS_SUCCESS;
  x_error_message:=null;

FOR hz_loc_rec in hz_loc
LOOP

 x_hz_location_id:=hz_loc_rec.location_id;
 l_loop_count:=l_loop_count+1;

END LOOP;

IF l_loop_count=0 THEN
  RAISE hz_loc_not_found;
END IF;

EXCEPTION
  WHEN hz_loc_not_found THEN
 fnd_message.set_name('CSE','CSE_PARTY_SITE_NOTFOUND');
    fnd_message.set_token('PARTY_SITE',p_party_site_id);
    x_error_message := fnd_message.get;
    x_return_status :=FND_API.G_RET_STS_ERROR;
  WHEN others THEN
   fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
   fnd_message.set_token('ERR_MSG',l_Api_Name||'='|| SQLERRM);
   x_error_message := fnd_message.get;
   x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_hz_location;

PROCEDURE get_fa_location(p_hz_location_id  IN  NUMBER,
                          p_loc_type_code   IN  VARCHAR2,
                          x_fa_location_id  OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_error_message   OUT NOCOPY VARCHAR2)

IS
cursor fa_loc is
  select fa_location_id
  from   csi_a_locations
  where  location_id =p_hz_location_id;

l_loop_count  NUMBER:=0;
fa_loc_not_found EXCEPTION;
l_api_name CONSTANT VARCHAR2(30) := 'GET_FA_LOCATION';

BEGIN
x_return_status:=FND_API.G_RET_STS_SUCCESS;
x_error_message:=null;
FOR fa_loc_rec in fa_loc
LOOP

 x_fa_location_id:=fa_loc_rec.fa_location_id;
 l_loop_count:=l_loop_count+1;

END LOOP;

IF l_loop_count=0 THEN
  RAISE fa_loc_not_found;
END IF;

EXCEPTION
  WHEN fa_loc_not_found THEN
    fnd_message.set_name('CSE','CSE_FA_LOC_ID_NOTFOUND');
    fnd_message.set_token('HZ_LOCATION_ID',p_hz_location_id);
    x_error_message := fnd_message.get;
    x_return_status :=FND_API.G_RET_STS_ERROR;
  WHEN others THEN
    fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    fnd_message.set_token('ERR_MSG',l_Api_Name||'='|| SQLERRM);
    x_error_message := fnd_message.get;
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE get_master_organization(p_organization_id          IN  NUMBER,
                                  p_master_organization_id   OUT NOCOPY NUMBER,
                                  x_return_status            OUT NOCOPY VARCHAR2,
                                  x_error_message            OUT NOCOPY VARCHAR2)
IS

l_sql_error         VARCHAR2(500);
l_org_code          VARCHAR2(3);
l_fnd_success       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnd_error         VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected    VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
l_error_message     VARCHAR2(2000);
e_procedure_error   EXCEPTION;

CURSOR c_name is
  SELECT organization_code
  FROM   mtl_parameters
  WHERE  organization_id = p_organization_id;

r_name   c_name%rowtype;

CURSOR c_id IS
  SELECT master_organization_id
  FROM   mtl_parameters
  WHERE  organization_id = p_organization_id;

r_id     c_id%rowtype;

BEGIN

  l_error_message := NULL;
  x_return_status := l_fnd_success;

  OPEN c_id;
  FETCH c_id into r_id;
  IF c_id%found then
    p_master_organization_id := r_id.master_organization_id;
  ELSE
    OPEN c_name;
    FETCH c_name into r_name;
    if c_name%found then
      l_org_code := r_name.organization_code;
    end if;
    RAISE e_procedure_error;
  END IF;

EXCEPTION
  WHEN e_procedure_error THEN
     fnd_message.set_name('CSE','CSE_MSTR_ORG_NOTFOUND');
     fnd_message.set_token('ORGANIZATION_ID',p_organization_id);
     fnd_message.set_token('ORGANIZATION_CODE',l_org_code);
     x_error_message := fnd_message.get;
     x_return_status := l_fnd_error;

  WHEN others THEN
     fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
     fnd_message.set_token('SQL_ERROR',SQLERRM);
     x_error_message := fnd_message.get;
     x_return_status := l_fnd_unexpected;
END get_master_organization;

PROCEDURE build_error_string (
        p_string            IN OUT NOCOPY  VARCHAR2,
        p_attribute         IN      VARCHAR2,
        p_value             IN      VARCHAR2) IS

BEGIN
	p_string := p_string || '<' || p_attribute || '>' ;
	p_string := p_string || p_value ;
	p_string := p_string || '</' || p_attribute || '>' ;

END build_error_string;

PROCEDURE get_string_value (
        p_string            IN      VARCHAR2,
        p_attribute         IN      VARCHAR2,
        x_value             OUT NOCOPY     VARCHAR2) IS

  tag_pos           INTEGER := 0 ;
  token             VARCHAR2(1024) := '' ;
  token_delimeter   VARCHAR2(1024) := '' ;
  tag_delimeter_pos INTEGER := 0 ;

BEGIN

  token := '<' || p_attribute || '>' ;
  token_delimeter := '</' || p_attribute || '>' ;
  tag_pos := INSTR( p_string, token, 1 ) ;

  IF (tag_pos = 0)
  THEN
    x_value := NULL ;
    RETURN ;
  END IF ;

  tag_delimeter_pos := INSTR( p_string, token_delimeter, 1 ) ;

  IF (tag_delimeter_pos = 0)
  THEN
    x_value := NULL ;
    RETURN ;
  END IF ;

  x_value := SUBSTR(p_string, tag_pos + LENGTH(token),
            tag_delimeter_pos - (tag_pos + LENGTH(token))) ;

END get_string_value;

--This procedure tries to acquire a lock for infinite time for
--the given lockname.
--Also this procedure releases the lock on COMMIT ;
FUNCTION Init_Instance_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Query_Rec IS
 l_Instance_Query_Rec CSI_DataStructures_Pub.Instance_Query_Rec;
BEGIN
RETURN l_Instance_Query_Rec;
END Init_Instance_Query_Rec;

FUNCTION Init_Instance_Create_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec IS
l_Instance_Rec  CSI_DATASTRUCTURES_PUB.Instance_Rec;
BEGIN
  l_instance_rec.version_label          := 'AS-CREATED';
  l_instance_rec.creation_complete_flag := NULL;
RETURN l_Instance_Rec;
END Init_Instance_Create_Rec;

FUNCTION Init_Instance_Update_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec IS
l_Instance_Rec  CSI_DATASTRUCTURES_PUB.Instance_Rec;
BEGIN
RETURN l_Instance_Rec;
END Init_Instance_Update_Rec;



FUNCTION Init_Party_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Tbl IS
 l_Party_Tbl  CSI_DATASTRUCTURES_PUB.Party_Tbl;
 l_Party_Id  NUMBER;

BEGIN

 IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL
 THEN
    csi_gen_utility_pvt.populate_install_param_rec;
 END IF;
 l_Party_ID := csi_datastructures_pub.g_install_param_rec.Internal_Party_Id;

   l_Party_Tbl(1).party_source_table      := 'HZ_PARTIES' ;
   l_Party_Tbl(1).party_id                := l_Party_Id;
   l_Party_Tbl(1).relationship_type_code  := 'OWNER';
   l_Party_Tbl(1).contact_flag            := 'N';

  RETURN l_Party_Tbl;
END Init_Party_Tbl;

FUNCTION Init_Account_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Account_Tbl IS
l_Account_Tbl CSI_DATASTRUCTURES_PUB.Party_Account_Tbl;
BEGIN
RETURN l_Account_Tbl;
END Init_Account_Tbl;

FUNCTION Init_ext_attrib_values_tbl RETURN CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl IS
l_extend_attrib_values_tbl  CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
BEGIN
RETURN l_extend_attrib_values_tbl;
END Init_ext_attrib_values_tbl;

FUNCTION Init_Pricing_Attribs_Tbl RETURN CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl IS
l_Pricing_Attribs_Tbl  CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
BEGIN
RETURN l_Pricing_Attribs_Tbl;
END Init_Pricing_Attribs_Tbl;

FUNCTION Init_Org_Assignments_Tbl RETURN CSI_DATASTRUCTURES_PUB.organization_units_tbl IS
l_Org_Assignments_Tbl  CSI_DATASTRUCTURES_PUB.organization_units_tbl;
BEGIN
RETURN l_Org_Assignments_Tbl;
END Init_Org_Assignments_Tbl;

FUNCTION Init_Asset_Assignment_Tbl RETURN CSI_DATASTRUCTURES_PUB.instance_asset_tbl IS
l_Asset_Assignment_Tbl CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
BEGIN
RETURN l_Asset_Assignment_Tbl;
END Init_Asset_Assignment_Tbl;

FUNCTION Init_Instance_Asset_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Query_Rec IS
l_instance_asset_Query_Rec CSI_DATASTRUCTURES_PUB.instance_asset_Query_Rec;
BEGIN
RETURN l_instance_asset_Query_Rec;
END Init_Instance_Asset_Query_Rec;

FUNCTION Init_Instance_Asset_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Rec IS
l_instance_asset_Rec CSI_DATASTRUCTURES_PUB.instance_asset_Rec;
BEGIN
RETURN l_instance_asset_Rec;
END Init_Instance_Asset_Rec;

FUNCTION Get_Txn_Type_Id(P_Txn_Type IN VARCHAR2,
                         P_App_Short_Name IN VARCHAR2) RETURN NUMBER IS
l_Txn_Type_Id NUMBER;
CURSOR Txn_Type_Cur IS
    SELECT ctt.Transaction_Type_Id Transaction_Type_Id
    FROM   CSI_Txn_Types ctt,
           FND_Application fa
    WHERE  ctt.Source_Transaction_Type = P_Txn_Type
    AND    fa.application_id   = ctt.Source_Application_ID
    AND    fa.Application_Short_Name = P_App_Short_Name;
BEGIN
OPEN Txn_Type_Cur;
FETCH Txn_Type_Cur INTO l_Txn_Type_Id;
CLOSE Txn_Type_Cur;
RETURN l_Txn_Type_Id;
END Get_Txn_Type_Id;

FUNCTION Get_Txn_Type_Code(P_Txn_Id IN NUMBER) RETURN VARCHAR2 IS
l_Txn_Type_Code VARCHAR2(100);
CURSOR Txn_Type_Id_Cur IS
    SELECT Source_Transaction_Type
    FROM   CSI_Txn_Types
    WHERE  Transaction_Type_Id = P_Txn_Id;
BEGIN
OPEN Txn_Type_Id_Cur;
FETCH Txn_Type_Id_Cur INTO l_Txn_Type_Code;
CLOSE Txn_Type_Id_Cur;
RETURN l_Txn_Type_Code;
END Get_Txn_Type_Code;

FUNCTION Get_Txn_Status_Code(P_Txn_Status IN VARCHAR2) RETURN VARCHAR2 IS
l_Txn_Status_Code VARCHAR2(30) ;
BEGIN
l_Txn_Status_Code := FND_API.G_MISS_CHAR;
RETURN l_Txn_Status_Code;
END Get_Txn_Status_Code;

FUNCTION Get_Location_Type_Code(P_Location_Meaning in VARCHAR2) RETURN VARCHAR2 IS

l_location_type_code     VARCHAR2(50);

CURSOR c_code IS
  SELECT lookup_code
  FROM   csi_lookups
  WHERE  lookup_type = 'CSI_INST_LOCATION_SOURCE_CODE'
  AND    lookup_code = upper(P_Location_Meaning);

r_code     c_code%rowtype;

BEGIN
  OPEN c_code;
  FETCH c_code into r_code;
  IF c_code%found THEN
    l_location_type_code := r_code.lookup_code;
  ELSE
    l_location_type_code := NULL;
  END IF;
  CLOSE c_code;
  RETURN l_location_type_code;
END Get_Location_Type_Code;


FUNCTION Get_Dflt_Project_Location_Id RETURN NUMBER IS

l_project_location_id     NUMBER :=0;

BEGIN
 IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL
 THEN
    csi_gen_utility_pvt.populate_install_param_rec;
 END IF;
  l_project_location_id := csi_datastructures_pub.g_install_param_rec.project_location_id;
  RETURN l_project_location_id;
END Get_Dflt_Project_Location_Id;

FUNCTION Get_Default_Status_Id (p_transaction_id in number) RETURN NUMBER IS

l_transaction_id     NUMBER;

CURSOR c_id IS
  SELECT   src_status_id
  FROM     csi_txn_sub_types
  WHERE    transaction_type_id = p_transaction_id
  AND      default_flag = 'Y';

r_id     c_id%rowtype;

BEGIN
  OPEN c_id;
  FETCH c_id into r_id;
  IF c_id%found THEN
    l_transaction_id := r_id.src_status_id;
  ELSE
    l_transaction_id := NULL;
  END IF;
  CLOSE c_id;
  RETURN l_transaction_id;
END Get_Default_Status_id;

FUNCTION Get_Txn_Action_Code(P_Txn_Action IN VARCHAR2) RETURN VARCHAR2 IS
l_Txn_Action_Code VARCHAR2(30) ;

BEGIN
  l_Txn_Action_Code := FND_API.G_MISS_CHAR;
  RETURN l_Txn_Action_Code;
END Get_Txn_Action_Code;

FUNCTION Get_Fnd_Employee_Id(P_Last_Updated IN NUMBER) RETURN NUMBER IS

l_employee_id     NUMBER;

CURSOR c_id IS
  SELECT employee_id
  FROM   fnd_user
  WHERE  user_id = p_last_updated;

r_id     c_id%rowtype;

BEGIN
  OPEN c_id;
  FETCH c_id into r_id;
  IF c_id%found THEN
    l_employee_id := r_id.employee_id;
  ELSE
    l_employee_id := -1;
  END IF;
  CLOSE c_id;
  RETURN l_employee_id;
END Get_Fnd_Employee_Id;

FUNCTION Init_Txn_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Rec IS
l_Txn_Rec CSI_DATASTRUCTURES_PUB.TRANSACTION_Rec;
BEGIN
  RETURN l_Txn_Rec;
END Init_Txn_Rec;

FUNCTION Init_Txn_Error_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec IS
l_Txn_Error_Rec CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec;
BEGIN
  l_Txn_Error_Rec.processed_flag      := CSE_DATASTRUCTURES_PUB.G_TXN_ERROR;
  RETURN l_Txn_Error_Rec;
END Init_Txn_Error_Rec;

FUNCTION Init_Party_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Party_Query_Rec IS
l_Party_Query_Rec CSI_DATASTRUCTURES_PUB.Party_Query_Rec;
 l_Party_Id  NUMBER;

BEGIN

 IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL
 THEN
    csi_gen_utility_pvt.populate_install_param_rec;
 END IF;

 l_Party_ID := csi_datastructures_pub.g_install_param_rec.Internal_Party_Id;


     l_Party_Query_Rec.party_id                := l_Party_Id;
     l_Party_Query_Rec.relationship_type_code  := 'OWNER';

RETURN  l_Party_Query_Rec;

END Init_Party_Query_Rec;
FUNCTION Is_Conc_Prg_Running(P_Request_ID IN NUMBER,
                             P_Executable IN VARCHAR2)
  RETURN BOOLEAN IS
 l_Return BOOLEAN := TRUE;
 l_Dummy VARCHAR2(1);
 CURSOR Conc_Cur IS
 SELECT 'X'
 FROM Fnd_Concurrent_Requests fcr,
      Fnd_Concurrent_Programs fcp,
      fnd_executables         fe
 WHERE fcr.Program_Application_Id = fcp.Application_Id
 AND   fcr.Concurrent_Program_Id  = fcp.Concurrent_Program_Id
 AND   fcr.Phase_Code = 'R'
 AND   fcr.Request_Id <> P_Request_Id
 AND   fcp.Executable_Application_Id = fe.Application_Id
 AND   fcp.Executable_Id = fe.Executable_Id
 AND   fcp.application_id = 873
 AND   fe.Executable_Name = P_Executable;
BEGIN
 OPEN Conc_Cur;
 FETCH Conc_Cur INTO l_Dummy;
  IF NOT Conc_Cur%FOUND
  THEN l_Return := FALSE;
  ELSE l_Return := TRUE;
  END IF;
 CLOSE Conc_Cur;
 RETURN l_Return;
EXCEPTION
 WHEN OTHERS THEN
 RETURN l_Return;
END Is_Conc_Prg_Running;


 PROCEDURE write_log (P_Message IN VARCHAR2) IS
 l_debug varchar2(1);
 BEGIN
    l_debug  := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'), 'Y');
    IF l_debug = 'Y'
    THEN
       FND_File.Put_Line(Fnd_File.LOG,P_Message);
    END IF ;
 EXCEPTION
 WHEN OTHERS THEN
    RAISE;
 END write_log;

 FUNCTION get_inv_name (p_transaction_id IN NUMBER) RETURN VARCHAR2 IS

 l_transaction_type_id     NUMBER;
 l_inv_name                VARCHAR2(30);

  CURSOR x is
    SELECT transaction_type_id
    FROM mtl_material_transactions
    WHERE transaction_id = p_transaction_id;

 BEGIN

   OPEN x;
   FETCH x into l_transaction_type_id;
   CLOSE x;

   IF l_transaction_type_id = 1 THEN --	Account issue
     l_inv_name := 'ACCT_ISSUE';
   ELSIF l_transaction_type_id = 2 THEN --	Subinventory Transfer
     l_inv_name := 'SUBINVENTORY_TRANSFER';
   ELSIF l_transaction_type_id = 3 THEN --	Direct Org Transfer
     l_inv_name := 'INTERORG_DIRECT_SHIP';
   ELSIF l_transaction_type_id = 4 THEN --	Cycle Count Adjust
     l_inv_name := 'CYCLE_COUNT';
   ELSIF l_transaction_type_id = 5 THEN --	Cycle Count Transfer
     l_inv_name := 'CYCLE_COUNT_TRANSFER';
   ELSIF l_transaction_type_id = 8 THEN --	Physical Inv Adjust
     l_inv_name := 'PHYSICAL_INVENTORY';
   ELSIF l_transaction_type_id = 9 THEN --	Physical Inv Transfer
     l_inv_name := 'PHYSICAL_INV_TRANSFER';
   ELSIF l_transaction_type_id = 12 THEN --	Intransit Receipt
     l_inv_name := 'INTERORG_TRANS_RECEIPT';
   ELSIF l_transaction_type_id = 15 THEN --	RMA Receipt
     l_inv_name := 'RMA_RECEIPT';
   ELSIF l_transaction_type_id = 17 THEN --	WIP Assembly Return
     l_inv_name := 'WIP_ISSUE';
   ELSIF l_transaction_type_id = 18 THEN --	PO Receipt
     l_inv_name := 'PO_RECEIPT_INTO_INVENTORY';
   ELSIF l_transaction_type_id = 21 THEN --	Intransit Shipment
     l_inv_name := 'INTERORG_TRANS_SHIPMENT';
   --ELSIF l_transaction_type_id = 25 THEN --	WIP cost update
   --ELSIF l_transaction_type_id = 26 THEN --	Periodic Cost Update
   --ELSIF l_transaction_type_id = 28 THEN --	Layer Cost Update
   ELSIF l_transaction_type_id = 31 THEN --	Account alias issue
     l_inv_name := 'ACCT_ALIAS_ISSUE';
   ELSIF l_transaction_type_id = 32 THEN --	Miscellaneous issue
     l_inv_name := 'MISC_ISSUE';
   ELSIF l_transaction_type_id = 33 THEN --	Sales order issue
     l_inv_name := 'OM_SHIPMENT';
   ELSIF l_transaction_type_id = 34 THEN --	Internal order issue
     l_inv_name := 'ISO_ISSUE';
   ELSIF l_transaction_type_id = 35 THEN --	WIP component issue
     l_inv_name := 'WIP_ISSUE';
   ELSIF l_transaction_type_id = 36 THEN --	Return to Vendor
     l_inv_name := 'RETURN_TO_VENDOR';
   --ELSIF l_transaction_type_id = 37 THEN --	RMA Return
   ELSIF l_transaction_type_id = 38 THEN --	WIP Neg Comp Issue
     l_inv_name := 'WIP_RECEIPT';
   ELSIF l_transaction_type_id = 40 THEN --	Account receipt
     l_inv_name := 'ACCT_RECEIPT';
   ELSIF l_transaction_type_id = 41 THEN --	Account alias receipt
     l_inv_name := 'ACCT_ALIAS_RECEIPT';
   ELSIF l_transaction_type_id = 42 THEN --	Miscellaneous receipt
     l_inv_name := 'MISC_RECEIPT';
   ELSIF l_transaction_type_id = 43 THEN --	WIP Component Return
     l_inv_name := 'WIP_RECEIPT';
   ELSIF l_transaction_type_id = 44 THEN --	WIP Assy Completion
     l_inv_name := 'WIP_ASSEMBLY_COMPLETION';
   ELSIF l_transaction_type_id = 48 THEN --	WIP Neg Comp Return
     l_inv_name := 'WIP_ISSUE';
   ELSIF l_transaction_type_id = 50 THEN --	Internal Order Xfer
     l_inv_name := 'ISO_TRANSFER';
   ELSIF l_transaction_type_id = 51 THEN --	Backflush Transfer
     l_inv_name := 'BACKFLUSH_TRANSFER';
   ELSIF l_transaction_type_id = 52 THEN --	Sales Order Pick
     l_inv_name := 'SALES_ORDER_PICK';
   ELSIF l_transaction_type_id = 53 THEN --	Internal Order Pick
     l_inv_name := 'ISO_PICK';
   ELSIF l_transaction_type_id = 54 THEN --	Int Order Direct Ship
     l_inv_name := 'ISO_DIRECT_SHIP';
   --ELSIF l_transaction_type_id = 55 THEN --	WIP Lot Split
   --ELSIF l_transaction_type_id = 56 THEN --	WIP Lot Merge
   --ELSIF l_transaction_type_id = 57 THEN --	Lot Bonus
   --ELSIF l_transaction_type_id = 58 THEN --	Lot Update Quantity
   ELSIF l_transaction_type_id = 61 THEN --	Int Req Intr Rcpt
     l_inv_name := 'ISO_REQUISITION_RECEIPT';
   ELSIF l_transaction_type_id = 62 THEN --	Int Order Intr Ship
     l_inv_name := 'ISO_SHIPMENT';
   ELSIF l_transaction_type_id = 63 THEN --	Move Order Issue
     l_inv_name := 'MOVE_ORDER_ISSUE';
   ELSIF l_transaction_type_id = 64 THEN --	Move Order Transfer
     l_inv_name := 'MOVE_ORDER_TRANSFER';
   ELSIF l_transaction_type_id = 66 THEN --	Project Borrow
     l_inv_name := 'PROJECT_BORROW';
   ELSIF l_transaction_type_id = 67 THEN --	Project Transfer
     l_inv_name := 'PROJECT_TRANSFER';
   ELSIF l_transaction_type_id = 68 THEN --	Project Payback
     l_inv_name := 'PROJECT_PAYBACK';
   ELSIF l_transaction_type_id = 70 THEN --	Shipment Rcpt Adjust
     l_inv_name := 'SHIPMENT_RCPT_ADJUSTMENT';
   ELSIF l_transaction_type_id = 71 THEN --	PO Rcpt Adjust
     l_inv_name := 'PO_RCPT_ADJUSTMENT';
   ELSIF l_transaction_type_id = 72 THEN --	Int Req Rcpt Adjust
     l_inv_name := 'INT_REQ_RCPT_ADJUSTMENT';
   --ELSIF l_transaction_type_id = 73 THEN --	Planning Transfer
   ELSIF l_transaction_type_id = 77 THEN --	ProjectContract Issue
     l_inv_name := 'OKE_SHIPMENT';
   --ELSIF l_transaction_type_id = 80 THEN --	Average cost update
   --ELSIF l_transaction_type_id = 82 THEN --	Inventory Lot Split
   --ELSIF l_transaction_type_id = 83 THEN --	Inventory Lot Merge
   --ELSIF l_transaction_type_id = 84 THEN --	Inventory Lot Translate
   --ELSIF l_transaction_type_id = 86 THEN --	Cost Group Transfer
   --ELSIF l_transaction_type_id = 87 THEN --	Container Pack
   --ELSIF l_transaction_type_id = 88 THEN --	Container Unpack
   --ELSIF l_transaction_type_id = 89 THEN --	Container Split
   --ELSIF l_transaction_type_id = 90 THEN --	WIP assembly scrap
   --ELSIF l_transaction_type_id = 91 THEN --	WIP return from scrap
   --ELSIF l_transaction_type_id = 92 THEN --	WIP estimated scrap
   ELSE
     l_inv_name := NULL;
   END IF;

   RETURN l_inv_name;
 END get_inv_name;
 PROCEDURE Check_if_top_assembly(p_instance_id IN NUMBER,
                       x_yes_top_assembly OUT NOCOPY BOOLEAN,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_error_message OUT NOCOPY VARCHAR2) IS
 CURSOR check_top_assembly(p_id IN NUMBER) IS
  SELECT 1
  FROM csi_ii_relationships ciir1
  WHERE ciir1.object_id = p_id
  AND ciir1.relationship_type_code = 'COMPONENT-OF'
  AND NOT EXISTS (select ciir2.subject_id
                  from csi_ii_relationships ciir2
                  where ciir2.relationship_type_code = 'COMPONENT-OF'
                  and ciir2.subject_id = p_id);

  l_dummy PLS_INTEGER;
 BEGIN
 x_return_status  := FND_API.G_RET_STS_SUCCESS;
 x_yes_top_assembly := FALSE;

 OPEN check_top_assembly(p_instance_id);
 FETCH check_top_assembly INTO l_dummy;
 CLOSE check_top_assembly;

 IF l_dummy = 1
 THEN x_yes_top_assembly := TRUE;
 END IF;

 EXCEPTION
  	WHEN OTHERS THEN
          IF check_top_assembly%ISOPEN
          THEN CLOSE check_top_assembly;
          END IF;
    		fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    		fnd_message.set_token('ERR_MSG', sqlerrm);
                x_return_status := fnd_api.g_ret_sts_unexp_error;
    		x_error_message := fnd_message.get;
--    		CSE_DEBUG_PUB.ADD('API CSE_UTIL_PKG.check_top_assembly others exception: ' || l_err_text);
 END check_if_top_assembly;

------------------------------------------------------------------------------
---
---             Added for Redeployment functionality.
---             This procedure returns x_redeploy_flag as 'Y'
---             If there exists a OUT-OF-SERVICE' transaction
---             previous to the p_transaction_date (by default, it is SYSDATE
---
------------------------------------------------------------------------------
PROCEDURE get_redeploy_flag(
              p_inventory_item_id IN NUMBER
             ,p_serial_number     IN VARCHAR2
             ,p_transaction_date  IN DATE
             ,x_redeploy_flag     OUT NOCOPY VARCHAR2
             ,x_return_status     OUT NOCOPY VARCHAR2
             ,x_error_message     OUT NOCOPY VARCHAR2)
IS
l_out_of_sev  NUMBER;
l_proj_insev  NUMBER;
l_issue_hz  NUMBER;
l_misc_issue_hz NUMBER;

CURSOR get_redeploy_flag_cur
IS
SELECT 'Y' redeploy_flag
FROM   csi_transactions ct
      ,csi_item_instances_h ciih
      ,csi_item_instances cii
WHERE  ct.transaction_id = ciih.transaction_id
AND    ciih.instance_id = cii.instance_id
AND    cii.inventory_item_id = p_inventory_item_id
AND    cii.serial_number = p_serial_number
AND    ct.transaction_date < NVL(p_transaction_date, SYSDATE)
AND    ct.transaction_type_id IN (l_out_of_sev, l_proj_insev, l_issue_hz, l_misc_issue_hz) ;

BEGIN
   x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   x_redeploy_flag := 'N' ;

   l_out_of_sev := get_txn_type_id('OUT_OF_SERVICE','CSE');
   l_proj_insev := get_txn_type_id('PROJECT_ITEM_IN_SERVICE','CSE');
   l_issue_hz := get_txn_type_id('ISSUE_TO_HZ_LOC','INV');
   l_misc_issue_hz := get_txn_type_id('MISC_ISSUE_HZ_LOC','INV');

   OPEN get_redeploy_flag_cur ;
   FETCH get_redeploy_flag_cur INTO x_redeploy_flag ;
   CLOSE get_redeploy_flag_cur ;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := fnd_api.G_RET_STS_ERROR ;
    x_error_message := SQLERRM ;
END get_redeploy_flag ;


------------------------------------------------------------------------------

PROCEDURE get_inst_n_comp_dtls(
             p_instance_id	 IN NUMBER
            ,p_transaction_id    IN NUMBER
            ,p_transaction_date  IN DATE
            ,x_inst_dtls_tbl     OUT NOCOPY csi_datastructures_pub.instance_header_tbl
            ,x_return_status     OUT NOCOPY VARCHAR2
            ,x_error_message     OUT NOCOPY VARCHAR2)
IS

-------------------------------------------------------------------------------
--         Logic for get_inst_n_comp_dtls
--         Get all the Components of the given instance
--         For each component and the instance itself get the instance details
--         Populate the out table
-------------------------------------------------------------------------------
l_api_version                   NUMBER           DEFAULT    1.0;
l_commit                        VARCHAR2(1)      DEFAULT        FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)       DEFAULT    FND_API.G_TRUE;
l_validation_level              NUMBER   := fnd_api.g_valid_level_full;
l_instance_header_tbl_out       csi_datastructures_pub.instance_header_tbl;
l_resolve_id_columns            VARCHAR2(1)   DEFAULT    FND_API.G_FALSE;
l_msg_index                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_count                     NUMBER;
l_return_status                 VARCHAR2(1);
l_error_message                 VARCHAR2(2000);
l_instance_rec             csi_datastructures_pub.instance_header_rec ;
l_party_header_tbl         csi_datastructures_pub.party_header_tbl  ;
l_account_header_tbl       csi_datastructures_pub.party_account_header_tbl ;
l_org_header_tbl           csi_datastructures_pub.org_units_header_tbl ;
l_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl ;
l_ext_attrib_tbl           csi_datastructures_pub.extend_attrib_values_tbl ;
l_ext_attrib_def_tbl       csi_datastructures_pub.extend_attrib_tbl ;
l_asset_header_tbl         csi_datastructures_pub.instance_asset_header_tbl;
l_relationship_query_rec   csi_datastructures_pub.relationship_query_rec ;
l_ii_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl ;
e_error                    EXCEPTION ;
i                          INTEGER ;
j                          INTEGER ;
k                          INTEGER ;

BEGIN
    l_instance_rec := NULL ;
    l_instance_rec.instance_id := p_instance_id ;
    i:= 0;
    j := 0;
    k := 0;
    cse_util_pkg.write_log('Call get item instance details');
    csi_item_instance_pub.get_item_instance_details(
        p_api_version		 =>	l_api_version,
        p_commit 		 =>  l_commit,
        p_init_msg_list     =>	l_init_msg_list,
        p_validation_level  =>  l_Validation_Level,
	p_instance_rec      =>  l_instance_rec,
	p_get_parties       =>  NULL,
	p_party_header_tbl  =>  l_party_header_tbl,
	p_get_accounts      =>  NULL,
	p_account_header_tbl => l_account_header_tbl,
	p_get_org_assignments  => NULL,
	p_org_header_tbl       => l_org_header_tbl,
	p_get_pricing_attribs  => NULL,
	p_pricing_attrib_tbl   => l_pricing_attrib_tbl,
	p_get_ext_attribs      => NULL,
	p_ext_attrib_tbl       => l_ext_attrib_tbl,
	p_ext_attrib_def_tbl   => l_ext_attrib_def_tbl,
	p_get_asset_assignments => NULL,
	p_asset_header_tbl      =>  l_asset_header_tbl,
        p_resolve_id_columns      =>  l_resolve_id_columns,
	p_time_stamp             =>  p_transaction_date ,
        x_return_status       	=>	l_return_status,
        x_msg_count            	=>	l_Msg_Count,
        x_msg_data             	=>	l_Msg_Data );

        cse_util_pkg.write_log('Return Status : '|| l_return_status);


        IF l_return_status = fnd_api.g_ret_sts_error
        THEN
           l_msg_index := 1;
           l_error_message:=l_msg_data;
           WHILE l_msg_count > 0
           LOOP
              l_error_message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE)||l_error_message;
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
           END LOOP;
          RAISE e_error;
        END IF ;
    ---Populate Instnace Details table with objcet(top assembly) instance details
         cse_util_pkg.write_log('Instance Rec after calling get inst dtls :'||l_instance_rec.instance_id);
         i:= 1;
         x_inst_dtls_tbl(i) := l_instance_rec ;

         cse_util_pkg.write_log('Count :' || x_inst_dtls_tbl.COUNT);
        l_relationship_query_rec.object_id :=  p_instance_id ;
        l_relationship_query_rec.relationship_type_code :=  'COMPONENT-OF';

   csi_ii_relationships_pub.get_relationships(
    p_api_version                => l_api_version ,
     p_commit                    => l_commit ,
     p_init_msg_list             => l_init_msg_list ,
     p_validation_level          => l_validation_level ,
     p_relationship_query_rec    => l_relationship_query_rec ,
     p_depth                     => NULL,
     p_time_stamp                => p_transaction_date,
     p_active_relationship_only  => fnd_api.g_true,
     x_relationship_tbl          => l_ii_relationship_tbl ,
     x_return_status             => l_return_status ,
     x_msg_count                 => l_msg_count ,
     x_msg_data                  => l_msg_data);

     IF l_return_status = fnd_api.g_ret_sts_error
     THEN
        l_msg_index := 1;
        l_error_message:=l_msg_data;
        WHILE l_msg_count > 0
        LOOP
           l_error_message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE)||l_error_message;
           l_msg_index := l_msg_index + 1;
           l_msg_count := l_msg_count - 1;
        END LOOP;
       RAISE e_error;
     END IF ;

     IF l_ii_relationship_tbl.COUNT > 0
     THEN
      FOR j IN l_ii_relationship_tbl.FIRST .. l_ii_relationship_tbl.LAST
      LOOP
       i := i+1 ;
       l_instance_rec := NULL ;
       l_instance_rec.instance_id := l_ii_relationship_tbl(j).subject_id ;

        csi_item_instance_pub.get_item_instance_details(
        p_api_version		 =>	l_api_version,
        p_commit 		 =>  l_commit,
        p_init_msg_list     =>	l_init_msg_list,
        p_validation_level  =>  l_Validation_Level,
	p_instance_rec      =>  l_instance_rec,
	p_get_parties       =>  NULL,
	p_party_header_tbl  =>  l_party_header_tbl,
	p_get_accounts      =>  NULL,
	p_account_header_tbl => l_account_header_tbl,
	p_get_org_assignments  => NULL,
	p_org_header_tbl       => l_org_header_tbl,
	p_get_pricing_attribs  => NULL,
	p_pricing_attrib_tbl   => l_pricing_attrib_tbl,
	p_get_ext_attribs      => NULL,
	p_ext_attrib_tbl       => l_ext_attrib_tbl,
	p_ext_attrib_def_tbl   => l_ext_attrib_def_tbl,
	p_get_asset_assignments => NULL,
	p_asset_header_tbl      =>  l_asset_header_tbl,
        p_resolve_id_columns      =>  l_resolve_id_columns,
	p_time_stamp             =>  p_transaction_date ,
        x_return_status       	=>	l_return_status,
        x_msg_count            	=>	l_Msg_Count,
        x_msg_data             	=>	l_Msg_Data );

        IF l_return_status = fnd_api.g_ret_sts_error
        THEN
           l_msg_index := 1;
           l_error_message:=l_msg_data;
           WHILE l_msg_count > 0
           LOOP
              l_error_message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE)||l_error_message;
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
           END LOOP;
          RAISE e_error;
        END IF ;
         ---populate the instance distance table.
         x_inst_dtls_tbl(i) := l_instance_rec ;

      END LOOP ;-- l_ii_relationship_tbl.FIRST .. l_ii_relationship_tbl.LAST
     END IF ; --l_ii_relationship_tbl.COUNT > 0

FOR k IN x_inst_dtls_tbl.FIRST .. x_inst_dtls_tbl.LAST
LOOP
  cse_util_pkg.write_log(' Instance ID : '||  x_inst_dtls_tbl(k).instance_id);
  cse_util_pkg.write_log(' Item ID : '||  x_inst_dtls_tbl(k).inventory_item_id);
  cse_util_pkg.write_log(' Location ID : ' || x_inst_dtls_tbl(k).location_id);
  cse_util_pkg.write_log(' Location Type Code : '||  x_inst_dtls_tbl(k).location_type_code);
END LOOP ;

EXCEPTION
WHEN e_error THEN
    x_return_status := fnd_api.G_RET_STS_ERROR ;
    x_error_message := l_error_message ;
    cse_util_pkg.write_log('In error :'||substr(x_error_message,1,200));
WHEN OTHERS THEN
    x_return_status := fnd_api.G_RET_STS_ERROR ;
    x_error_message := SQLERRM ;
    cse_util_pkg.write_log('In other exception :'||x_error_message);
END get_inst_n_comp_dtls ;



------------------------------------------------------------------------------
  FUNCTION dump_error_stack RETURN varchar2
  IS
    l_msg_count       number;
    l_msg_data        varchar2(2000);
    l_msg_index_out   number;
    x_msg_data        varchar2(4000);
  BEGIN
    x_msg_data := null;
    fnd_msg_pub.count_and_get(
      p_count  => l_msg_count,
      p_data   => l_msg_data);

    FOR l_ind IN 1..l_msg_count
    LOOP
      fnd_msg_pub.get(
        p_msg_index     => l_ind,
        p_encoded       => fnd_api.g_false,
        p_data          => l_msg_data,
        p_msg_index_out => l_msg_index_out);

      x_msg_data := ltrim(x_msg_data||' '||l_msg_data);
      IF length(x_msg_data) > 1999 THEN
        x_msg_data := substr(x_msg_data, 1, 1999);
        exit;
      END IF;
    END LOOP;
    RETURN x_msg_data;
  EXCEPTION
    when others then
      RETURN x_msg_data;
  END dump_error_stack;

  PROCEDURE set_debug IS
    l_file     VARCHAR2(500);
    l_sysdate  DATE := sysdate;
    l_cse      varchar2(3) := 'cse';
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.g_dir  := nvl(fnd_profile.value('cse_debug_log_directory'), '/tmp');
      cse_debug_pub.g_file := NULL;
      l_file := cse_debug_pub.set_debug_file(l_cse||'.'||to_char(l_sysdate,'DDMONYYYY')||'.dbg');
      cse_debug_pub.debug_on;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END set_debug;


------------------------------------------------------------------------------

END CSE_UTIL_PKG;

/
