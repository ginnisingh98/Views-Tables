--------------------------------------------------------
--  DDL for Package Body BOMCUMYD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMCUMYD" AS
/* $Header: BOMCMYLB.pls 120.1.12000000.2 2007/04/13 12:36:23 deegupta ship $ */

PROCEDURE Cumulative_Yield(
ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
RETCODE                 IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
Current_org_id		IN	NUMBER,
Scope			IN	NUMBER		DEFAULT 1,
Flag_Value		IN	VARCHAR2,
Item_Id			IN	NUMBER,
Operation_Type		IN	NUMBER		DEFAULT 1,
Update_Events		IN	NUMBER		DEFAULT 1,
Item_Low		IN	VARCHAR2,
Item_High		IN	VARCHAR2
) IS
	Item_Name		VARCHAR2(40) ;
	Range_Item_Id 		NUMBER := 0  ;
	ROUTING_SEQ_ID		NUMBER := 1  ;
	conc_status		BOOLEAN      ;
	Current_Error_Code      VARCHAR2(20) := NULL;

	Item_Range_Not_Specified 	         EXCEPTION;
	Item_Specific_Not_Specified		 EXCEPTION;

CURSOR  Item_Range_Both is
SELECT 	inventory_item_id,concatenated_segments
FROM 	mtl_system_items_b_kfv
WHERE 	concatenated_segments BETWEEN item_low and item_high
AND     organization_id = current_org_id;

CURSOR  Item_Range_Low is
SELECT 	inventory_item_id,concatenated_segments
FROM 	mtl_system_items_b_kfv
WHERE 	concatenated_segments >= item_low
AND     organization_id = current_org_id;

CURSOR  Item_Range_High is
SELECT 	inventory_item_id,concatenated_segments
FROM 	mtl_system_items_b_kfv
WHERE 	concatenated_segments <= item_high
AND     organization_id = current_org_id;

CURSOR  Cur_Rtg(Item_Id NUMBER) IS
SELECT 	routing_sequence_id,alternate_routing_designator
FROM   	bom_operational_routings
WHERE  	assembly_item_id = Item_Id
AND    	cfm_routing_flag = 3
AND     organization_id = current_org_id;

