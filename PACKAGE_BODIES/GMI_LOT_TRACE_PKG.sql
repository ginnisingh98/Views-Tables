--------------------------------------------------------
--  DDL for Package Body GMI_LOT_TRACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOT_TRACE_PKG" AS
/* $Header: GMILGENB.pls 115.6 2003/11/19 08:32:36 gmangari ship $  */
PROCEDURE exp_lot(pitem_id number,plot_id number, lvl number,comp_no IN OUT NOCOPY number,View_flag number,trace_id number) IS
  lot_tab lot_tab_typ;
  i number := 1;
BEGIN
  INSERT INTO GMI_LOT_TRACE (LOT_TRACE_ID
                             ,ITEM_ID
                             ,LOT_ID
                             ,COMP_NO
                             ,LEVEL_NO
                             ,CIR_FLG)
         values (trace_id,
                 pitem_id,
                 plot_id,
                 comp_no,
                 1,
                 null);
  comp_no :=1;
  lot_tab(i) := plot_id;
  GMI_Lot_trace_pkg.EXP_lot1(pitem_id,plot_id,2,comp_no,view_flag,trace_id,i,lot_tab);
END;

PROCEDURE exp_lot1(pitem_id number,
		   plot_id number,
		   lvl number,
                   comp_no IN OUT NOCOPY number,
                   View_flag number,
                   trace_id number,
                   node_index NUMBER,
                   lot_tab IN OUT NOCOPY LOT_TAB_TYP) IS

V_cursor_id    INTEGER;
V_selectstmt   VARCHAR2(500);
v_item_id      ic_item_mst.item_id%TYPE;
v_lot_id       ic_lots_mst.lot_id%TYPE;
v_has_child    VARCHAR2(10);
v_dummy        INTEGER;
i              NUMBER := node_index+1;
j              NUMBER := 1;
cir_flg        NUMBER;
Cir_ref        CONSTANT NUMBER := 1;
BEGIN

-- Open the cursor for processing
  V_cursor_id  := DBMS_SQL.OPEN_CURSOR;
--BEGIN BUG#3102313 James Bernard
--Modified the select statement to honour formula security.
--Joined the doc_id of the transactions with pm_btch_hdr.batch_id
--and pm_btch_hdr.formula_id with fm_form_mst.formula_id
-- Create the Query string based pn view flag 1. for lot source 2. for wareused
  IF view_flag = 1 THEN
    V_selectstmt :=' SELECT  INGRED_ITEM_ID item_id,INGRED_LOT_ID lot_id , HAS_CHILD  '||
                   ' FROM GMI_LOTS_SOURCE_BOM_V SRC '||
                   ' WHERE DOC_ID IN (SELECT BATCH_ID FROM PM_BTCH_HDR PM, FM_FORM_MST FM ' ||
                   ' WHERE BATCH_ID=SRC.DOC_ID AND PM.FORMULA_ID=FM.FORMULA_ID ) AND PRODUCT_ITEM_ID = ' || pitem_id  ||
                   '    AND PRODUCT_LOT_ID =' ||plot_id;
  ELSE
    V_selectstmt :=' SELECT  PRODUCT_ITEM_ID item_id,PRODUCT_LOT_ID lot_id , HAS_CHILD  '||
                   ' FROM GMI_LOTS_DEST_BOM_V  DEST '||
                   ' WHERE DOC_ID IN (SELECT BATCH_ID FROM PM_BTCH_HDR PM, FM_FORM_MST FM ' ||
                   ' WHERE BATCH_ID=DEST.DOC_ID AND PM.FORMULA_ID=FM.FORMULA_ID ) AND INGRED_ITEM_ID = '|| pitem_id  ||
                   '    AND INGRED_LOT_ID =' ||plot_id;
  END IF;
--END BUG#3102313
--  Parse the Query

  DBMS_SQL.PARSE(v_cursor_id,v_selectstmt,DBMS_SQL.V7);

-- Define the output variables

  DBMS_SQL.DEFINE_COLUMN(v_cursor_id,1,v_item_id);
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id,2,v_lot_id);
  DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,3,v_has_child,10);

--  Execute the statement

  v_dummy := DBMS_SQL.EXECUTE(v_cursor_id);
  LOOP
    IF DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0 THEN
      EXIT;
    END IF;

    --  Retrieve data into PL/SQL Variables

     DBMS_SQL.COLUMN_VALUE(v_cursor_id,1,v_item_id);
     DBMS_SQL.COLUMN_VALUE(v_cursor_id,2,v_lot_id);
     DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,3,v_has_child);
     lot_tab(i) := v_lot_id;
     comp_no := comp_no +1;
     IF v_has_child <> 'no' THEN
       j:= 1;  -- initialize index to search through the lot stack
       WHILE j <= node_index
       LOOP
         IF LOT_TAB(j) = v_lot_id THEN
           cir_flg := CIR_REF;
           EXIT;
         ELSE
           cir_flg := 0;
         END IF;
         j := j + 1;
       END LOOP;
       IF cir_flg <> CIR_REF THEN
         INSERT INTO GMI_LOT_TRACE (LOT_TRACE_ID
                             ,ITEM_ID
                             ,LOT_ID
                             ,COMP_NO
                             ,LEVEL_NO
                             ,CIR_FLG)
         values (trace_id,
                 v_item_id,
                 v_lot_id,
                 comp_no,
                 lvl,
                 null);
         GMI_Lot_trace_pkg.exp_lot1(v_item_id,v_lot_id,lvl+1,comp_no,view_flag,trace_id,i,lot_tab);
       ELSE
         INSERT INTO GMI_LOT_TRACE (LOT_TRACE_ID
                             ,ITEM_ID
                             ,LOT_ID
                             ,COMP_NO
                             ,LEVEL_NO
                             ,CIR_FLG)
         values (trace_id,
                 v_item_id,
                 v_lot_id,
                 comp_no,
                 lvl,
                 '*');
       END IF;
     ELSE
     INSERT INTO GMI_LOT_TRACE (LOT_TRACE_ID
                             ,ITEM_ID
                             ,LOT_ID
                             ,COMP_NO
                             ,LEVEL_NO
                             ,CIR_FLG)
         values (trace_id,
                 v_item_id,
                 v_lot_id,
                 comp_no,
                 lvl,
                 null);
     END IF;
  END LOOP;
