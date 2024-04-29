--------------------------------------------------------
--  DDL for Package Body RLM_XML_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_XML_API" as
/* $Header: RLMXMLPB.pls 120.8 2006/12/22 19:22:24 rlanka noship $*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
PROCEDURE ValidateScheduleType(x_SchedType IN VARCHAR2,
			       x_RetCode OUT NOCOPY NUMBER) IS
 --
 l_Timer    NUMBER;
 --
BEGIN
  --
  SELECT hsecs INTO l_Timer FROM v$timer;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.start_debug(x_SchedType || '-' || l_Timer);
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.ValidateScheduleType');
     rlm_core_sv.dlog(C_DEBUG, 'x_SchedType', x_SchedType);
  END IF;
  --
  IF (UPPER(x_SchedType) <> k_DEMAND) THEN
    --
    x_RetCode := k_ERROR;
    --
  ELSE
    --
    x_RetCode := k_SUCCESS;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'x_RetCode', x_RetCode);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
END ValidateScheduleType;


PROCEDURE SetSSSILineDetails(x_LineType IN VARCHAR2,
		         x_ReqdDt   IN     DATE,
		         x_RecdDt   IN     DATE,
		         x_ShipDt   IN     DATE,
                         x_ItemQty  IN     NUMBER,
		         x_RecdQty  IN     NUMBER,
		         x_ShipQty  IN     NUMBER,
			 x_DateType IN     VARCHAR2,
			 x_ItemUOM  IN     VARCHAR2,
			 x_RecdUOM  IN     VARCHAR2,
			 x_ShipUOM  IN     VARCHAR2,
		         x_StartDt  OUT NOCOPY    DATE,
		         x_Qty      OUT NOCOPY    NUMBER,
			 x_Subtype  OUT NOCOPY    VARCHAR2,
			 x_DateCode OUT NOCOPY    VARCHAR2,
			 x_QtyUOM   OUT NOCOPY    VARCHAR2,
			 x_ErrCode  IN OUT NOCOPY NUMBER,
			 x_ErrMsg   IN OUT NOCOPY VARCHAR2) IS

  --
  e_IncompleteData	EXCEPTION;
  e_UnknownData		EXCEPTION;
  --

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.SetSSSILineDetails');
     rlm_core_sv.dlog(C_DEBUG, 'x_LineType', x_LineType);
     rlm_core_sv.dlog(C_DEBUG, 'x_DateType', x_DateType);
     rlm_core_sv.dlog(C_DEBUG, 'x_ReqdDt',  to_char(x_ReqdDt, 'DD-MON-YYYY HH24:MI:SS'));
     rlm_core_sv.dlog(C_DEBUG, 'x_RecdDt',  to_char(x_RecdDt, 'DD-MON-YYYY HH24:MI:SS'));
     rlm_core_sv.dlog(C_DEBUG, 'x_ShipDt',  to_char(x_ShipDt, 'DD-MON-YYYY HH24:MI:SS'));
     rlm_core_sv.dlog(C_DEBUG, 'x_RecdQty and UOM', x_RecdQty || '-' || x_RecdUOM);
     rlm_core_sv.dlog(C_DEBUG, 'x_ShipQty and UOM', x_ShipQty || '-' || x_ShipUOM);
     rlm_core_sv.dlog(C_DEBUG, 'x_ItemQty and UOM', x_ItemQty || '-' || x_ItemUOM);
  END IF;
  --
  IF (UPPER(x_LineType) IN ('0', '1', '2') OR x_LineType is NULL) THEN
   --
   x_Subtype  := '1';
   x_DateCode := NVL(x_DateType, k_DELIVER);
   x_StartDt  := x_ReqdDt;
   x_Qty      := x_ItemQty;
   x_QtyUOM   := x_ItemUOM;
   --
  ELSIF (UPPER(x_LineType) = '4') THEN
   --
   IF (x_RecdDt IS NOT NULL) THEN
    --
    x_Subtype  := k_RECEIPT;
    x_DateCode := k_RECEIVED;
    x_StartDt  := x_RecdDt;
    --
    IF (x_RecdQty IS NOT NULL) THEN
     --
     x_Qty    := x_RecdQty;
     x_QtyUOM := x_RecdUOM;
     --
    END IF;
    --
   ELSIF (x_ShipDt IS NOT NULL) THEN
    --
    x_Subtype  := k_SHIPMENT;
    x_DateCode := k_SHIPPED;
    x_StartDt  := x_ShipDt;
    --
    IF (x_ShipQty IS NOT NULL) THEN
      --
      x_Qty    := x_ShipQty;
      x_QtyUOM := x_ShipUOM;
      --
    END IF;
    --
   ELSE
    --
    RAISE e_IncompleteData;
    --
   END IF;
   --
  ELSIF (x_LineType = '3') THEN
   --
   x_Subtype  := k_FINISHED;
   x_DateCode := k_FROMTO;
   x_StartDt  := x_ReqdDt;
   x_Qty      := x_ItemQty;
   x_QtyUOM   := x_ItemUOM;
   --
  ELSIF (x_LineType = '5') THEN
   --
   x_Subtype  := k_AHDBHND;
   x_DateCode := k_ASOF;
   x_StartDt  := x_ReqdDt;
   x_Qty      := x_ItemQty;
   x_QtyUOM   := x_ItemUOM;
   --
  ELSE
   --
   RAISE e_UnknownData;
   --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  EXCEPTION
   WHEN e_IncompleteData THEN
      x_ErrCode := x_ErrCode + 1;
      x_ErrMsg := x_ErrMsg || ' Required data not present on schedule';
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Required Data not on schedule');
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

  WHEN e_UnknownData THEN
      x_ErrCode := x_ErrCode + 1;
      x_ErrMsg := x_ErrMsg || ' Unknown linetype ''' || x_LineType || '''';
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Unknown line type = ' || x_LineType);
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

  WHEN OTHERS THEN
     x_ErrCode := x_ErrCode + 1;
     x_ErrMsg := x_ErrMsg || ' Unknown error in SetSSSILineDetails';
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Unknown error in SetSSSILineDetails');
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     raise ecx_utils.PROGRAM_EXIT;

END SetSSSILineDetails;


PROCEDURE SetSPSILineDetails(x_LineType IN  VARCHAR2,
			 x_FromDt    IN     DATE,
			 x_ToDt      IN     DATE,
		         x_RecdDt    IN     DATE,
		         x_ShipDt    IN     DATE,
                         x_ItemQty   IN     NUMBER,
		         x_RecdQty   IN     NUMBER,
		         x_ShipQty   IN     NUMBER,
			 x_DateType  IN     VARCHAR2,
			 x_ItemUOM   IN     VARCHAR2,
			 x_RecdUOM   IN     VARCHAR2,
			 x_ShipUOM   IN     VARCHAR2,
			 x_BktType   IN     VARCHAR2,
		         x_StartDt   OUT NOCOPY    DATE,
			 x_EndDt     OUT NOCOPY    DATE,
			 x_Subtype   OUT NOCOPY    VARCHAR2,
		         x_Qty       OUT NOCOPY    NUMBER,
			 x_DateCode  OUT NOCOPY    VARCHAR2,
			 x_QtyUOM    OUT NOCOPY    VARCHAR2,
			 x_ErrCode   IN OUT NOCOPY NUMBER,
			 x_ErrMsg    IN OUT NOCOPY VARCHAR2) IS
  --
  e_UnknownData		EXCEPTION;
  e_IncompleteData	EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.SetSPSILineDetails');
     rlm_core_sv.dlog(C_DEBUG, 'x_LineType', x_LineType);
     rlm_core_sv.dlog(C_DEBUG, 'x_DateType', x_DateType);
     rlm_core_sv.dlog(C_DEBUG, 'x_BktType',  x_BktType);
     rlm_core_sv.dlog(C_DEBUG, 'x_FromDt',  to_char(x_FromDt, 'DD-MON-YYYY HH24:MI:SS'));
     rlm_core_sv.dlog(C_DEBUG, 'x_ToDt',    to_char(x_ToDt, 'DD-MON-YYYY HH24:MI:SS'));
     rlm_core_sv.dlog(C_DEBUG, 'x_RecdDt',  to_char(x_RecdDt, 'DD-MON-YYYY HH24:MI:SS'));
     rlm_core_sv.dlog(C_DEBUG, 'x_ShipDt',  to_char(x_ShipDt, 'DD-MON-YYYY HH24:MI:SS'));
     rlm_core_sv.dlog(C_DEBUG, 'x_RecdQty and UOM', x_RecdQty || '-' || x_RecdUOM);
     rlm_core_sv.dlog(C_DEBUG, 'x_ShipQty and UOM', x_ShipQty || '-' || x_ShipUOM);
     rlm_core_sv.dlog(C_DEBUG, 'x_ItemQty and UOM', x_ItemQty || '-' || x_ItemUOM);
  END IF;

  --
  IF (UPPER(x_LineType) IN ('0', '1', '2') OR x_LineType IS NULL) THEN
    --
    x_Subtype := NVL(x_BktType, '1');
    x_DateCode := NVL(x_DateType, k_DELIVER);
    x_StartDt  := NVL(x_FromDt, SYSDATE);
    x_EndDt    := x_ToDt;
    x_Qty      := x_ItemQty;
    x_QtyUOM   := x_ItemUOM;
    --
  ELSIF (UPPER(x_LineType) = '4') THEN
    --
    IF (x_RecdDt is NOT NULL) THEN
     --
     x_Subtype  := k_RECEIPT;
     x_DateCode := k_RECEIVED;
     x_StartDt  := x_RecdDt;
     --
     IF (x_RecdQty IS NOT NULL) THEN
      --
      x_Qty    := x_RecdQty;
      x_QtyUOM := x_RecdUOM;
      --
     END IF;
     --
    ELSIF (x_ShipDt is NOT NULL) THEN
     --
     x_Subtype  := k_SHIPMENT;
     x_DateCode := k_SHIPPED;
     x_StartDt  := x_ShipDt;
     --
     IF (x_ShipQty IS NOT NULL) THEN
      --
      x_Qty    := x_ShipQty;
      x_QtyUOM := x_ShipUOM;
      --
     END IF;
     --
    ELSE
     --
     RAISE e_IncompleteData;
     --
    END IF;
    --
  ELSIF (x_LineType = '3') THEN
    --
    x_SubType := NVL(x_BktType, k_FINISHED);
    x_DateCode := k_FROMTO;
    x_StartDt  := x_FromDt;
    x_EndDt    := x_ToDt;
    x_Qty      := x_ItemQty;
    x_QtyUOM   := x_ItemUOM;
    --
  ELSIF (x_LineType = '5') THEN
    --
    x_SubType := NVL(x_BktType, k_AHDBHND);
    x_DateCode := k_ASOF;
    x_StartDt  := x_FromDt;
    x_EndDt    := x_ToDt;
    x_Qty      := x_ItemQty;
    x_QtyUOM   := x_ItemUOM;
    --
  ELSE
    --
    RAISE e_UnknownData;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  EXCEPTION
   WHEN e_IncompleteData THEN
      x_ErrCode := x_ErrCode + 1;
      x_ErrMsg := x_ErrMsg || ' Required data not on schedule';
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Required Data not present on schedule');
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

  WHEN e_UnknownData THEN
      x_ErrCode := x_ErrCode + 1;
      x_ErrMsg := x_ErrMsg || ' Unknown linetype ''' || x_LineType || '''';
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Unknown linetype = '|| x_LineType);
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

  WHEN OTHERS THEN
     x_ErrCode := x_ErrCode + 1;
     x_ErrMsg := x_ErrMsg || ' Unknown error in SetSPSILineDetails';
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Unknown error in SetSPSILineDetails');
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     raise ecx_utils.PROGRAM_EXIT;

END SetSPSILineDetails;



PROCEDURE SetScheduleItemNum(x_HeaderID IN NUMBER,
			     x_ErrCode  IN OUT NOCOPY NUMBER,
			     x_ErrMsg   IN OUT NOCOPY VARCHAR2) IS
  --
  x_GroupRef 		t_Cursor_ref;
  x_GroupRec 		t_ItemAttribsRec;
  x_SchedItemNum	NUMBER := 1;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.SetScheduleItemNum');
  END IF;
  --
  g_SchedItemTab.DELETE;
  --
  InitializeSchedItemTab(x_HeaderID);
  --
  PrintSchedItemTab;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, '# of rows in g_SchedItemTab ', g_SchedItemTab.COUNT);
  END IF;
  --
  FOR i IN 1..g_SchedItemTab.COUNT LOOP
    --
    UPDATE rlm_interface_lines_all
    SET schedule_item_num = x_SchedItemNum
    WHERE header_id = x_HeaderID AND
	  NVL(cust_ship_from_org_ext, k_VNULL) = NVL(g_SchedItemTab(i).ship_from_ext, k_VNULL)  AND
	  NVL(cust_ship_to_ext, k_VNULL)       = NVL(g_SchedItemTab(i).ship_to_ext, k_VNULL)    AND
	  NVL(cust_bill_to_ext, k_VNULL)       = NVL(g_SchedItemTab(i).bill_to_ext, k_VNULL)    AND
	  NVL(customer_item_ext, k_VNULL)      = NVL(g_SchedItemTab(i).cust_item_ext, k_VNULL)  AND
	  NVL(item_description_ext, k_VNULL)   = NVL(g_SchedItemTab(i).item_desc_ext, k_VNULL)  AND
	  NVL(customer_dock_code, k_VNULL)     = NVL(g_SchedItemTab(i).cust_dock_code, k_VNULL) AND
	  NVL(hazard_code_ext, k_VNULL)	       = NVL(g_SchedItemTab(i).hazrd_code_ext, k_VNULL) AND
	  NVL(customer_item_revision, k_VNULL) = NVL(g_SchedItemTab(i).cust_item_rev, k_VNULL)  AND
	  NVL(item_note_text, k_VNULL)	       = NVL(g_SchedItemTab(i).item_note_text, k_VNULL) AND
	  NVL(cust_po_number, k_VNULL)	       = NVL(g_SchedItemTab(i).cust_po_num, k_VNULL)    AND
	  NVL(cust_po_line_num, k_VNULL)       = NVL(g_SchedItemTab(i).cust_po_linnum, k_VNULL) AND
	  NVL(cust_po_release_num, k_VNULL)    = NVL(g_SchedItemTab(i).cust_po_relnum, k_VNULL) AND
          NVL(cust_po_date, k_DNULL)	       = NVL(g_SchedItemTab(i).cust_po_date, k_DNULL)   AND
	  NVL(commodity_ext, k_VNULL)	       = NVL(g_SchedItemTab(i).commodity_ext, k_VNULL)  AND
	  NVL(supplier_item_ext, k_VNULL)      = NVL(g_SchedItemTab(i).sup_item_ext, k_VNULL);

    --4316744: Timezone uptake in RLM.
    UPDATE rlm_interface_headers_all
    SET sched_horizon_start_date = TRUNC(sched_horizon_start_date),
        sched_horizon_end_date = TRUNC(sched_horizon_end_date) + 0.99999
    WHERE header_id = x_HeaderID;
    --
    x_SchedItemNum := x_SchedItemNum + 1;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, '# of rows updated', SQL%ROWCOUNT);
    END IF;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      x_ErrCode := x_ErrCode + 1;
      x_ErrMsg  := x_ErrMsg || ' Unknown error in RLM_XML_API.SetScheduleItemNum';
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Unknown error in SetScheduleItemNum');
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
END SetScheduleItemNum;


PROCEDURE PrintSchedItemTab IS
--
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.PrintSchedItemTab');
  END IF;
  --
  FOR i in 1..g_SchedItemTab.COUNT LOOP
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, '--------------------------------------------');
       rlm_core_sv.dlog(C_DEBUG, 'Index', i);
       rlm_core_sv.dlog(C_DEBUG,'Ship From', g_SchedItemTab(i).ship_from_ext);
       rlm_core_sv.dlog(C_DEBUG,'Ship To', g_SchedItemTab(i).ship_to_ext);
       rlm_core_sv.dlog(C_DEBUG,'Bill To', g_SchedItemTab(i).bill_to_ext);
       rlm_core_sv.dlog(C_DEBUG,'Cust Item', g_SchedItemTab(i).cust_item_ext);
       rlm_core_sv.dlog(C_DEBUG,'Item Desc', g_SchedItemTab(i).item_desc_ext);
       rlm_core_sv.dlog(C_DEBUG,'Dock Code', g_SchedItemTab(i).cust_dock_code);
       rlm_core_sv.dlog(C_DEBUG,'Haz Code', g_SchedItemTab(i).hazrd_code_ext);
       rlm_core_sv.dlog(C_DEBUG,'Item Rev', g_SchedItemTab(i).cust_item_rev);
       rlm_core_sv.dlog(C_DEBUG,'Item Note', g_SchedItemTab(i).item_note_text);
       rlm_core_sv.dlog(C_DEBUG,'PO Num', g_SchedItemTab(i).cust_po_num);
       rlm_core_sv.dlog(C_DEBUG,'PO Line Num', g_SchedItemTab(i).cust_po_linnum);
       rlm_core_sv.dlog(C_DEBUG,'PO Rel Num', g_SchedItemTab(i).cust_po_relnum);
       rlm_core_sv.dlog(C_DEBUG,'PO Date', g_SchedItemTab(i).cust_po_date);
       rlm_core_sv.dlog(C_DEBUG,'Sup Item', g_SchedItemTab(i).sup_item_ext);
    END IF;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
END PrintSchedItemTab;


PROCEDURE InitializeSchedItemTab (x_HeaderID IN NUMBER) IS
  --
  CURSOR c_ItemAttribs IS
    SELECT cust_ship_from_org_ext,
	   cust_ship_to_ext,
           cust_bill_to_ext,
	   customer_item_ext,
	   item_description_ext,
	   customer_dock_code,
	   hazard_code_ext,
	   customer_item_revision,
	   item_note_text,
	   cust_po_number,
	   cust_po_line_num,
	   cust_po_release_num,
	   cust_po_date,
	   commodity_ext,
	   supplier_item_ext
   FROM rlm_interface_lines_all
   WHERE header_id = x_HeaderID;
   --
   c_ItemAttribsRec	t_ItemAttribsRec;
   --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.InitializeSchedItemTab');
  END IF;
  --
  OPEN c_ItemAttribs;
  FETCH c_ItemAttribs INTO c_ItemAttribsRec;
  --
  WHILE c_ItemAttribs%FOUND LOOP
    --
    IF NOT IsDuplicate(c_ItemAttribsRec) THEN
      --
      InsertItemAttribRec(c_ItemAttribsRec);
      --
    END IF;
    --
    FETCH c_ItemAttribs INTO c_ItemAttribsRec;
    --
  END LOOP;
  --
  CLOSE c_ItemAttribs; --bug 4570658

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
END InitializeSchedItemTab;



FUNCTION IsDuplicate(x_ItemAttribsRec IN t_ItemAttribsRec) RETURN BOOLEAN IS
  --
  b_Match	BOOLEAN;
  e_NoMatch     EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.IsDuplicate');
  END IF;
  --
/*
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Printing attribs rec');
     rlm_core_sv.dlog(C_DEBUG,'Ship From', x_ItemAttribsRec.ship_from_ext);
     rlm_core_sv.dlog(C_DEBUG,'Ship To', x_ItemAttribsRec.ship_to_ext);
     rlm_core_sv.dlog(C_DEBUG,'Bill To', x_ItemAttribsRec.bill_to_ext);
     rlm_core_sv.dlog(C_DEBUG,'Cust Item', x_ItemAttribsRec.cust_item_ext);
     rlm_core_sv.dlog(C_DEBUG,'Item Desc', x_ItemAttribsRec.item_desc_ext);
     rlm_core_sv.dlog(C_DEBUG,'Dock Code', x_ItemAttribsRec.cust_dock_code);
     rlm_core_sv.dlog(C_DEBUG,'Haz Code', x_ItemAttribsRec.hazrd_code_ext);
     rlm_core_sv.dlog(C_DEBUG,'Item Rev', x_ItemAttribsRec.cust_item_rev);
     rlm_core_sv.dlog(C_DEBUG,'Item Note', x_ItemAttribsRec.item_note_text);
     rlm_core_sv.dlog(C_DEBUG,'PO Num', x_ItemAttribsRec.cust_po_num);
     rlm_core_sv.dlog(C_DEBUG,'PO Line Num', x_ItemAttribsRec.cust_po_linnum);
     rlm_core_sv.dlog(C_DEBUG,'PO Rel Num', x_ItemAttribsRec.cust_po_relnum);
     rlm_core_sv.dlog(C_DEBUG,'PO Date', x_ItemAttribsRec.cust_po_date);
     rlm_core_sv.dlog(C_DEBUG,'Sup Item', x_ItemAttribsRec.sup_item_ext);
  END IF;
*/

  b_Match := FALSE;
  --
  IF (g_SchedItemTab.COUNT = 0) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, '# of rows in g_SchedItemTab', g_SchedItemTab.COUNT);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    RETURN (FALSE);
    --
  END IF;
  --
  FOR i IN 1..g_SchedItemTab.COUNT LOOP
    --
    BEGIN
      --
      IF (NVL(g_SchedItemTab(i).ship_from_ext, k_VNULL) <> NVL(x_ItemAttribsRec.ship_from_ext, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','SF did not match with entry ' || i);
        END IF;
	RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).ship_to_ext, k_VNULL) <> NVL(x_ItemAttribsRec.ship_to_ext, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','ST did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).bill_to_ext, k_VNULL) <> NVL(x_ItemAttribsRec.bill_to_ext, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','BT did not match');
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).cust_item_ext, k_VNULL) <> NVL(x_ItemAttribsRec.cust_item_ext, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','CI did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).item_desc_ext, k_VNULL) <> NVL(x_ItemAttribsRec.item_desc_ext, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','Desc did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).cust_dock_code, k_VNULL) <> NVL(x_ItemAttribsRec.cust_dock_code, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','Dock did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).hazrd_code_ext, k_VNULL) <> NVL(x_ItemAttribsRec.hazrd_code_ext, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','Haz did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).cust_item_rev, k_VNULL) <> NVL(x_ItemAttribsRec.cust_item_rev, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','Item rev did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).item_note_text, k_VNULL) <> NVL(x_ItemAttribsRec.item_note_text, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','Note did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).cust_po_num, k_VNULL) <> NVL(x_ItemAttribsRec.cust_po_num, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','PO Num did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).cust_po_linnum, k_VNULL) <> NVL(x_ItemAttribsRec.cust_po_linnum, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','POLnum did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).cust_po_relnum, k_VNULL) <> NVL(x_ItemAttribsRec.cust_po_relnum, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','PORel did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).commodity_ext, k_VNULL) <> NVL(x_ItemAttribsRec.commodity_ext, k_VNULL)) THEN
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','commodity did not match with entry ' || i);
         END IF;
         RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).sup_item_ext, k_VNULL) <> NVL(x_ItemAttribsRec.sup_item_ext, k_VNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','Sup item did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      IF (NVL(g_SchedItemTab(i).cust_po_date, k_DNULL) <> NVL(x_ItemAttribsRec.cust_po_date, k_DNULL)) THEN
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','PO Date did not match with entry ' || i);
        END IF;
        RAISE e_NoMatch;
      END IF;

      b_Match := TRUE;
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'RLM_MSG','All attributes matched with entry ' || i);
      END IF;
      EXIT;

      EXCEPTION
        --
        WHEN e_NoMatch THEN
          NULL;
      --
    END;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'b_Match', b_Match);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  RETURN (b_Match);
  --