BEGIN
	/* Print the list of parameters */
        FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;
	FND_FILE.PUT_LINE( FND_FILE.LOG,'SCOPE='||to_char(scope));
	FND_FILE.PUT_LINE( FND_FILE.LOG,'CURRENT_ORG_ID='||to_char(current_org_id));
	FND_FILE.PUT_LINE( FND_FILE.LOG,'ITEM_ID='||to_char(item_id));
	FND_FILE.PUT_LINE( FND_FILE.LOG,'ITEM_FROM='||item_low);
	FND_FILE.PUT_LINE( FND_FILE.LOG,'ITEM_TO='||item_high);
	FND_FILE.PUT_LINE( FND_FILE.LOG,'OPERATION_TYPE='||to_char(operation_type));
	FND_FILE.PUT_LINE( FND_FILE.LOG,'UPDATE_EVENTS='||to_char(update_events));
        FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;
	/* Make sure the right set of parameter are passed */
        IF (scope = 2) AND ((item_low IS NULL) and (item_high is NULL)) THEN
		raise Item_Range_Not_Specified ;
	END IF ;

        IF ((scope = 1) AND (item_id IS NULL)) THEN
		raise Item_Specific_Not_Specified ;
	END IF ;


	/* Open the cursor Item_Range for getting the Item ID's */
	If scope = 2 Then
	 If ((Item_low is NOT NULL) and (Item_High is NOT NULL)) then
	  Open Item_Range_Both;
          Loop
	 	Fetch Item_Range_Both
	  	Into  Range_Item_Id,Item_Name;

	  	EXIT WHEN Item_Range_Both%NOTFOUND;

	  /* Check if routing exists ,if it does then call the function to calculate cumulative yield */

		For C1 in Cur_Rtg(Range_Item_Id)
		Loop
		      if (C1.ALTERNATE_ROUTING_DESIGNATOR is not NULL) then
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name  || ' with Alternate... ' || C1.ALTERNATE_ROUTING_DESIGNATOR);
		      else
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name);
		      end if;
		      BOM_CALC_CYNP.calc_cynp(C1.routing_sequence_id,1,1);
		End Loop;
	  End Loop;
	 ElsIf (Item_Low is NOT NULL) then
	  Open Item_Range_Low;
          Loop
	 	Fetch Item_Range_Low
	  	Into  Range_Item_Id,Item_Name;

	  	EXIT WHEN Item_Range_Low%NOTFOUND;

	  /* Check if routing exists ,if it does then call the function to calculate cumulative yield */

	        For C1 in Cur_Rtg(Range_Item_Id)
	        Loop
		      if (C1.ALTERNATE_ROUTING_DESIGNATOR is not NULL) then
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name  || ' with Alternate... ' || C1.ALTERNATE_ROUTING_DESIGNATOR);
		      else
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name);
		      end if;
		      BOM_CALC_CYNP.calc_cynp(C1.routing_sequence_id,1,1);
	        End Loop;
          End Loop;
	 ElsIf (Item_High is NOT NULL) then
	  Open Item_Range_High;
          Loop
	 	Fetch Item_Range_High
	  	Into  Range_Item_Id,Item_Name;

	  	EXIT WHEN Item_Range_High%NOTFOUND;

	  /* Check if routing exists ,if it does then call the function to calculate cumulative yield */

	        For C1 in Cur_Rtg(Range_Item_Id)
	        Loop
		      if (C1.ALTERNATE_ROUTING_DESIGNATOR is not NULL) then
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name  || ' with Alternate... ' || C1.ALTERNATE_ROUTING_DESIGNATOR);
		      else
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name);
		      end if;
		      BOM_CALC_CYNP.calc_cynp(C1.routing_sequence_id,1,1);
	        End Loop;
          End Loop;
	 End If;
	Else
		SELECT concatenated_segments
		INTO   Item_Name
		FROM   mtl_system_items_b_kfv
		WHERE  inventory_item_id = Item_Id
		AND    organization_id   = Current_Org_Id;

		For C1 in Cur_Rtg(Item_Id)
		Loop
		      if (C1.ALTERNATE_ROUTING_DESIGNATOR is not NULL) then
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name  || ' with Alternate... ' || C1.ALTERNATE_ROUTING_DESIGNATOR);
		      else
		         FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing routing for item....' || Item_Name);
		      end if;
		      BOM_CALC_CYNP.calc_cynp(C1.routing_sequence_id,1,1);
		End Loop;
	end if;
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing ends for Cumulative Yield...');
Exception
	WHEN Item_Range_Not_Specified THEN
	 FND_FILE.PUT_LINE( FND_FILE.LOG,'ITEM RANGE NOT SPECIFIED');
 	 RETCODE := 2;
   	 conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
	WHEN Item_Specific_Not_Specified THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG,'Specific Item Value not Specified');
 	  RETCODE := 2;
   	  conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
 	WHEN OTHERS THEN
   	  FND_FILE.PUT_LINE(FND_FILE.LOG,'Others '||SQLCODE || ':'||SQLERRM) ;
   	  RETCODE := 2;
   	  conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
End Cumulative_Yield;

PROCEDURE flm_calc_util(
org_id                  IN      NUMBER,
item_id			IN	NUMBER,
opr_type		IN	NUMBER,
rtg_seq_id		IN	NUMBER,
Flow_Line_Id		IN	NUMBER
) IS
	l_tpct			NUMBER;
	v_Lead_Time_Profile_Val         varchar2(50); --Variable to define profile for Lead Time Basis
	l_line_hours		NUMBER;
	l_line_Seconds		NUMBER;
BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside calculation');

        BOM_CALC_CYNP.calc_cynp(rtg_seq_id, opr_type, 1);
        BOM_CALC_TPCT.calculate_tpct(rtg_seq_id, to_char(opr_type));
        BOM_CALC_OP_TIMES_PK.calculate_operation_times(org_id, rtg_seq_id);

        /*** Updation of TPCT in the Master items Table  *****/
        SELECT TOTAL_PRODUCT_CYCLE_TIME into l_tpct FROM
        BOM_OPERATIONAL_ROUTINGS bor
        WHERE bor.ROUTING_SEQUENCE_ID = rtg_seq_id
        AND bor.ORGANIZATION_ID = org_id
        AND bor.ASSEMBLY_ITEM_ID = item_id;

        -- Bug 4632067. Lead time should be in days, hence dividing by 24
        -- Bug 5869157 The profile option "BOM:LEAD TIME CALCULATION BASIS" will control whether the lead time is calculated
	-- by dividing by 24 or by line hours
        /** Get the value of profile option BOM:LEAD TIME CALCULATION BASIS **/
        fnd_profile.get('BOM:LEAD_TIME_CALCULATION_BASIS', v_Lead_Time_Profile_Val);
	IF Flow_Line_Id is NULL THEN        /*** Line is not specified  ***/
		UPDATE MTL_SYSTEM_ITEMS
		SET FULL_LEAD_TIME = l_tpct/24,
		    FIXED_LEAD_TIME = l_tpct/24,
		    PROGRAM_UPDATE_DATE = SYSDATE
		WHERE INVENTORY_ITEM_ID = item_id
		AND ORGANIZATION_ID = org_id;
        ELSE
            IF v_Lead_Time_Profile_Val = 'LHR' THEN        /**--Prfoile option is Line hrs-- **/
	       /**Get the line hours using LINE_ID**/
	       Select (STOP_TIME - START_TIME) into l_line_Seconds
               from wip_lines where line_id = Flow_Line_Id
	       and ORGANIZATION_ID = org_id;

	       l_line_hours := 	l_line_Seconds/3600;

	       /**Update using Line hours**/
		UPDATE MTL_SYSTEM_ITEMS
		SET FULL_LEAD_TIME = l_tpct/l_line_hours,
		    FIXED_LEAD_TIME = l_tpct/l_line_hours,
		    PROGRAM_UPDATE_DATE = SYSDATE
		WHERE INVENTORY_ITEM_ID = item_id
		AND ORGANIZATION_ID = org_id;
	    ELSE
	        UPDATE MTL_SYSTEM_ITEMS
		SET FULL_LEAD_TIME = l_tpct/24,
		    FIXED_LEAD_TIME = l_tpct/24,
		    PROGRAM_UPDATE_DATE = SYSDATE
		WHERE INVENTORY_ITEM_ID = item_id
		AND ORGANIZATION_ID = org_id;
            END IF;
	END IF;

END flm_calc_util;

FUNCTION check_op_type(
rtg_seq_id		IN	NUMBER,
op_type			IN	NUMBER
) RETURN NUMBER IS

CURSOR process_chk is
SELECT null from bom_operation_sequences
WHERE routing_sequence_id = rtg_seq_id
and process_op_seq_id is not null;

CURSOR line_chk is
SELECT null from bom_operation_sequences
WHERE routing_sequence_id = rtg_seq_id
and line_op_seq_id is not null;

temp NUMBER := 1;
BEGIN
        IF op_type = 2 THEN
           open process_chk;
           fetch process_chk into temp;
           IF process_chk%NOTFOUND THEN
              temp := 1;
           ELSE
              temp := 2;
           END IF;
           close process_chk;
        ELSIF op_type = 3 THEN
           open line_chk;
           fetch line_chk into temp;
           IF line_chk%NOTFOUND THEN
              temp := 1;
           ELSE
              temp := 3;
           END IF;
           close line_chk;
        END IF;
        return temp;
END check_op_type;

PROCEDURE print_debug(
item_id			IN	NUMBER,
alt			IN	VARCHAR2,
rtg_seq_id		IN	NUMBER
)
IS
BEGIN
    if (alt is not NULL) then
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing routing for item....'
          || to_char(item_id) || ' with Alternate... '
          || alt || 'Rtg_seq_id = '
          || to_char(rtg_seq_id));
    else
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing routing for item....'
          || to_char(item_id) || 'Rtg_seq_id '
          || to_char(rtg_seq_id));
    end if;
END print_debug;

