--------------------------------------------------------
--  DDL for Package Body FV_STATUS_OF_OBLIGATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_STATUS_OF_OBLIGATIONS" as
    -- $Header: FVXPOSRB.pls 120.6 2006/06/19 12:07:11 svaithil ship $
    --==============================================================
	-- Error Code and Error Messages
	v_error_code Number := 0 ;
	v_error_mesg Varchar2(500) ;
  g_module_name varchar2(100) := 'fv.plsql.fv_status_of_obligations.';
	-- Dynamic SQL variables
	v_select 	 varchar2(2000);
	v_val_string 	 varchar2(2000);
	v_po_select 	 varchar2(2000);
	v_where	 	varchar2(1000) ;

	v_inv_cursor Integer ;
	v_po_cursor  Integer ;
	v_exec_ret	 Integer ;

	-- Global variables to store the passes parameters
	v_segval1	varchar2(20);
	v_segval2	varchar2(20);
	v_segval3	varchar2(20);

	v_segval1_low	varchar2(20);
	v_segval1_high	varchar2(20);

	v_seg_val1	varchar2(30);
	v_seg_val2	varchar2(30);
	v_seg_val3	varchar2(30);

	v_segval2_low	varchar2(20);
	v_segval2_high	varchar2(20);

	v_segval3_low	varchar2(20);
	v_segval3_high	varchar2(20);

	v_from_period	date;
	v_to_period	date;
	v_set_of_books_id number;

	/*b_from_period	date;
	b_to_period	date;
	b_set_of_books_id number;*/

	-- Variables to store the Main select information

	v_reqnum	po_requisition_headers.segment1%type;
	v_reqdate 	date;
	v_reqamt	number;
	v_reqccid	number;

	v_oblignum	po_headers.segment1%type;
	v_obligdate 	date;
	v_obligamt	number;
	v_obligccid	number;
	v_obligstatus	po_lines.closed_code%type;
	v_inv_po_distribution_id
			po_distributions.po_distribution_id%type ;
	v_po_req_distribution_id
			po_req_distributions.distribution_id%type ;
	v_po_distribution_id po_distributions.po_distribution_id%type ;

	v_invnum	ap_invoices.invoice_num%type;
	v_invdate 	date;
	v_invamt	number;
	v_invccid	number;
	v_reversal_flag	Varchar2(1)  ;

----------------------------------------------------------------------
--				MAIN
----------------------------------------------------------------------
procedure main (
		Errbuf       OUT NOCOPY varchar2,
		retcode      OUT NOCOPY varchar2,
		segval1 	 in  varchar2,
		segval2 	 in varchar2,
		segval3 	 in varchar2,
		segval1_low  in varchar2,
		segval1_high in varchar2,
		segval2_low  in varchar2,
		segval2_high in varchar2,
		segval3_low  in varchar2,
		segval3_high in varchar2,
		from_period  in date,
		to_period 	 in date,
		set_of_books_id in number)

IS
l_module_name varchar2(200) := g_module_name || 'main';
l_errbuf      varchar2(300);
Begin

	-- Initialize parameters to global variables
	v_segval1	:= segval1 ;
	v_segval2	:= segval2 ;
	v_segval3	:= segval3 ;

	v_segval1_low  :=	segval1_low ;
	v_segval1_high := segval1_high ;
	v_segval2_low  :=	segval2_low ;
	v_segval2_high := segval2_high ;
	v_segval3_low  :=	segval3_low ;
	v_segval3_high := segval3_high ;

	v_from_period  := from_period ;
	v_to_period	   := to_period ;
	v_set_of_books_id  := set_of_books_id ;

       If v_error_code = 0 Then
            Initialize ;
        End If ;

        If v_error_code = 0 Then
            Build_Where_Clause ;
        End If ;

        If v_error_code = 0 Then
            Process_Invoices ;
        End If ;

        If v_error_code = 0 Then
            Process_pos ;
        End If ;


        If v_error_code = 0 Then
            Commit ;
        Else
            Rollback ;
        End If ;

        retcode := to_char(v_error_code) ;
        errbuf  := v_error_mesg ;
EXCEPTION
WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
End Main ;