END IsDuplicate;


PROCEDURE InsertItemAttribRec(x_ItemAttribsRec IN t_ItemAttribsRec) IS
  --
  v_Index	NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.InsertItemAttribs');
  END IF;
  --
  v_Index := g_SchedItemTab.COUNT;
  --
  g_SchedItemTab(v_Index+1).ship_from_ext  := x_ItemAttribsRec.ship_from_ext;
  g_SchedItemTab(v_Index+1).ship_to_ext    := x_ItemAttribsRec.ship_to_ext;
  g_SchedItemTab(v_Index+1).bill_to_ext    := x_ItemAttribsRec.bill_to_ext;
  g_SchedItemTab(v_Index+1).cust_item_ext  := x_ItemAttribsRec.cust_item_ext;
  g_SchedItemTab(v_Index+1).item_desc_ext  := x_ItemAttribsRec.item_desc_ext;
  g_SchedItemTab(v_Index+1).cust_dock_code := x_ItemAttribsRec.cust_dock_code;
  g_SchedItemTab(v_Index+1).hazrd_code_ext := x_ItemAttribsRec.hazrd_code_ext;
  g_SchedItemTab(v_Index+1).cust_item_rev  := x_ItemAttribsRec.cust_item_rev;
  g_SchedItemTab(v_Index+1).item_note_text := x_ItemAttribsRec.item_note_text;
  g_SchedItemTab(v_Index+1).cust_po_num    := x_ItemAttribsRec.cust_po_num;
  g_SchedItemTab(v_Index+1).cust_po_linnum := x_ItemAttribsRec.cust_po_linnum;
  g_SchedItemTab(v_Index+1).cust_po_relnum := x_ItemAttribsRec.cust_po_relnum;
  g_SchedItemTab(v_Index+1).cust_po_date   := x_ItemAttribsRec.cust_po_date;
  g_SchedItemTab(v_Index+1).commodity_ext  := x_ItemAttribsRec.commodity_ext;
  g_SchedItemTab(v_Index+1).sup_item_ext   := x_ItemAttribsRec.sup_item_ext;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