PROCEDURE Flow_Batch_Calc(
ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
RETCODE                 IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
Current_org_id		IN	NUMBER,
Scope			IN	NUMBER		DEFAULT 1,
Flag_Value		IN	VARCHAR2,
Item_Id			IN	NUMBER,
Line_Id			IN	NUMBER,
oper_type		IN	NUMBER		DEFAULT 3,
Item_Low		IN	VARCHAR2,
Item_High		IN	VARCHAR2,
Operation_Name		IN	VARCHAR2,
Event_Name		IN	VARCHAR2
) IS
	Item_Name		VARCHAR2(40) ;
	Current_Error_Code      VARCHAR2(20) := NULL;
	conc_status		BOOLEAN      ;
	Operation_Code		VARCHAR2(4);

        TYPE item_id_tab_type IS TABLE of
        MTL_SYSTEM_ITEMS_B_KFV.inventory_item_id%TYPE
        INDEX by BINARY_INTEGER;

        TYPE item_name_tab_type IS TABLE of
        MTL_SYSTEM_ITEMS_B_KFV.concatenated_segments%TYPE
        INDEX by BINARY_INTEGER;

        item_tab item_id_tab_type;
        item_name_tab item_name_tab_type;

        i 	NUMBER := 1;
        l_all 	NUMBER := 0;
        l_tpct 	NUMBER;
        l_op_type NUMBER := 3;
        l_op_flag NUMBER;
        l_found BOOLEAN := false;

        No_Op_On_Line		EXCEPTION;
        No_Event_On_Line	EXCEPTION;

CURSOR  Item_Range_Both is
SELECT 	inventory_item_id,concatenated_segments
FROM 	mtl_system_items_b_kfv
WHERE 	concatenated_segments BETWEEN item_low and item_high
AND     organization_id = current_org_id;

CURSOR  Item_Range_Low is
SELECT 	inventory_item_id,concatenated_segments
FROM 	mtl_system_items_b_kfv
WHERE 	concatenated_segments >= item_low
AND     organization_id = current_org_id;

CURSOR  Item_Range_High is
SELECT 	inventory_item_id,concatenated_segments
FROM 	mtl_system_items_b_kfv
WHERE 	concatenated_segments <= item_high
AND     organization_id = current_org_id;

CURSOR Cur_Line_Flow_Rtg (v_line NUMBER) is
SELECT routing_sequence_id, alternate_routing_designator,
       assembly_item_id
FROM BOM_OPERATIONAL_ROUTINGS	bor
WHERE bor.ORGANIZATION_ID = current_org_id
AND bor.CFM_ROUTING_FLAG = 1
AND bor.LINE_ID = v_line;

CURSOR Cur_Line_Op_Flow_Rtg (v_line NUMBER, v_operation_code VARCHAR2) is
SELECT DISTINCT bor.routing_sequence_id, bor.alternate_routing_designator,
       bor.assembly_item_id
FROM BOM_OPERATIONAL_ROUTINGS	bor,
BOM_OPERATION_SEQUENCES bos,
BOM_STANDARD_OPERATIONS bso
WHERE bor.ORGANIZATION_ID = current_org_id
AND bor.CFM_ROUTING_FLAG = 1
AND bor.LINE_ID = v_line
AND bso.OPERATION_CODE = v_operation_code
AND bos.STANDARD_OPERATION_ID = bso.STANDARD_OPERATION_ID
AND bor.ROUTING_SEQUENCE_ID = bos.ROUTING_SEQUENCE_ID
AND bos.OPERATION_TYPE = l_op_type;

CURSOR Cur_Flow_Rtg is
SELECT routing_sequence_id, alternate_routing_designator,
       assembly_item_id
FROM BOM_OPERATIONAL_ROUTINGS bor
WHERE bor.ORGANIZATION_ID = current_org_id
AND bor.CFM_ROUTING_FLAG = 1;

CURSOR Cur_Item_Line_Flow_Rtg (Item_id NUMBER, v_line NUMBER) is
SELECT routing_sequence_id, alternate_routing_designator
FROM BOM_OPERATIONAL_ROUTINGS	bor
WHERE bor.ORGANIZATION_ID = current_org_id
AND bor.ASSEMBLY_ITEM_ID = Item_id
AND bor.CFM_ROUTING_FLAG = 1
AND bor.LINE_ID = v_line;