--  Close the cursor
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
END;


function has_ingred_in_pnd(fv_item_id number, fv_lot_id number)
return varchar2
is
	cursor prod_cursor is
	select doc_id
	from ic_tran_pnd
	where item_id = fv_item_id and lot_id = fv_lot_id
	and doc_type = 'PROD' and line_type in (1,2)
	and completed_ind = 1 and delete_mark = 0
	group by doc_id
	having sum(trans_qty) > 0;

	lv_ingred_count number := 0;
begin
	for prod in prod_cursor
	loop
		begin
			select count(*) into lv_ingred_count
			from (
				select item_id, lot_id
				from ic_tran_pnd
				where doc_type = 'PROD'
				and doc_id = prod.doc_id
				and completed_ind = 1
				and delete_mark = 0
				and lot_id <> 0
				and line_type = -1
				group by item_id, lot_id
				having sum(trans_qty) < 0
			);

		exit when lv_ingred_count > 0;

		exception
			when no_data_found then
				lv_ingred_count := 0;
		end;

	end loop;

	if lv_ingred_count > 0
	then return 'yes';
	else return 'no';
	end if;

end has_ingred_in_pnd;

function has_product_in_pnd(fv_item_id number, fv_lot_id number)
return varchar2
is
	cursor ingred_cursor is
	select doc_id
	from ic_tran_pnd
	where item_id = fv_item_id and lot_id = fv_lot_id
	and doc_type = 'PROD' and line_type = -1
	and completed_ind = 1 and delete_mark = 0
	group by doc_id
	having sum(trans_qty) < 0;

	lv_product_count number := 0;
begin
	for ingred in ingred_cursor
	loop
		begin
			select count(*) into lv_product_count
			from (
			select item_id, lot_id
			from ic_tran_pnd
			where doc_type = 'PROD'
			and doc_id = ingred.doc_id
			and completed_ind = 1
			and delete_mark = 0
			and lot_id <> 0
			and line_type in (1,2)
			group by item_id, lot_id
			having sum(trans_qty) > 0);

		exit when lv_product_count > 0;

		exception
			when no_data_found then
				lv_product_count := 0;
		end;

	end loop;

	if lv_product_count > 0
	then return 'yes';
	else return 'no';
	end if;

end has_product_in_pnd;

function has_ingred_in_cmp(fv_item_id number, fv_lot_id number)
return varchar2
is
	cursor prod_cursor is
	select doc_id
	from ic_tran_cmp
	where item_id = fv_item_id and lot_id = fv_lot_id
	and doc_type = 'PROD' and line_type in (1,2)
	group by doc_id
	having sum(trans_qty) > 0;

	lv_ingred_count number := 0;
begin
	for prod in prod_cursor
	loop
		begin
			select count(*) into lv_ingred_count
			from (
				select item_id, lot_id
				from ic_tran_cmp
				where doc_type = 'PROD'
				and doc_id = prod.doc_id
				and lot_id <> 0
				and line_type = -1
				group by item_id, lot_id
				having sum(trans_qty) < 0
			);

		exit when lv_ingred_count > 0;

		exception
			when no_data_found then
				lv_ingred_count := 0;
		end;

	end loop;

	if lv_ingred_count > 0
	then return 'yes';
	else return 'no';
	end if;

end has_ingred_in_cmp;

function has_product_in_cmp(fv_item_id number, fv_lot_id number)
return varchar2
is
	cursor ingred_cursor is
	select doc_id
	from ic_tran_cmp
	where item_id = fv_item_id and lot_id = fv_lot_id
	and doc_type = 'PROD' and line_type = -1
	group by doc_id
	having sum(trans_qty) < 0;

	lv_product_count number := 0;
begin
	for ingred in ingred_cursor
	loop
		begin
			select count(*) into lv_product_count
			from (
			select item_id, lot_id
			from ic_tran_cmp
			where doc_type = 'PROD'
			and doc_id = ingred.doc_id
			and lot_id <> 0
			and line_type in (1,2)
			group by item_id, lot_id
			having sum(trans_qty) > 0);

		exit when lv_product_count > 0;

		exception
			when no_data_found then
				lv_product_count := 0;
		end;

	end loop;

	if lv_product_count > 0
	then return 'yes';
	else return 'no';
	end if;

end has_product_in_cmp;


function has_ingred(fv_item_id number, fv_lot_id number)
return varchar2
is
begin
	if fv_lot_id = 0
	then
		return 'no';
	elsif has_ingred_in_pnd(fv_item_id, fv_lot_id) = 'yes'
	then
		return 'yes';
	elsif has_ingred_in_cmp(fv_item_id, fv_lot_id) = 'yes'
	then
		return 'yes';
	else
		return 'no';
	end if;
end;

function has_product(fv_item_id number, fv_lot_id number)
return varchar2
is
begin
	if fv_lot_id = 0
	then
		return 'no';
	elsif has_product_in_pnd(fv_item_id, fv_lot_id) = 'yes'
	then
		return 'yes';
	elsif has_product_in_cmp(fv_item_id, fv_lot_id) = 'yes'
	then
		return 'yes';
	else
		return 'no';
	end if;
end;





END; -- End of lot trace package


/