END InsertItemAttribRec;


PROCEDURE UpdateLineNumbers(x_HeaderID IN     NUMBER,
			    x_ErrCode  IN OUT NOCOPY NUMBER,
			    x_ErrMsg   IN OUT NOCOPY VARCHAR2) IS
  --
  v_linenumber NUMBER := 1;
  v_lineid     NUMBER;
  --
  CURSOR c_Lines IS
    SELECT line_id
    FROM rlm_interface_lines_all
    WHERE header_id = x_HeaderID
    ORDER BY schedule_item_num;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.UpdateLineNumbers');
     rlm_core_sv.dlog(C_DEBUG, 'x_HeaderID', x_HeaderID);
  END IF;
  --
  OPEN c_Lines;
  FETCH c_Lines INTO v_lineid;
  --
  WHILE c_Lines%FOUND LOOP
    --
    UPDATE rlm_interface_lines_all
    SET line_number = v_linenumber
    WHERE line_id = v_lineid;
    --
    v_linenumber := v_linenumber + 1;
    --
    FETCH c_Lines INTO v_lineid;
    --
  END LOOP;
  CLOSE c_lines; --bug 4570658
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
     rlm_core_sv.stop_debug;
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
     --
     x_ErrCode := x_ErrCode + 1;
     x_ErrMsg := x_ErrMsg || ' Unknown error in UpdateLineNumbers';
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'RLM_ERROR', 'Unknown Error in UpdateLineNumbers');
        rlm_core_sv.dpop(C_SDEBUG);
        rlm_core_sv.stop_debug;
     END IF;
     --
