--------------------------------------------------------
--  DDL for Package Body GMD_CREATE_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_CREATE_FORMULA" AS
/* $Header: GMDPCFMB.pls 120.2 2005/09/23 06:49:11 txdaniel noship $ */
/*      =============================================
      Procedure:
       Create_Formula

      DESCRIPTION:
        This PL/SQL procedure is responsible for
        calling the formula API.

      =============================================
 */

  PROCEDURE CREATE_FORMULA  IS
	  formula_insert_table GMD_FORMULA_PUB.formula_insert_hdr_tbl_type;
	  form_count BINARY_INTEGER := 0;
	  form_handle UTL_FILE.FILE_TYPE;
	  line_out varchar2(2000);
	  rec_type varchar2(2000);
	  start_position NUMBER := 0;
	  end_position NUMBER := 1;
	  l_return_status varchar2(1);
	  x_msg_count NUMBER;
	  x_msg_data  varchar2(240);
	  my_text varchar2(2000);
	  time_start BINARY_INTEGER;
	  time_load BINARY_INTEGER;
	  time_end BINARY_INTEGER;

	  l_end_of_line VARCHAR2(30);

  BEGIN
     time_start := DBMS_UTILITY.GET_TIME;

/*	    OPEN A TEXT FILE
	    PLEASE NOTE: my file exists in /sqlcom/log/opm115m
	    This needs to be changed !!!!!!
*/

     form_handle := UTL_FILE.FOPEN('/sqlcom/log/opm115g','MPGFM.csv','R');

  LOOP
     UTL_FILE.GET_LINE(form_handle,line_out);

	 form_count := form_count + 1;
	 start_position := 0;
	 end_position := 1;

        IF (end_position <> 0)  THEN
	         end_position := instr(line_out,',',start_position + 1,1);
	         rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
	         formula_insert_table(form_count).record_type :=  rec_type;
	         start_position := end_position;
	    END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_no :=  UPPER(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_vers :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_type :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_desc1 :=  rec_type;
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_desc2 :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_class :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).fmcontrol_class :=  rec_type;
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).inactive_ind :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_id :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formulaline_id :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).line_type :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).line_no :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).item_no :=  UPPER(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).qty :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).detail_uom :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).release_type :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).scrap_factor :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).scale_type_hdr :=  to_number(rec_type);
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).scale_type_dtl :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).cost_alloc :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).phantom_type :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).rework_type :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).owner_organization_id :=  (rec_type);
             start_position := end_position;
        END IF;

       /*  New fields added for Mini pack G - for fm_form_mst_b table*/
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).formula_status :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).owner_id :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        /* New fields added for Mini pack G - for fm_matl_dtl  */
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).TPFORMULA_ID :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).IAFORMULA_ID :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).CONTRIBUTE_STEP_QTY_IND  :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).user_name :=  rec_type;
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).created_by :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).last_updated_by :=  to_number(rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).creation_date :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).last_update_date :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).text_code_hdr :=  (rec_type);
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).text_code_dtl :=  (rec_type);
             start_position := end_position;
        END IF;


        /* Flexfields for formula header and detail  */

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute1 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute2 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute3 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute4 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute5 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute6 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute7 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute8 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute9 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute10 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute11 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute12 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute13 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute14 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute15 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute16 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute17 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute18 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute19 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute20 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute21 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute22 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute23 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute24 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute25 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute26 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute27 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute28 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute29 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute30 :=  rec_type;
             start_position := end_position;
        END IF;


        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute1 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute2 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute3 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute4 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute5 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute6 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute7 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute8 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute9 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute10 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute11 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute12 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute13 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute14 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute15 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute16 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute17 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute18 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute19 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute20 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute21 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute22 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute23 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute24 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute25 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute26 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute27 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute28 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute29 :=  rec_type;
             start_position := end_position;
        END IF;
        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).dtl_attribute30 :=  rec_type;
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             formula_insert_table(form_count).attribute_category :=  rec_type;
             start_position := end_position;
        END IF;

        IF (end_position <> 0)  THEN
             end_position := instr(line_out,',',start_position + 1,1);
             rec_type := substr(line_out,start_position + 1,(end_position - start_position) - 1);
             l_end_of_line :=  rec_type;
             start_position := end_position;
        END IF;


   END LOOP;


EXCEPTION
	WHEN no_data_found THEN
		UTL_FILE.FCLOSE(form_handle);
		time_load := DBMS_UTILITY.GET_TIME;

             GMD_FORMULA_PUB.Insert_Formula
             (  1.0                           ,
                FND_API.G_FALSE               ,
                FND_API.G_TRUE               ,
                'YES'                         ,
                l_return_status               ,
                x_msg_count                   ,
                x_msg_data                    ,
                formula_insert_table
             );


		time_end := DBMS_UTILITY.GET_TIME;

        IF (l_return_status <> 'S') THEN
	      for i IN 1 .. x_msg_count LOOP
		    my_text := FND_MSG_PUB.get(i,x_msg_data);
		   /* dbms_output.put_line('The text is '||my_text);   */
	      END LOOP;
	    END IF;


	WHEN OTHERS
	THEN
		UTL_FILE.FCLOSE(form_handle);

  END Create_Formula;
End GMD_CREATE_FORMULA;

/