----------------------------------------------------------------------
--                          INITIALIZE
----------------------------------------------------------------------
Procedure Initialize is
l_module_name varchar2(200) := g_module_name || 'initialize';
Begin
    -- Delete the Temporary table
    Delete from FV_STATUS_OBLIG_TEMP ;
Exception
    When Others Then
        v_error_code := sqlcode ;
        v_error_mesg := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
End Initialize ;

----------------------------------------------------------------------
--			PROCESS_INVOICES
----------------------------------------------------------------------
Procedure  Process_invoices is
l_module_name varchar2(200) := g_module_name || 'process_invoices';
l_errbuf varchar2(300);
l_req_duplicate number;
l_po_duplicate number;
Cursor c1_duplicate_PO(p_inv_po_distribution_id number) Is
        select 2
        from fv_status_oblig_temp
        where inv_po_distribution_id = p_inv_po_distribution_id ;
Cursor c2_duplicate_req(p_po_req_distribution_id number) Is
        select 1
        from fv_status_oblig_temp
        where po_req_distribution_id = p_po_req_distribution_id;
Begin

    Begin
	v_inv_cursor := DBMS_SQL.OPEN_CURSOR  ;
    Exception
	When Others Then
            v_error_code := sqlcode ;
            v_error_mesg := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
    End ;

	-- Get all the Invoices
	v_select :=
	    'select  api.invoice_num,
 		     api.invoice_date,
		     apd.amount,
		     apd.dist_code_combination_id,
		     apd.po_distribution_id ' || v_val_string
	    || ' from  ap_invoice_distributions apd,
		     ap_invoices api,
		     gl_code_combinations glcc
	     where api.invoice_id = apd.invoice_id
	     and   glcc.code_combination_id = apd.dist_code_combination_id
	     and  (api.invoice_date  between  :b_from_period and  :b_to_period)
	     and api.set_of_books_id = :b_set_of_books_id '|| v_where ;


    Begin

	dbms_sql.parse(v_inv_cursor, v_select, DBMS_SQL.V7) ;

	dbms_sql.bind_variable(v_inv_cursor,':b_from_period',v_from_period);
	dbms_sql.bind_variable(v_inv_cursor,':b_to_period',v_to_period);
	dbms_sql.bind_variable(v_inv_cursor,':b_set_of_books_id',v_set_of_books_id);

	dbms_sql.bind_variable(v_inv_cursor,':b_segval1_low',v_segval1_low);
	dbms_sql.bind_variable(v_inv_cursor,':b_segval1_high',v_segval1_high);

	If v_segval2 is NOT NULL Then
		dbms_sql.bind_variable(v_inv_cursor,':b_segval2_low',v_segval2_low);
		dbms_sql.bind_variable(v_inv_cursor,':b_segval2_high',v_segval2_high);
	End if;

	If v_segval3 is NOT NULL Then
		dbms_sql.bind_variable(v_inv_cursor,':b_segval3_low',v_segval3_low);
		dbms_sql.bind_variable(v_inv_cursor,':b_segval3_high',v_segval3_high);
	End if;

    Exception
	When Others Then
            v_error_code := sqlcode ;
            v_error_mesg := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
    End ;


	dbms_sql.define_column(v_inv_cursor, 1, v_invnum,50);
	dbms_sql.define_column(v_inv_cursor, 2, v_invdate);
	dbms_sql.define_column(v_inv_cursor, 3, v_invamt);
	dbms_sql.define_column(v_inv_cursor, 4, v_invccid);
	dbms_sql.define_column(v_inv_cursor, 5, v_inv_po_distribution_id);
	dbms_sql.define_column(v_inv_cursor, 6, v_seg_val1,25);

	if(v_segval2 is not null) then
	    dbms_sql.define_column(v_inv_cursor, 7, v_seg_val2,25);
	End if;

	if(v_segval3 is not null) then
	    dbms_sql.define_column(v_inv_cursor, 8, v_seg_val3,25);
	End if;


	Begin
	    v_exec_ret := dbms_sql.execute(v_inv_cursor);
    	Exception
	    When Others Then
                v_error_code := sqlcode ;
                v_error_mesg := sqlerrm ;
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
    	End ;

	Loop
	   if dbms_sql.fetch_rows(v_inv_cursor) = 0 then
		exit;
	   else
		dbms_sql.column_value(v_inv_cursor, 1, v_invnum);
		dbms_sql.column_value(v_inv_cursor, 2, v_invdate);
		dbms_sql.column_value(v_inv_cursor, 3, v_invamt);
		dbms_sql.column_value(v_inv_cursor, 4, v_invccid);
		dbms_sql.column_value(v_inv_cursor, 5,
						v_inv_po_distribution_id);
		dbms_sql.column_value(v_inv_cursor, 6, v_seg_val1);

		if(v_segval2 is not null) then
		    dbms_sql.column_value(v_inv_cursor, 7, v_seg_val2);
		End if;

		if(v_segval3 is not null) then
		    dbms_sql.column_value(v_inv_cursor, 8, v_seg_val3);
		End if;

	   end if;

	   -- Look for Purchase Order for the Invoice
	   If (v_inv_po_distribution_id IS NOT NULL )  then
	        -- PO Exists, Get the PO Information
		Begin
	   	    select poh.segment1,
		    	   pod.gl_encumbered_date,
			   (pod.quantity_ordered -
				nvl(pod.quantity_cancelled,0))
				* Nvl(pol.unit_price, 0),
			   pol.closed_code,
			   pod.code_combination_id ,
			   pod.req_distribution_id,
			   pod.po_distribution_id

		   Into	v_oblignum ,
			   v_obligdate ,
			   v_obligamt	,
			   v_obligstatus ,
			   v_obligccid	,
			   v_po_req_distribution_id,
			   v_po_distribution_id

		   from  po_headers poh,
			   po_lines pol,
			   po_line_locations poll,
			   po_distributions pod,
			   gl_code_combinations glcc

		   where poh.approved_flag = 'Y'
		   and pod.po_distribution_id = v_inv_po_distribution_id
		   and poh.po_header_id = pol.po_header_id
	  	   and pol.po_line_id   = poll.po_line_id
	  	   and poll.line_location_id   = pod.line_location_id
		   and pod.code_combination_id = glcc.code_combination_id
	  	   and pod.set_of_books_id = v_set_of_books_id
		   and not exists
        	       (select 1
        	       from po_headers A
        	       where A.segment1 = poh.segment1
        	       and poh.type_lookup_code = 'PLANNED'
        	       and pod.source_distribution_id is NULL);