END UpdateLineNumbers;


PROCEDURE FlexBktAssignment(x_header_id IN NUMBER,
			    x_ErrCode   IN OUT NOCOPY NUMBER,
			    x_ErrMsg    IN OUT NOCOPY VARCHAR2)
IS
  --
  v_lineID           NUMBER;
  v_line_ID          NUMBER;
  v_flexbkt          VARCHAR2(30);
  v_flexbktcode      VARCHAR2(30);
  v_start_date	     DATE;
  v_end_date	     DATE;
  --
  CURSOR c_Line
   IS
     SELECT line_id, flex_bkt_code
     FROM rlm_interface_lines_all
     WHERE header_id = x_header_id
     AND   flex_bkt_flag is null;
  --
  CURSOR c_Bkt
   IS
     SELECT line_id, flex_bkt_code, start_date_time, end_date_time
     FROM rlm_interface_lines_all
     WHERE header_id = x_header_id
     AND   flex_bkt_flag = 'Y';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.FlexBktAssignment');
     rlm_core_sv.dlog(C_DEBUG, 'x_HeaderID', x_header_id);
  END IF;
  --
  OPEN c_Line;
  FETCH c_Line INTO v_lineID, v_flexbkt;
  --
  WHILE c_Line%FOUND LOOP
    --
    OPEN c_Bkt;
    FETCH c_Bkt INTO v_line_ID, v_flexbktcode, v_start_date, v_end_date;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'BKTYPE', v_flexbkt);
    END IF;
    --
    WHILE c_Bkt%FOUND LOOP
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'FLEXBKTID', v_flexbktcode);
      END IF;
      --
      IF v_flexbktcode = v_flexbkt THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Match between FLEXBKTID and BKTYPE for line', v_lineID);
        END IF;
        --
        UPDATE rlm_interface_lines_all
        SET start_date_time = v_start_date,
            end_date_time   = v_end_date
        WHERE line_id = v_lineID;
        --
        IF v_flexbkt NOT IN ('1', '2', '4', '5', k_RECEIPT, k_SHIPMENT) THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'v_flexbkt', v_flexbkt);
             rlm_core_sv.dlog(C_DEBUG, 'Replacing ' || v_flexbkt || ' with FLEXIBLE');
          END IF;
          --
          UPDATE rlm_interface_lines_all
          SET item_detail_subtype = '3'
          WHERE line_id = v_lineID;
          --
        END IF;
        --
        EXIT;
        --
      END IF;
      --
      FETCH c_Bkt INTO v_line_ID, v_flexbktcode, v_start_date, v_end_date;
      --
    END LOOP;
    --
    CLOSE c_Bkt;
    --
    FETCH c_Line INTO v_lineID, v_flexbkt;
    --
  END LOOP;
  --
  CLOSE c_Line;
  --
  DELETE FROM rlm_interface_lines_all
  WHERE header_id = x_header_id
  AND  flex_bkt_flag = 'Y';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    x_ErrCode := x_ErrCode + 1;
    x_ErrMsg  := x_ErrMsg || ' Unknown error in RLM_XML_API.FlexBktAssignment';
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'RLM_ERROR', 'Unknown Error in FlexBktAssignment');
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;