CURSOR Cur_Item_Line_Op_Flow_Rtg (Item_id NUMBER, v_line NUMBER, v_operation_code VARCHAR2) is
SELECT DISTINCT bor.routing_sequence_id, bor.alternate_routing_designator
FROM BOM_OPERATIONAL_ROUTINGS bor,
BOM_OPERATION_SEQUENCES bos,
BOM_STANDARD_OPERATIONS bso
WHERE bor.ORGANIZATION_ID = current_org_id
AND bor.ASSEMBLY_ITEM_ID = Item_id
AND bor.CFM_ROUTING_FLAG = 1
AND bor.LINE_ID = v_line
AND bso.OPERATION_CODE = v_operation_code
AND bos.STANDARD_OPERATION_ID = bso.STANDARD_OPERATION_ID
AND bor.ROUTING_SEQUENCE_ID = bos.ROUTING_SEQUENCE_ID
AND bos.OPERATION_TYPE = l_op_type;

CURSOR Cur_Item_Flow_Rtg (Item_id NUMBER) is
SELECT routing_sequence_id, alternate_routing_designator
FROM BOM_OPERATIONAL_ROUTINGS bor
WHERE bor.ORGANIZATION_ID = current_org_id
AND bor.ASSEMBLY_ITEM_ID = Item_id
AND bor.CFM_ROUTING_FLAG = 1;


BEGIN
	/* Print the list of parameters */

        FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;
	FND_FILE.PUT_LINE(FND_FILE.LOG,'SCOPE='||to_char(scope));
	FND_FILE.PUT_LINE(FND_FILE.LOG,'CURRENT_ORG_ID='||to_char(current_org_id));
	FND_FILE.PUT_LINE(FND_FILE.LOG,'ITEM_ID='||to_char(item_id));
	FND_FILE.PUT_LINE(FND_FILE.LOG,'ITEM_FROM='||item_low);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'ITEM_TO='||item_high);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'OPERATION_TYPE='||to_char(oper_type));
	FND_FILE.PUT_LINE(FND_FILE.LOG,'LINE_ID='||to_char(Line_Id));
	FND_FILE.PUT_LINE(FND_FILE.LOG,'OPERATION_Name='||Operation_Name);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Event_Name='||Event_Name);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;

        i := 1;
        item_tab.DELETE;

        IF scope = 1 THEN
          IF item_id is NULL THEN
             l_all := 1;
          ELSE
            item_tab(1) := item_id;
          END IF;
        ELSIF scope = 2 THEN
          IF (item_high is NULL) and (item_low is NULL) THEN
             l_all := 1;
          ELSIF (item_high is NOT NULL) AND (item_low is NULL) THEN
             FOR C1 in item_range_high
             LOOP
                item_tab(i) := C1.inventory_item_id;
                item_name_tab(i) := C1.concatenated_segments;
                i := i + 1;
             END LOOP;
          ELSIF (item_low is NOT NULL) AND (item_high is NULL) THEN
             FOR C1 in item_range_low
             LOOP
                item_tab(i) := C1.inventory_item_id;
                item_name_tab(i) := C1.concatenated_segments;
                i := i + 1;
             END LOOP;
          ELSE
             FOR C1 in item_range_both
             LOOP
                item_tab(i) := C1.inventory_item_id;
                item_name_tab(i) := C1.concatenated_segments;
                i := i + 1;
             END LOOP;
          END IF;
        END IF;