/*                   and not exists
                       (select 2
                       from fv_status_oblig_temp
                       where inv_po_distribution_id = pod.po_distribution_id) ;*/

                    Open c1_duplicate_PO(v_inv_po_distribution_id);
                    Fetch c1_duplicate_PO Into l_po_duplicate;
                    If c1_duplicate_PO%FOUND Then
                          v_obligamt := 0 ;
                          v_reqamt := 0 ;
                    End if;
                    Close c1_duplicate_PO;

		Exception
                   When No_Data_Found Then
                        v_obligamt := 0 ;
                        v_reqamt := 0 ;
                        v_oblignum  := Null ;
                     	v_obligdate := Null ;
             	        v_obligccid := Null ;
                	v_obligstatus  := Null ;
        	        v_po_distribution_id := Null ;

                   When TOO_MANY_ROWS Then
                       	v_error_code := sqlcode ;
                       	v_error_mesg :=
				'More than one PO Distribution rows found for
				the Invoice Distribution id - ' ||
                                to_char(v_inv_po_distribution_id) ;
                   When Others Then
                   	v_error_code := sqlcode ;
                       	v_error_mesg := sqlerrm ;
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
		End ;


	       If v_po_req_distribution_id is NOT NULL Then

		    -- Requisition Exists, Look for Requisitions
		    Begin
		       Select porh.segment1,
		 	    pord.gl_encumbered_date,
		       	    (porl.quantity - nvl(porl.quantity_cancelled,0))
			    	* porl.unit_price,
			     pord.code_combination_id

		       Into v_reqnum ,
			    v_reqdate ,
			    v_reqamt,
			    v_reqccid

		       from po_requisition_headers porh,
			    po_requisition_lines porl,
			    po_req_distributions pord,
			    gl_code_combinations glcc

		       where pord.distribution_id = v_po_req_distribution_id
		       and   porh.requisition_header_id =
						porl.requisition_header_id
		       and   porl.requisition_line_id =
						pord.requisition_line_id
		       and   pord.code_combination_id =
						glcc.code_combination_id;