END FlexBktAssignment;


--MOAC changes: Added the following procedure

Procedure GetDefaultOU(x_default_ou IN OUT NOCOPY NUMBER,
                                          x_ErrCode  IN OUT NOCOPY NUMBER,
                                          x_ErrMsg   IN OUT NOCOPY VARCHAR2) IS
 --
 l_default_org_id NUMBER;
--
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.GetDefaultOU');
  END IF;
   --
  FND_PROFILE.GET('DEFAULT_ORG_ID', l_default_org_id);
  --
 IF l_default_org_id IS NULL THEN
  X_ErrCode := x_ErrCode+1;
  X_ErrMsg := 'Cannot process schedule because the Default Operating Unit has not been defined';
  X_default_ou := NULL;
ELSE
  x_default_ou := l_default_org_id;
END IF;
--
IF (l_debug <> -1) THEN
  rlm_core_sv.dlog(C_DEBUG, 'Default Org ID', x_default_ou);
  rlm_core_sv.dpop(C_SDEBUG);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    X_ErrCode := x_ErrCode + 1;
    X_ErrMsg := 'Unknown error when determing Default Operating Unit';
    --
    IF (l_debug <> -1) THEN
   Rlm_core_sv.dlog(C_DEBUG, 'RLM_ERROR', 'Unspecified error when Deriving OU');
      Rlm_core_sv.dpop(C_SDEBUG);
    END IF;