--        IF Operation_Name is NULL THEN  -- Event based filtering
-- Changed for the bug found during testing
        IF Operation_name is NULL AND Event_Name is NOT NULL THEN
           Operation_code := Event_Name;
           l_op_type := 1;
        ELSE
           l_op_type := oper_type;
           Operation_Code := Operation_Name;
        END IF;

        IF l_all = 0 THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Item/Item range specified, op type='||to_char(l_op_type));
           FOR i IN 1..item_tab.COUNT
           LOOP
               IF Line_id is NULL THEN        /*** Line is not specified  ***/
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'No line is specified');
                  FOR C1 in Cur_Item_Flow_Rtg(item_tab(i))
                  Loop
                      print_debug(item_tab(i), C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                      flm_calc_util(current_org_id, item_tab(i), l_op_type, C1.routing_sequence_id, Line_Id);
                  End Loop;
               ELSIF Operation_code is NULL THEN	/*** Only Line is specified   ***/
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Only line is specified');
                  FOR C1 in Cur_Item_Line_Flow_Rtg(item_tab(i), Line_Id)
                  Loop
                      print_debug(item_tab(i), C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                      flm_calc_util(current_org_id, item_tab(i), l_op_type, C1.routing_sequence_id, Line_Id);
                  End Loop;
               ELSIF l_op_type > 1 THEN	/***  Line and operation are specified   ***/
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Line and operation is specified');
                  FOR C1 in Cur_Item_Line_Op_Flow_Rtg(item_tab(i), Line_id, Operation_Code)
                  Loop
                      print_debug(item_tab(i), C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                      flm_calc_util(current_org_id, item_tab(i), l_op_type, C1.routing_sequence_id, Line_Id);
                      l_found := true;
                  End Loop;
                  IF scope = 1 AND NOT l_found THEN
                     raise No_Op_On_Line;
                  END IF;
               ELSE		/*** Line, operation_type and Event are specified ***/
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Line, operation and event specified');
                  FOR C1 in Cur_Item_Line_Op_Flow_Rtg(item_tab(i), Line_id, Operation_Code)
                  Loop
                      l_op_flag := check_op_type(C1.routing_sequence_id, oper_type);
                      IF l_op_flag <> 1 THEN
                         print_debug(item_tab(i), C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                         flm_calc_util(current_org_id, item_tab(i), l_op_flag, C1.routing_sequence_id, Line_Id);
                         l_found := true;
                      END IF;
                  End Loop;
                  IF scope = 1 AND NOT l_found THEN
                     raise No_Event_On_Line;
                  END IF;
               END IF;
           End Loop;
        ELSE
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Item/Item range NOT specified, selecting all items...');
           IF Line_id is NULL THEN		/*** Line is not specified  ***/
              FND_FILE.PUT_LINE(FND_FILE.LOG,'No line is specified');
              FOR C1 in Cur_Flow_Rtg
              Loop
                   print_debug(C1.assembly_item_id, C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                   flm_calc_util(current_org_id, C1.assembly_item_id, l_op_type, C1.routing_sequence_id, Line_Id);
              End Loop;
           ELSIF Operation_code is NULL THEN	/*** Only Line is specified   ***/
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Only line is specified');
              FOR C1 in Cur_Line_Flow_Rtg(Line_Id)
              Loop
                   print_debug(C1.assembly_item_id, C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                   flm_calc_util(current_org_id, C1.assembly_item_id, l_op_type, C1.routing_sequence_id, Line_Id);
               End Loop;
            ELSIF l_op_type > 1 THEN	/***  Line and operation specified   ***/
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Line and operation specified');
               FOR C1 in Cur_Line_Op_Flow_Rtg(Line_id, Operation_Code)
               Loop
                   print_debug(C1.assembly_item_id, C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                   flm_calc_util(current_org_id, C1.assembly_item_id, l_op_type, C1.routing_sequence_id, Line_Id);
               End Loop;
            ELSE		/*** Line, Operation and event specified  ***/
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Line, operation and event specified');
               FOR C1 in Cur_Line_Op_Flow_Rtg(Line_id, Operation_Code)
               Loop
                   l_op_flag := check_op_type(C1.routing_sequence_id, oper_type);
                   IF l_op_flag <> 1 THEN
                      print_debug(C1.assembly_item_id, C1.Alternate_Routing_Designator, C1.routing_sequence_id);
                      flm_calc_util(current_org_id, C1.assembly_item_id, l_op_flag, C1.routing_sequence_id, Line_Id);
                   END IF;
               End Loop;

            END IF;
        END IF;
Exception

   	WHEN No_Op_On_Line THEN
   	  FND_FILE.PUT_LINE(FND_FILE.LOG,'Specified operation not available for the item on the line specified');
 	  RETCODE := 2;
   	  conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
   	WHEN No_Event_On_Line THEN
   	  FND_FILE.PUT_LINE(FND_FILE.LOG,'Specified event not available for the item on the line specified');
 	  RETCODE := 2;
   	  conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

 	WHEN OTHERS THEN
   	  FND_FILE.PUT_LINE(FND_FILE.LOG,'Others '||SQLCODE || ':'||SQLERRM) ;
   	  RETCODE := 2;
   	  conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

END Flow_Batch_Calc;

END BOMCUMYD ;

/