/*                       and not exists
                           (select 1
                           from fv_status_oblig_temp
                           where po_req_distribution_id =
                           	             v_po_req_distribution_id ) ;*/

                    	Open c2_duplicate_req(v_po_req_distribution_id);
                        Fetch c2_duplicate_req Into l_req_duplicate;
       	                If c2_duplicate_req%FOUND Then
                        	  v_reqamt := 0 ;
                        End if;
        	        Close c2_duplicate_req;

                    Exception

                       	When No_Data_Found Then
                           v_reqamt := 0 ;
              		   v_reqnum  := Null ;
                           v_reqdate := Null ;
        		   v_reqccid := Null ;
                       	When TOO_MANY_ROWS Then
                      	    v_error_code := sqlcode ;
                      	    v_error_mesg :=
                           	     'More than one REQ Distribution rows
					found for the PO Distribution id - ' ||
                            to_char(v_po_req_distribution_id) ;
                   	When Others Then
                        	v_error_code := sqlcode ;
                        	v_error_mesg := sqlerrm ;
                            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
                    End ;

	   	Else
			-- Requisition does not exist, Reset the variables.
        		v_reqnum  := Null ;
        		v_reqdate := Null ;
        		v_reqamt  := Null ;
        		v_reqccid := Null ;

	     	End If ;

	   Else

		-- PO Does not exist reset both req and po information
        	v_oblignum  := Null ;
        	v_obligdate := Null ;
        	v_obligamt  := Null ;
        	v_obligccid := Null ;
        	v_obligstatus  	     := Null ;
        	v_po_distribution_id := Null ;

        	v_reqnum  := Null ;
        	v_reqdate := Null ;
        	v_reqamt  := Null ;
        	v_reqccid := Null ;
		v_po_req_distribution_id := Null ;

	   End If ;

	   -- For reversal invoices, obligation and requisition amounts needs to
	   -- be reported only once
	   If v_reversal_flag = 'Y' and v_invamt < 0 then
		v_obligamt := 0 ;
		v_reqamt := 0 ;
	   End If ;

	   Insert_Processing ;

	end loop;

	Begin
	    dbms_sql.close_cursor(v_inv_cursor);
   	Exception
           When Others then
           	v_error_code := sqlcode ;
           	v_error_mesg := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
   	End ;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
End process_invoices ;

----------------------------------------------------------------------
--			BUILD_WHERE_CLAUSE
----------------------------------------------------------------------
Procedure build_where_clause is
l_module_name varchar2(200) := g_module_name || 'build_where_clause';
l_errbuf varchar2(300);
Begin

	-- Build the optional where clause
	v_where :=  ' and (' || v_segval1 ||' between :b_segval1_low and
			:b_segval1_high ' || ')' ;

	v_val_string := ',' ||  v_segval1;

	If v_segval2 is NOT NULL Then
		v_where := v_where || ' and (' || v_segval2 ||
			' between :b_segval2_low and :b_segval2_high ' || ')' ;

		v_val_string := v_val_string ||  ',' ||  v_segval2;
	End If ;

	If v_segval3 is NOT NULL Then
		v_where := v_where || ' and (' || v_segval3 ||
			' between :b_segval3_low and :b_segval3_high ' || ')' ;

		v_val_string := v_val_string ||  ',' ||  v_segval3;
	End If ;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
End build_where_clause ;



----------------------------------------------------------------------
--			PROCESS_POS
----------------------------------------------------------------------
Procedure  Process_pos is

	l_po_exists	Varchar2(1) := 'N' ;
	l_req_distribution_id Number ;
    l_module_name varchar2(200) := g_module_name || 'process_pos';
    l_errbuf varchar2(300);