END GetDefaultOU;



FUNCTION DeriveExtProcessID(p_msgStd      IN VARCHAR2,
                            p_txnType     IN VARCHAR2,
                            p_txnSubtype  IN VARCHAR2) RETURN NUMBER IS
 --
 v_StdID          NUMBER;
 v_ExtProcessID   NUMBER;
 v_Direction      VARCHAR2(20) := 'IN';
 v_stdType        VARCHAR2(30) := 'XML';
 --
BEGIN
 --
 IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.DeriveExtProcessID');
   rlm_core_sv.dlog(C_DEBUG, 'Msg Std', p_msgStd);
   rlm_core_sv.dlog(C_DEBUG, 'Txn Type', p_txnType);
   rlm_core_sv.dlog(C_DEBUG, 'Txn Subtype', p_txnSubtype);
   rlm_core_sv.dlog(C_DEBUG, 'Direction', v_Direction);
   rlm_core_sv.dlog(C_DEBUG, 'Std Type', v_stdType);
 END IF;
 --
 SELECT standard_id
 INTO v_StdID
 FROM ecx_standards_b
 WHERE standard_code = p_msgStd
 AND   standard_type = v_stdType;
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.dlog(C_DEBUG, 'Standard ID', v_StdID);
 END IF;
 --
 SELECT ext_process_id
 INTO v_ExtProcessID
 FROM ecx_ext_processes
 WHERE standard_id = v_StdID
 AND ext_type = p_txnType
 AND ext_subtype = p_txnSubtype
 AND direction = v_Direction;
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.dlog(C_DEBUG, 'Ext Process ID', v_ExtProcessID);
  rlm_core_sv.dpop(C_SDEBUG);
 END IF;
 --
 RETURN v_ExtProcessID;
 --
 EXCEPTION
  --
  WHEN OTHERS THEN
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Unexpected error', SUBSTRB(SQLERRM, 1, 200));
    rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
   RAISE;
   --