Begin

   Begin
       v_po_cursor := DBMS_SQL.OPEN_CURSOR  ;
   Exception
       When Others then
           v_error_code := sqlcode ;
           v_error_mesg := sqlerrm ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
   End ;

   v_invnum	:= NULL ;
   v_invdate 	:= NULL ;
   v_invamt	:= NULL ;
   v_invccid	:= NULL ;
   v_inv_po_distribution_id := NULL ;

   -- Get all the Purchase Orders
   v_po_select :=
   'select poh.segment1 ,
	pod.gl_encumbered_date,
	(pod.quantity_ordered - nvl(pod.quantity_cancelled,0))
			* nvl(pol.unit_price, 0) obligamt ,
	pol.closed_code,
	pod.code_combination_id,
	pod.req_distribution_id,
	pod.po_distribution_id' || v_val_string ||
   ' from po_headers poh,
	  po_lines pol,
	  po_line_locations poll,
	  po_distributions pod,
	  gl_code_combinations glcc
   where
	NOT EXISTS( Select 1
		    from fv_status_oblig_temp fvs
		    where fvs.po_distribution_id = pod.po_distribution_id)
	and poh.approved_flag = '||''''||'Y'||''''||
     '  and poh.po_header_id = pol.po_header_id
  	and pol.po_line_id = poll.po_line_id
  	and poll.line_location_id = pod.line_location_id
        and not exists
                (select 1
                from po_headers A
                where A.segment1 = poh.segment1
                and poh.type_lookup_code = '||''''||'PLANNED'||''''||
                ' and pod.source_distribution_id is NULL)
  	and pod.set_of_books_id = :b_set_of_books_id
  	and glcc.code_combination_id = pod.code_combination_id
	and pod.gl_encumbered_date between :b_from_period and :b_to_period '||  v_where ;


	/*----------------- TESTING ------------------------
	Insert into surya_temp values('PO', v_po_select) ;
	----------------- TESTING ------------------------ */

   Begin
   	dbms_sql.parse(v_po_cursor, v_po_select, DBMS_SQL.V7) ;
   	dbms_sql.bind_variable(v_po_cursor,':b_from_period',v_from_period);
	dbms_sql.bind_variable(v_po_cursor,':b_to_period',v_to_period);
	dbms_sql.bind_variable(v_po_cursor,':b_set_of_books_id',v_set_of_books_id);

	dbms_sql.bind_variable(v_po_cursor,':b_segval1_low',v_segval1_low);
	dbms_sql.bind_variable(v_po_cursor,':b_segval1_high',v_segval1_high);

	If v_segval2 is NOT NULL Then
		dbms_sql.bind_variable(v_po_cursor,':b_segval2_low',v_segval2_low);
		dbms_sql.bind_variable(v_po_cursor,':b_segval2_high',v_segval2_high);
	End if;

	If v_segval3 is NOT NULL Then
		dbms_sql.bind_variable(v_po_cursor,':b_segval3_low',v_segval3_low);
		dbms_sql.bind_variable(v_po_cursor,':b_segval3_high',v_segval3_high);
	End if;

   Exception
        When Others then
           v_error_code := sqlcode ;
           v_error_mesg := sqlerrm ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
   End ;


   dbms_sql.define_column(v_po_cursor, 1, v_oblignum, 50);
   dbms_sql.define_column(v_po_cursor, 2, v_obligdate);
   dbms_sql.define_column(v_po_cursor, 3, v_obligamt);
   dbms_sql.define_column(v_po_cursor, 4, v_obligstatus, 25);
   dbms_sql.define_column(v_po_cursor, 5, v_obligccid);
   dbms_sql.define_column(v_po_cursor, 6, v_po_req_distribution_id);
   dbms_sql.define_column(v_po_cursor, 7, v_po_distribution_id);
	dbms_sql.define_column(v_po_cursor, 8, v_seg_val1,25);
	if(v_segval2 is not null) then
	dbms_sql.define_column(v_po_cursor, 9, v_seg_val2,25);
	End if;
	if(v_segval3 is not null) then
	dbms_sql.define_column(v_po_cursor, 10, v_seg_val3,25);
	End if;

   Begin
   	v_exec_ret := dbms_sql.execute(v_po_cursor);
   Exception
        When Others then
           v_error_code := sqlcode ;
           v_error_mesg := sqlerrm ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
   End ;


   loop
      if dbms_sql.fetch_rows(v_po_cursor) = 0 then
	   exit;
	else

	   dbms_sql.column_value(v_po_cursor, 1, v_oblignum);
	   dbms_sql.column_value(v_po_cursor, 2, v_obligdate);
	   dbms_sql.column_value(v_po_cursor, 3, v_obligamt);
	   dbms_sql.column_value(v_po_cursor, 4, v_obligstatus);
	   dbms_sql.column_value(v_po_cursor, 5, v_obligccid);
	   dbms_sql.column_value(v_po_cursor, 6,
						v_po_req_distribution_id);
   	   dbms_sql.column_value(v_po_cursor, 7, v_po_distribution_id);
		dbms_sql.column_value(v_po_cursor, 8, v_seg_val1);
		if(v_segval2 is not null) then
		dbms_sql.column_value(v_po_cursor, 9, v_seg_val2);
		End if;
		if(v_segval3 is not null) then
		dbms_sql.column_value(v_po_cursor, 10, v_seg_val3);
		End if;

	end if;


	If v_po_req_distribution_id is NOT NULL Then

	   Begin
	      -- Requisition Exists, Look for Requisitions
		Select porh.segment1,
			 pord.gl_encumbered_date,
	            (porl.quantity - nvl(porl.quantity_cancelled,0))
			    * porl.unit_price ,
			 pord.code_combination_id

		Into	v_reqnum ,
			v_reqdate ,
			v_reqamt,
			v_reqccid

		from  po_requisition_headers porh,
			po_requisition_lines porl,
			po_req_distributions pord,
			gl_code_combinations glcc

		where pord.distribution_id = v_po_req_distribution_id
		and   porh.requisition_header_id = porl.requisition_header_id
		and   porl.requisition_line_id = pord.requisition_line_id
		and   pord.code_combination_id = glcc.code_combination_id ;

          Exception

                   When No_Data_Found Then
                        Null ;

                   When TOO_MANY_ROWS Then
                      v_error_code := sqlcode ;
                      v_error_mesg :=
                           'More than one REQ Distribution rows found for the
                           PO Distribution id - ' ||
                                to_char(v_po_req_distribution_id) ;
                   When Others Then
                        v_error_code := sqlcode ;
                        v_error_mesg := sqlerrm ;
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);

           End ;
	Else
                v_reqnum  := Null ;
                v_reqdate := Null ;
                v_reqamt  := Null ;
                v_reqccid := Null ;

	End If ;

	Insert_Processing ;

   end loop;

   Begin
       dbms_sql.close_cursor(v_po_cursor);
   Exception
        When Others then
           v_error_code := sqlcode ;
           v_error_mesg := sqlerrm ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',v_error_mesg);
   End ;

EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
End process_pos ;


----------------------------------------------------------------------
--				INSERT_PROCESSING
----------------------------------------------------------------------
Procedure Insert_processing is
l_module_name varchar2(200) := g_module_name || 'insert_processing';
l_errbuf varchar2(300);
Begin
	   -- Perform the Inserts
	   insert into fv_status_oblig_temp
		(REQNUM                        ,
		REQDATE                        ,
		REQAMT                         ,
		REQCCID                        ,
		OBLIGNUM                       ,
		OBLIGDATE                      ,
		OBLIGAMT                       ,
		OBLIGCCID                      ,
		OBLIGSTATUS 			 ,
		INVNUM                         ,
		INVDATE                        ,
		INVAMT                         ,
		INVCCID                        ,
		segval1                        ,
		segval2                        ,
		segval3                        ,
		INV_PO_DISTRIBUTION_ID         ,
		PO_REQ_DISTRIBUTION_ID         ,
		PO_DISTRIBUTION_ID		)
	   values
		(v_reqnum ,
		v_reqdate ,
		v_reqamt  ,
		v_reqccid ,
		v_oblignum ,
		v_obligdate ,
		v_obligamt ,
		v_obligccid ,
		v_obligstatus,
		v_invnum ,
		v_invdate ,
		v_invamt ,
		v_invccid,
		v_seg_val1,
		v_seg_val2,
		v_seg_val3,
		v_inv_po_distribution_id,
		v_po_req_distribution_id,
		v_po_distribution_id     ) ;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
End Insert_Processing ;

-----------------------------------------------------------------
--				End Of the Package
-----------------------------------------------------------------
End fv_status_of_obligations ;


/