END DeriveExtProcessID;



PROCEDURE DeriveCustomerId(x_internalcontrolNum IN NUMBER,
                           x_SourceTPLocCode OUT NOCOPY VARCHAR2,
                           x_CustomerId OUT NOCOPY NUMBER,
                           x_ErrCode  IN OUT NOCOPY NUMBER,
                           x_ErrMsg   IN OUT NOCOPY VARCHAR2)  IS
 --
 v_msgType         VARCHAR2(100);
 v_msgStd          VARCHAR2(100);
 v_TxnType         VARCHAR2(100);
 v_TxnsubType      VARCHAR2(100);
 v_DocNum          VARCHAR2(256);
 v_PartyId         VARCHAR2(256);
 v_SourceTPLocCode VARCHAR2(256);
 v_protocolType    VARCHAR2(500);
 v_protocolAdd     VARCHAR2(2000);
 v_userName        VARCHAR2(500);
 v_Passwd          VARCHAR2(500);
 v_attrib1         VARCHAR2(500);
 v_attrib2         VARCHAR2(500);
 v_attrib3         VARCHAR2(500);
 v_attrib4         VARCHAR2(500);
 v_attrib5         VARCHAR2(500);
 v_ErrCode         VARCHAR2(100);
 v_ErrMsg          VARCHAR2(100);
 --
 v_tpheaderID      NUMBER;
 v_CustacctSiteId  NUMBER;
 v_CustAccountId   NUMBER;
 v_Party_Id        NUMBER;
 v_PartySiteId     NUMBER;
 v_ExtProcessID    NUMBER;
 --
BEGIN
 --
 IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(C_SDEBUG, 'RLM_XML_API.DeriveCustomerId');
   rlm_core_sv.dlog(C_DEBUG, 'Internal Control Num', x_internalControlNum);
 END IF;
 --
 ECX_TRADING_PARTNER_PVT.getEnvelopeInformation
     (
       i_internal_control_number => x_internalControlNum,
       i_message_type            => v_msgtype,
       i_message_standard        => v_msgStd,
       i_transaction_type        => v_Txntype,
       i_transaction_subtype     => v_txnSubtype,
       i_document_number        => v_docnum,
       i_party_id                => v_partyId,
       i_party_site_id          => v_SourceTPLocCode,
       i_protocol_type          => v_protocolType,
       i_protocol_address       => v_protocolAdd,
       i_username               => v_Username,
       i_password               => v_Passwd,
       i_attribute1             => v_attrib1,
       i_attribute2             => v_attrib2,
       i_attribute3             => v_attrib3,
       i_attribute4             => v_attrib4,
       i_attribute5             => v_attrib5,
       retcode                  => v_ErrCode,
       retmsg                   => v_ErrMsg
     );
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.dlog(C_DEBUG, 'Party ID', v_partyId);
  rlm_core_sv.dlog(C_DEBUG, 'Source TP Location Code', v_SourceTPLocCode);
  rlm_core_sv.dlog(C_DEBUG, 'Protocal Type', v_protocolType);
  rlm_core_sv.dlog(C_DEBUG, 'Protocol Add', v_ProtocolAdd);
  rlm_core_sv.dlog(C_DEBUG, 'User name', v_Username);
  rlm_core_Sv.dlog(C_DEBUG, 'Password', v_Passwd);
  rlm_core_sv.dlog(C_DEBUG, 'Attrib1', v_attrib1);
  rlm_core_sv.dlog(C_DEBUG, 'Attrib2', v_attrib2);
  rlm_core_sv.dlog(C_DEBUG, 'Attrib3', v_attrib3);
  rlm_core_sv.dlog(C_DEBUG, 'Attrib4', v_attrib4);
  rlm_core_sv.dlog(C_DEBUG, 'Attrib5', v_attrib5);
  rlm_core_sv.dlog(C_DEBUG, 'Error Code', v_ErrCode);
  rlm_core_sv.dlog(C_DEBUG, 'Error Msg', v_Errmsg);
  rlm_core_sv.dlog(C_DEBUG, 'Txn Type', v_Txntype);
  rlm_core_sv.dlog(C_DEBUG, 'Txn Subtype', v_txnSubtype);
  rlm_core_sv.dlog(C_DEBUG, 'Msg Type', v_msgtype);
  rlm_core_sv.dlog(C_DEBUG, 'Doc Number', v_docnum);
  rlm_core_sv.dlog(C_DEBUG, 'Msg Std', v_msgStd);
 END IF;
 --
 x_SourceTPLocCode := v_SourceTPLocCode;
 v_ExtProcessID := DeriveExtProcessID(v_msgStd, v_Txntype, v_txnSubtype);
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.dlog(C_DEBUG, 'Ext Process ID', v_ExtProcessID);
 END IF;
 --
 SELECT party_site_id, party_id
 INTO v_PartySiteID, v_party_id
 FROM ecx_tp_headers
 WHERE tp_header_id IN (SELECT DISTINCT tp_header_id
                        FROM ecx_tp_details
                        WHERE source_tp_location_code = v_SourceTPLocCode
                        AND   ext_process_id          = v_ExtProcessID);
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.dlog(C_DEBUG, 'Party Site ID', v_partySiteID);
  rlm_core_sv.dlog(C_DEBUG, 'Party ID', v_party_ID);
 END IF;
 --
 SELECT cust_acct_site_id, cust_account_id
 INTO v_CustacctSiteId, v_CustAccountId
 FROM hz_cust_acct_sites_all
 WHERE party_site_id = v_PartySiteID
 AND ece_tp_location_code = v_SourceTPLocCode;
 --
 x_CustomerId := v_CustAccountId;
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.dlog(C_DEBUG, 'Customer Site ID', v_CustacctSiteId);
  rlm_core_sv.dlog(C_DEBUG, 'Customer ID', v_CustAccountId);
  rlm_core_sv.dpop(C_SDEBUG);
 END IF;
 --
 EXCEPTION
  --
  WHEN OTHERS THEN
   --
   x_SourceTPLocCode := NULL;
   x_ErrCode := x_ErrCode + 1;
   x_ErrMsg  := x_ErrMsg || 'error in RLM_XML_API.DeriveCustomerId' || SUBSTRB(SQLERRM, 1, 200);
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG,'RLM_ERROR', 'Unknown Error in RLM_XML_API.DeriveCustomerId');
    rlm_core_sv.dlog(C_DEBUG, 'Exception when others',
                     SUBSTRB(SQLERRM, 1, 200));
    rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
END DeriveCustomerId;

END RLM_XML_API;

/
