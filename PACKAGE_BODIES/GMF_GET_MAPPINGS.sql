--------------------------------------------------------
--  DDL for Package Body GMF_GET_MAPPINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GET_MAPPINGS" AS
/* $Header: gmfactmb.pls 115.27 2003/05/21 20:34:01 sschinch ship $ */

    /* Declarations for AR merge                             */

    TYPE A_seg_len IS TABLE OF gl_plcy_seg.length%TYPE INDEX BY BINARY_INTEGER;

    GA_of_seg		A_segment;
    GA_of_seg_len	A_seg_len;
    GA_of_seg_pos	A_seg_len;
    sv_co_code		sy_orgn_mst.co_code%TYPE := 'x';


    Gn_of_seg	NUMBER := -1;

   /* Coming functions compare are special function
   REM to help compare the column value with a given value.
   REM Used for searching a right account.
   REM                                                      */

    FUNCTION IsEmpty(p_str IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
	/* B1043070: No change for "rtrim", we want char stripping from right  */

	IF ( p_str IS NULL OR RTRIM(p_str) IS NULL )
	THEN
	    RETURN(TRUE);
	ELSE
	    RETURN (FALSE);
	END IF;
    END;


    FUNCTION fstrcmp(p_col IN VARCHAR2, p_val IN VARCHAR2) RETURN NUMBER IS
    BEGIN
	IF (p_col = p_val OR p_col IS NULL OR p_col = ' ')
	THEN
	    RETURN (1);
	ELSE
	    RETURN (0);
	END IF;
    END;

    FUNCTION fnumcmp(p_col IN NUMBER, p_val IN NUMBER) RETURN NUMBER IS
    BEGIN
	IF (p_col = p_val OR p_col IS NULL OR p_col = 0 )
	THEN
	    RETURN (1);
	ELSE
	    RETURN (0);
	END IF;
    END;

    /*##################################################
    #  NAME get_account_mappings
    #
    #  SYNOPSIS
    #    Proc get_account_mappings
    #    Parms
    #  DESCRIPTION
    #    Fetches the account mapping for AR update Package.
    #    GMFARUPD
    #  HISTORY
    #   11-Sep-2001 Uday Moogala  Bug 2031374 - New Item Attributes
    #     Added two new item attributes - GL Business Class and GL Product Line
    #     as input parameters to get_account_mappings procedures.
    #     Also made other changes required to incorporate this feature at
    #     various places. Search with bug# for changes made
    #   11-Oct-2001 Uday Moogala  Bug 2468912 - New Attribute
    #     Added a new attribute Line Type as input parameters to
    #     get_account_mappings procedures. Search with bug# for changes made
    #   22-Oct-2001 Uday Moogala  Bug 2423983 - New Attribute
    #     Added a new attribute AR Trans Type as input parameters to
    #     get_account_mappings procedures. Search with bug# for changes made
    ################################################### */

    PROCEDURE get_account_mappings (
		v_co_code 		IN OUT NOCOPY VARCHAR2,
		v_orgn_code 		VARCHAR2,
		v_whse_code 		VARCHAR2,
		v_item_id   		NUMBER,
		v_vendor_id 		NUMBER,
		v_cust_id   		NUMBER,
		v_reason_code 		VARCHAR2,
		v_icgl_class           	VARCHAR2,
		v_vendgl_class         	VARCHAR2,
		v_custgl_class         	VARCHAR2,
		v_currency_code        	VARCHAR2,
		v_routing_id           	NUMBER,
		v_charge_id		NUMBER,
		v_taxauth_id           	NUMBER,
		v_aqui_cost_id		NUMBER,
		v_resources		VARCHAR2,
		v_cost_cmpntcls_id     	NUMBER,
		v_cost_analysis_code   	VARCHAR2,
		v_order_type		NUMBER,
		v_sub_event_type       	NUMBER,
		v_acct_ttl_type		NUMBER,
		v_acct_id		IN OUT NOCOPY NUMBER,
		v_acctg_unit_id		IN OUT NOCOPY NUMBER,
		v_source		NUMBER DEFAULT 0,
		v_business_class_cat_id	NUMBER DEFAULT 0,	-- Bug 2031374 - umoogala
		v_product_line_cat_id	NUMBER DEFAULT 0,	-- Bug 2031374 - umoogala
		v_line_type		NUMBER DEFAULT NULL, 	-- Bug 2468912 - umoogala
		v_ar_trx_type_id	NUMBER DEFAULT 0	-- Bug 2423983 - umoogala
		)
    IS
	X_sqlstmt        VARCHAR2(2000);
	X_sqlwhere       VARCHAR2(2000);
	X_sqlwhere1      VARCHAR2(2000) DEFAULT '';
	x_order_by       gmf_get_mappings.my_order_by;
	X_my_order_by    VARCHAR2(200);
	X_sqlwhere2      VARCHAR2(2000);
	X_sqlwhere3      VARCHAR2(2000);
	X_sqlwhere4      VARCHAR2(2000);
	X_sqlwhere5      VARCHAR2(2000);
	X_sqlwhere6      VARCHAR2(2000);
	X_sqlcolumns     VARCHAR2(2000);
	X_sqlcolumns1    VARCHAR2(2000);
	X_sqlcolumns2    VARCHAR2(2000);
	X_acct_id        gl_acct_mst.acct_id%TYPE;
	X_sqlordby       VARCHAR2(1000);
	X_tmp1           NUMBER(10);
	X_cursor_handle  INTEGER;
	i                INTEGER DEFAULT 0;
	X_sqlstmt1       VARCHAR2(2000);	-- Bug 2031374 - umoogala 200 -> 2000
	X_sqlstmt2       VARCHAR2(2000);	-- Bug 2031374 - umoogala 200 -> 2000
	X_num_col        NUMBER(15);
	X_rows_processed NUMBER(15);
	X_whse_orgn      VARCHAR2(4);
	X_map_whse_co    VARCHAR2(4);
	X_map_orgn_co    VARCHAR2(4);
	X_map_orgn_code  VARCHAR2(4);
	X_space          VARCHAR2(10) := ' ';


	x_co_code        sy_orgn_mst.co_code%TYPE;
	CURSOR Cur_get_company(v_org_code VARCHAR2) IS
	  SELECT co_code
	    FROM sy_orgn_mst
	  WHERE  orgn_code = v_org_code;

	CURSOR Cur_get_whse_orgn(v_whs_code VARCHAR2) IS
	  SELECT orgn_code
	  FROM   ic_whse_mst
	  WHERE  whse_code = v_whs_code;
  BEGIN

    /* This cursor fetches the co_code of specified organizaton. */

    IF (v_orgn_code IS NOT NULL) THEN
      OPEN Cur_get_company(v_orgn_code);
      FETCH Cur_get_company INTO X_map_orgn_co;
      CLOSE Cur_get_company;
    END IF;

    IF (v_whse_code IS NOT NULL) THEN
      OPEN Cur_get_whse_orgn(v_whse_code);
      FETCH Cur_get_whse_orgn INTO X_whse_orgn;
      CLOSE Cur_get_whse_orgn;
    END IF;

    IF (X_whse_orgn IS NOT NULL) THEN
      OPEN Cur_get_company(X_whse_orgn);
      FETCH Cur_get_company INTO X_map_whse_co;
      CLOSE Cur_get_company;
    END IF;

    i := 0;
    /* Get the priorities for the Account Title
    REM ---------------------------------------- */

    FOR Cur_subevtacct_ttl IN (
			SELECT map_orgn_ind, acct_ttl_type
			FROM gl_sevt_ttl
			WHERE sub_event_type = v_sub_event_type
			  AND acct_ttl_type = v_acct_ttl_type)
    LOOP

	/* VC - Bug 1498503 */
        IF (Cur_subevtacct_ttl.map_orgn_ind = 1) THEN
          X_map_orgn_code := V_orgn_code;
          X_co_code :=   X_map_orgn_co;
        ELSE
          X_co_code := X_map_whse_co;
          X_map_orgn_code := X_whse_orgn;
        END IF;

	IF ( IsEmpty(X_co_code) )
	THEN
		X_co_code := v_co_code;
	END IF;
	v_co_code := X_co_code;

	IF ( IsEmpty(X_map_orgn_code) )
	THEN
		X_map_orgn_code := v_orgn_code;
	END IF;

       --X_sqlstmt := 'SELECT NVL(co_code,'' ''),orgn_code_pri, whse_code_pri,icgl_class_pri, custgl_class_pri,vendgl_class_pri ,item_pri,customer_pri, vendor_pri,tax_auth_pri,';

       X_sqlstmt := 'SELECT NVL(co_code,'' ''),orgn_code_pri, whse_code_pri,icgl_class_pri, custgl_class_pri,vendgl_class_pri ,item_pri,customer_pri, vendor_pri,tax_auth_pri,';

       --
       -- Bug 2031374 - umoogala : Added gl_business_class_pri and gl_product_line_pri
       -- Bug 2468912 - umoogala : Added line_type_pri
       -- Bug 2423983 - umoogala : Added ar_trx_type_pri
       --
       X_sqlstmt1 := 'charge_pri,currency_code_pri, reason_code_pri,routing_pri, aqui_cost_code_pri,resource_pri, ' ||
			'cost_cmpntcls_pri,cost_analysis_pri, order_type_pri, gl_business_class_pri, gl_product_line_pri, line_type_pri, ar_trx_type_pri FROM gl_acct_hrc ';

      --X_sqlstmt2 :=   ' WHERE  acct_ttl_type = '||to_char(Cur_subevtacct_ttl.acct_ttl_type) || ' AND gmf_get_mappings.fstrcmp(co_code,'''||v_co_code||''')=1 AND delete_mark = 0 ORDER BY 1 desc';

      X_sqlstmt2 :=   ' WHERE  acct_ttl_type = :pacct_ttl_type AND (co_code IS NULL OR co_code = :pco_code) AND delete_mark = 0 ORDER BY 1 desc';


       X_cursor_handle := DBMS_SQL.OPEN_CURSOR;

       DBMS_SQL.PARSE(X_cursor_handle,X_sqlstmt||X_sqlstmt1||X_sqlstmt2,DBMS_SQL.V7);

       --DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pspace',x_space);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pacct_ttl_type',Cur_subevtacct_ttl.acct_ttl_type);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pco_code',v_co_code);

       -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
       -- Bug 2423983: 22 to 23
       FOR k IN 2..23 LOOP
         DBMS_SQL.DEFINE_COLUMN(X_cursor_handle,k,x_tmp1);
       END LOOP;
       X_rows_processed := DBMS_SQL.EXECUTE(X_cursor_handle);

       /* selecting the acct_id in gl_acct_map
          create the order_by based on the priority retrieved above.
          company is always the first column selected */

       -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
       -- Bug 2423983: 22 to 23
        FOR z IN 1..23 LOOP
           X_order_by(z) := 0;
        END LOOP;

        X_my_order_by := 'ORDER BY 1 desc';

        IF (DBMS_SQL.FETCH_ROWS(X_cursor_handle) > 0)  THEN
          -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
          -- Bug 2423983: 22 to 23
          FOR j IN 2..23 LOOP
            DBMS_SQL.COLUMN_VALUE(X_cursor_handle,j,x_tmp1);
            IF (X_tmp1 > 0) THEN
              x_tmp1:=x_tmp1 + 1;
              X_order_by(x_tmp1) := j;
            END IF;
          END LOOP;
        END IF;

        -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
        -- Bug 2423983: 22 to 23
        FOR z IN 2..23 LOOP
          IF (X_order_by(z) > 0) THEN
            X_my_order_by := X_my_order_by||','||to_char(x_order_by(z))||' desc ';
          END IF;
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR(X_cursor_handle);

/*         X_sqlwhere := 'WHERE acct_ttl_type = '||to_char(Cur_subevtacct_ttl.acct_ttl_type)||
		   ' AND gmf_get_mappings.fstrcmp(co_code, ''' || X_co_code || ''')=1' ||
		   ' AND gmf_get_mappings.fstrcmp(whse_code, ''' || v_whse_code || ''')=1'; */

           X_sqlwhere := 'WHERE acct_ttl_type = :pacct_ttl_type AND (co_code IS NULL OR co_code = :pco_code) '||
		    ' AND (whse_code IS NULL OR whse_code = :pwhse_code) ';

	    /*X_sqlwhere1:= ' AND gmf_get_mappings.fstrcmp(orgn_code, ''' || X_map_orgn_code || ''')=1' ||
		   ' AND gmf_get_mappings.fnumcmp(item_id, ' || NVL(v_item_id, 0) || ')=1 ' ||
		   ' AND gmf_get_mappings.fnumcmp(vendor_id, ' || NVL(v_vendor_id,0) || ')=1 ' ; */

            X_sqlwhere1:= ' AND (orgn_code IS NULL OR orgn_code = :pmap_orgn_code ) '||
		     ' AND (item_id IS NULL OR item_id = :pitem_id) AND (vendor_id IS NULL OR vendor_id = :pvendor_id) ' ;


     /*    X_sqlwhere2:= ' AND gmf_get_mappings.fnumcmp(cust_id, ' || NVL(v_cust_id,0) || ')=1' ||
		   ' AND gmf_get_mappings.fstrcmp(reason_code, ''' || v_reason_code || ''')=1' ||
		   ' AND gmf_get_mappings.fstrcmp(icgl_class, ''' || v_icgl_class || ''')=1'; */

           X_sqlwhere2:= ' AND (cust_id IS NULL OR cust_id = :pcust_id)  '||
		         ' AND (reason_code IS NULL OR reason_code = :preason_code) '||
		         ' AND (icgl_class IS NULL OR icgl_class = :picgl_class) ';


       /*  X_sqlwhere3:=   ' AND gmf_get_mappings.fstrcmp(vendgl_class, ''' || v_vendgl_class || ''')=1' ||
		   ' AND gmf_get_mappings.fstrcmp(custgl_class, ''' || v_custgl_class || ''')=1'; */

           X_sqlwhere3:=   ' AND (vendgl_class IS NULL OR vendgl_class = :pvendgl_class) '||
             		   ' AND (custgl_class IS NULL OR custgl_class = :pcustgl_class) ';


       /*  X_sqlwhere4:=   ' AND gmf_get_mappings.fstrcmp(currency_code, '''||v_currency_code||''')=1' ||
		     ' AND gmf_get_mappings.fnumcmp(routing_id, '||nvl(v_routing_id,0)||')=1'; */

           X_sqlwhere4:=   ' AND (currency_code IS NULL OR currency_code = :pcurrency_code) '||
 	         	         ' AND (routing_id IS NULL OR routing_id = :prouting_id) ';

        /* X_sqlwhere5:=   ' AND gmf_get_mappings.fnumcmp(charge_id, '||nvl(v_charge_id,0)||')=1' ||
		     ' AND gmf_get_mappings.fnumcmp(taxauth_id, '||nvl(v_taxauth_id,0)||')=1' ||
		     ' AND gmf_get_mappings.fnumcmp(aqui_cost_id, '||nvl(v_aqui_cost_id,0)||')=1' ; */

          X_sqlwhere5:=   ' AND (charge_id IS NULL OR charge_id = :pcharge_id) ' ||
		     ' AND (taxauth_id IS NULL OR taxauth_id = :ptaxauth_id) ' ||
		     ' AND (aqui_cost_id IS NULL OR aqui_cost_id = :paqui_cost_id) ' ;

  /*	X_sqlwhere6 := 	 ' AND gmf_get_mappings.fstrcmp(resources, '''||v_resources||''')=1' ||
		     ' AND gmf_get_mappings.fnumcmp(cost_cmpntcls_id, '||nvl(v_cost_cmpntcls_id,0)||')=1' ||
		     ' AND gmf_get_mappings.fstrcmp(cost_analysis_code, '''||v_cost_analysis_code||''')=1' ||
		     ' AND  delete_mark = 0 '; */

       X_sqlwhere6 :=  ' AND (resources IS NULL OR resources = :presources) ' ||
 			     ' AND (cost_cmpntcls_id IS NULL OR cost_cmpntcls_id = :pcost_cmpntcls_id) ' ||
			     ' AND (cost_analysis_code IS NULL OR cost_analysis_code = :pcost_analysis_code) ' ||
			     ' AND  delete_mark = 0 ';

	/**
	* RS B1408077 Based on the source passed add condition on the source type column
	*/
	IF( (v_order_type IS NOT NULL) AND (v_order_type <> 0 ) )
	THEN

		IF( v_source = 11 )
		THEN
                        /* Bug 2431861
                        X_sqlwhere6 := X_sqlwhere6 || ' AND ( source_type = 11 ' ||
                                ' AND gmf_get_mappings.fnumcmp(order_type, '||nvl(v_order_type,0)||')=1  ) ';

                         X_sqlwhere6 := X_sqlwhere6 || ' AND (( source_type = 11 ' ||
                                ' AND order_type      = '||to_char(nvl(v_order_type,0))||')'||' OR order_type IS NULL)'; */

                        X_sqlwhere6 := X_sqlwhere6 || ' AND ( source_type = 11 ' ||
                                ' AND (order_type = :porder_type OR order_type IS NULL))';

		ELSE
/*			X_sqlwhere6 := X_sqlwhere6 || ' AND ( source_type IS NULL ' ||
				' AND gmf_get_mappings.fnumcmp(order_type, '||nvl(v_order_type,0)||')=1  ) '; */

			X_sqlwhere6 := X_sqlwhere6 || ' AND ( source_type IS NULL ' ||
				' AND (order_type IS NULL OR order_type = :porder_type)) ';


		END IF;

	ELSE
		/* Do it as before */
--		X_sqlwhere6 := X_sqlwhere6 || ' AND gmf_get_mappings.fnumcmp(order_type, '||nvl(v_order_type,0)||')=1  ';
		X_sqlwhere6 := X_sqlwhere6 || ' AND (order_type IS NULL OR order_type = :porder_type) ';

	END IF;
	/* End B1408077 */

       /*
       * Bug 2031374 - umoogala : Added gl_business_class_pri and gl_product_line_pri
       * Bug 2468912 - umoogala : Added line_type
       * Bug 2423983 - umoogala : Added ar_trx_type_id
       */

/*	X_sqlwhere6 := X_sqlwhere6 ||
			' AND gmf_get_mappings.fnumcmp(gl_business_class_cat_id, ' ||
				nvl(v_business_class_cat_id,0)||')=1  ' ||
  			' AND gmf_get_mappings.fnumcmp(gl_product_line_cat_id, ' ||
     				nvl(v_product_line_cat_id,0)||')=1  ' ||
  			' AND gmf_get_mappings.fnumcmp(line_type, ' ||
     				nvl(v_line_type,0)||')=1  ' ||
  			' AND gmf_get_mappings.fnumcmp(ar_trx_type_id, ' ||
     				nvl(v_ar_trx_type_id,0)||')=1  ' ; */

X_sqlwhere6 := X_sqlwhere6 ||
			' AND (gl_business_class_cat_id IS NULL OR gl_business_class_cat_id = :pbusiness_class_cat_id) ' ||
  			' AND (gl_product_line_cat_id IS NULL OR gl_product_line_cat_id  = :pproduct_line_cat_id) ' ||
  			' AND (line_type IS NULL OR line_type =  :pline_type) ' ||
  			' AND (ar_trx_type_id IS NULL OR ar_trx_type_id = :par_trx_type_id) ' ;



	/* End Bug 2031374 */

 	   /* Changed the selection of acct_id to be the last column to be
              selected. If not since the order by is by field position no the
              correct acct_id doesnot get picked up if there are more than 1 record  */

       X_sqlcolumns:=   ' SELECT co_code,'||
			    'nvl(orgn_code,'' ''),'||
			    'nvl(whse_code,'' ''),'||
			    'nvl(icgl_class,'' ''),'||
			    'nvl(custgl_class,'' ''),'||
			    'nvl(vendgl_class,'' ''),';

       X_sqlcolumns1:=      'nvl(item_id,0),'||
			    'nvl(cust_id,0),'||
			    'nvl(vendor_id,0),'||
			    'nvl(taxauth_id,0),'||
			    'nvl(charge_id,0),'||
			    'nvl(currency_code,'' ''),'||
			    'nvl(reason_code,'' ''),';

       --
       -- Bug 2468912 - umoogala
       -- here nvl(line_type,-99) is done to sort the values properly in case of
       -- ingredients (line_type = -1).
       -- In case of nvl..0, when we sort, 0 will come first then -1.
       -- nvl..-99 will put null line type after -1. Other values of line type, 1 and 2,
       -- will not have any issue as they are > 0
       --
       X_sqlcolumns2:=	'nvl(routing_id,0),'||
			    'nvl(aqui_cost_id,0),'||
			    'nvl(resources,'' ''),'||
			    'nvl(cost_cmpntcls_id,0),'||
			    'nvl(cost_analysis_code,'' ''),'||
			    'nvl(order_type,0),'||
                 	    'nvl(gl_business_class_cat_id,0), '||  	-- Bug 2031374 - umoogala
                 	    'nvl(gl_product_line_cat_id,0), ' ||	-- Bug 2031374 - umoogala
                 	    'nvl(line_type,-99), ' ||			-- Bug 2468912 - umoogala
                 	    'nvl(ar_trx_type_id,0), ' ||		-- Bug 2423983 - umoogala
			    'acct_id ' ;

       X_sqlordby:= X_my_order_by;

       X_cursor_handle := DBMS_SQL.OPEN_CURSOR;

       DBMS_SQL.PARSE(X_cursor_handle,X_sqlcolumns||X_sqlcolumns1||X_sqlcolumns2||' FROM gl_acct_map '||X_sqlwhere||X_sqlwhere1||X_sqlwhere2||X_sqlwhere3||X_sqlwhere4||X_sqlwhere5||X_sqlwhere6||X_sqlordby,DBMS_SQL.V7);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pacct_ttl_type',Cur_subevtacct_ttl.acct_ttl_type);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pco_code',x_co_code);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pwhse_code',v_whse_code);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pmap_orgn_code',x_map_orgn_code);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pitem_id',v_item_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pvendor_id',v_vendor_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcust_id',v_cust_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':preason_code',v_reason_code);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':picgl_class',v_icgl_class);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pvendgl_class',v_vendgl_class);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcustgl_class',v_custgl_class);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcurrency_code',v_currency_code);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':prouting_id',v_routing_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcharge_id',v_charge_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':ptaxauth_id',v_taxauth_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':paqui_cost_id',v_aqui_cost_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':presources',v_resources);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcost_cmpntcls_id',v_cost_cmpntcls_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcost_analysis_code',v_cost_analysis_code);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':porder_type',v_order_type);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pbusiness_class_cat_id',v_business_class_cat_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pproduct_line_cat_id',v_product_line_cat_id);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pline_type',v_line_type);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':par_trx_type_id',v_ar_trx_type_id);


       -- Bug 2031374 - umoogala : 20 -> 22, Bug 2468912: 22 to 23
       -- Bug 2423983: 23 to 24
       DBMS_SQL.DEFINE_COLUMN(X_cursor_handle,24,x_num_col);
       x_rows_processed := DBMS_SQL.EXECUTE(X_cursor_handle);
       IF (DBMS_SQL.FETCH_ROWS(X_cursor_handle) > 0) THEN
	 i:= i + 1;
	 -- Bug 2031374 - umoogala : 20 -> 22, Bug 2468912: 22 to 23
       -- Bug 2423983: 23 to 24
	 DBMS_SQL.COLUMN_VALUE(X_cursor_handle,24,gmf_get_mappings.my_accounts(i).acct_id);
	 gmf_get_mappings.my_accounts(i).acct_ttl_type := Cur_subevtacct_ttl.acct_ttl_type;
       END IF;
       DBMS_SQL.CLOSE_CURSOR(x_cursor_handle);
   END LOOP;
   no_of_rows := i;

   /* No rows found */
   v_acct_id := -1;

   IF (no_of_rows > 0)
   THEN
     FOR i IN 1..no_of_rows LOOP
       IF (my_accounts(i).acct_ttl_type = v_acct_ttl_type)
       THEN
	 v_acct_id :=NVL(my_accounts(i).acct_id,0);
	 EXIT;
       END IF;
     END LOOP;
   ELSE
     v_acct_id := -2;
   END IF;

    v_acctg_unit_id := -1;
/*    FOR crec IN (SELECT acctg_unit_id
	  FROM gl_accu_map
	  WHERE co_code = X_co_code
	    AND gmf_get_mappings.fstrcmp(orgn_code, X_map_orgn_code) = 1
	    AND gmf_get_mappings.fstrcmp(whse_code, v_whse_code) = 1
	    AND delete_mark = 0
	  ORDER BY nvl(orgn_code,' ') DESC, nvl(whse_code,' ') DESC
	  ) */

      FOR crec IN (SELECT acctg_unit_id
	  FROM gl_accu_map
	  WHERE co_code = X_co_code
	    AND (orgn_code IS NULL OR orgn_code = X_map_orgn_code)
	    AND (whse_code IS NULL OR whse_code = v_whse_code)
	    AND delete_mark = 0
	  ORDER BY nvl(orgn_code,' ') DESC, nvl(whse_code,' ') DESC
	  )
    LOOP
	v_acctg_unit_id := crec.acctg_unit_id;
	EXIT;
    END LOOP;

    sv_gl_acct_map.co_code := v_co_code;
    sv_gl_acct_map.acct_id := v_acct_id;
    sv_acctg_unit_id := v_acctg_unit_id;

 END get_account_mappings;

    /* This procedure parses to maintain the sequence by refernce no.
    REM e.g. segment1, 10, 11, 12 will go to segment 1,2,3,4
    */

    PROCEDURE parse_account(p_co_code VARCHAR2, p_acct IN VARCHAR2, p_of_seg IN OUT NOCOPY A_segment)
    IS
	i NUMBER := 0;
	n NUMBER := 0;
	source_account  my_opm_seg_values;  /* Array of source accounts */
    BEGIN
	i := 1;
        IF (p_acct IS NOT NULL) THEN
          source_account := get_opm_segment_values(p_acct,p_co_code,2);
        END IF;
	IF ( sv_co_code <> p_co_code )
	THEN
	    /* Get the GEMMS to OF account segment mapping information */

	    Gn_of_seg := 0;
	    FOR i IN 1..31
	    LOOP
		GA_of_seg_pos(i) := 0;
		GA_of_seg_len(i) := 0;
	    END LOOP;
	    n := 1;
		/* Stores the current position */
	    FOR crec IN (SELECT
				/* B1043070: Changed "substrb" to "substr", we want
				REM           everything from 8th character and not byte */
				/* B2227050: select f.segment_num instead of f.application_column_name
				REM           order by f.segment_num instead of p.segment_no */
				f.segment_num, p.segment_no, p.length
			FROM
				gl_plcy_seg p,
				gl_plcy_mst pm,
				fnd_id_flex_segments f,
				gl_sets_of_books s
			WHERE
				p.co_code = p_co_code
			  AND	p.delete_mark = 0
			  AND	p.co_code = pm.co_code
			  AND	pm.sob_id = s.set_of_books_id
			  AND	s.chart_of_accounts_id = f.id_flex_num
			  AND	f.application_id = 101
			  AND 	f.id_flex_code = 'GL#'
				  /* B1043070 Changed upper to lower */
			  AND	LOWER(f.segment_name)  = LOWER(p.short_name)
			  AND 	f.enabled_flag         = 'Y'
			ORDER BY f.segment_num)

	    LOOP
		Gn_of_seg := Gn_of_seg + 1;
		/* Bug 2227050
		GA_of_seg_pos(crec.segment_ref) := n;
		GA_of_seg_len(crec.segment_ref) := crec.length;
		*/
		GA_of_seg_pos(Gn_of_seg) := crec.segment_no;
		GA_of_seg_len(Gn_of_seg) := crec.length;
		n := n + 1 ;  /* + crec.length; */
	    END LOOP;
	    sv_co_code := p_co_code;
	END IF;

	FOR i IN 1..31
	LOOP
	    IF ( GA_of_seg_len(i) > 0 )
	    THEN
		/* B1043070: Changed "substrb" to "substr", we want 8th character
		REM GA_of_seg(i) := SUBSTRB(p_acct, GA_of_seg_pos(i), GA_of_seg_len(i));  */
		/* No need to check segment lengths */
		-- GA_of_seg(i) := SUBSTR(p_acct, GA_of_seg_pos(i), GA_of_seg_len(i));
		 GA_of_seg(i)  :=  source_account(GA_of_seg_pos(i));
	    ELSE
		GA_of_seg(i) := NULL;
	    END IF;
	    p_of_seg(i) := GA_of_seg(i);
	END LOOP;
    END parse_account;

    /* DESCRIPTION
    REM  Based on acctg_unit_id acct_id and co_code get the acctg_unit and
    REM  acct_no and separate the segments based on the segment delimiter info
    REM  PCR#9867 - Segments on gemms side and oracle financials need not
    REM	have one to one correspondence. i.e., the first segment in
    REM	gemms might be the 3rd segment in oracle financials. */

   PROCEDURE get_of_seg(p_co_code IN VARCHAR2, p_acct_id NUMBER, p_acctg_unit_id IN NUMBER, p_of_seg IN OUT NOCOPY A_segment, rc IN OUT NOCOPY NUMBER)
    IS
	v_acctg_unit_no	gl_accu_mst.acctg_unit_no%TYPE := NULL;
	v_acct_no	gl_acct_mst.acct_no%TYPE := NULL;
	v_segment_delimiter gl_plcy_mst.segment_delimiter%TYPE;
    BEGIN
	rc := 0;
	SELECT acctg_unit_no INTO v_acctg_unit_no
	FROM gl_accu_mst WHERE acctg_unit_id = p_acctg_unit_id;

	SELECT acct_no INTO v_acct_no
	FROM gl_acct_mst
	WHERE acct_id = p_acct_id;

	SELECT segment_delimiter INTO v_segment_delimiter
	 FROM  gl_plcy_mst
	 WHERE co_code = p_co_code
	     AND delete_mark = 0;

	/* It is ok to use . as delimter, it will be ignored any way */
	/* It is not ok to hard code . as delimiter. Fetch it from policy master. */

/*	parse_account(p_co_code, v_acctg_unit_no || '.' ||  v_acct_no, p_of_seg); */
        parse_account(p_co_code, v_acctg_unit_no || v_segment_delimiter ||  v_acct_no, p_of_seg);
    EXCEPTION
	WHEN OTHERS THEN
	    IF ( v_acctg_unit_no IS NULL )
	    THEN
		rc := -1;	/* error in acctg_unit_no */
	    ELSE
		rc := -2;	/* error in acct_no */
	    END IF;
    END get_of_seg;


  /*##################################################
  #  NAME get_account_mappings
  #
  #  SYNOPSIS
  #    Proc get_account_mappings
  #    Parms
  #  DESCRIPTION
  #     Fetches the accounts defined in account mapping
  #     form.
  #  HISTORY
  #   11-Sep-2001 Uday Moogala  Bug 2031374 - New Item Attributes
  #     Added two new item attributes - GL Business Class and GL Product Line
  #     as input parameters to get_account_mappings procedures.
  #     Also made other changes required to incorporate this feature at
  #     various places. Search with bug# for changes made
  #   11-Oct-2001 Uday Moogala  Bug 2468912 - New Attribute
  #     Added a new attribute Line Type as input parameters to
  #     get_account_mappings procedures. Search with bug# for changes made
  #   22-Oct-2001 Uday Moogala  Bug 2423983 - New Attribute
  #     Added a new attribute AR Trans Type as input parameters to
  #     get_account_mappings procedures. Search with bug# for changes made
  ################################################### */
  PROCEDURE get_account_mappings (v_co_code 		VARCHAR2,
				 v_orgn_code 		VARCHAR2,
				 v_whse_code 		VARCHAR2,
			         v_item_id   		NUMBER,
				 v_vendor_id 		NUMBER,
				 v_cust_id   		NUMBER,
				 v_reason_code 		VARCHAR2,
                                 v_icgl_class           VARCHAR2,
				 v_vendgl_class         VARCHAR2,
				 v_custgl_class         VARCHAR2,
				 v_currency_code        VARCHAR2,
				 v_routing_id           NUMBER,
				 v_charge_id		NUMBER,
				 v_taxauth_id           NUMBER,
				 v_aqui_cost_id		NUMBER,
				 v_resources		VARCHAR2,
				 v_cost_cmpntcls_id     NUMBER,
                                 v_cost_analysis_code   VARCHAR2,
				 v_order_type		NUMBER,
                                 v_sub_event_type       NUMBER,
				 v_source		NUMBER DEFAULT 0,
				 v_business_class_cat_id  NUMBER DEFAULT 0,	-- Bug 2031374 - umoogala
				 v_product_line_cat_id    NUMBER DEFAULT 0,	-- Bug 2031374 - umoogala
				 v_line_type		NUMBER, 		-- Bug 2468912 - umoogala
				 v_ar_trx_type_id	NUMBER DEFAULT 0	-- Bug 2423983 - umoogala
				 ) IS
    X_sqlstmt        VARCHAR2(2000);
    X_sqlwhere       VARCHAR2(2000);
    X_sqlwhere1      VARCHAR2(2000) DEFAULT '';
    x_order_by       gmf_get_mappings.my_order_by;
    X_my_order_by    VARCHAR2(200);
    X_sqlwhere2      VARCHAR2(2000);
    X_sqlwhere3      VARCHAR2(2000);
    X_sqlwhere4      VARCHAR2(2000);
    X_sqlwhere5      VARCHAR2(2000);
    X_sqlwhere6      VARCHAR2(2000);
    X_sqlwhere7      VARCHAR2(2000);
    X_sqlcolumns     VARCHAR2(2000);
    X_sqlcolumns1    VARCHAR2(2000);
    X_sqlcolumns2    VARCHAR2(2000);
    X_acct_id        gl_acct_mst.acct_id%TYPE;
    X_sqlordby       VARCHAR2(1000);
    X_tmp1           NUMBER(10);
    X_cursor_handle  INTEGER;
    i                INTEGER DEFAULT 0;
    X_sqlstmt1       VARCHAR2(2000);         -- Bug 2031374 - umoogala 200 -> 2000
    X_sqlstmt2       VARCHAR2(2000);         -- Bug 2031374 - umoogala 200 -> 2000
    X_num_col        NUMBER(15);
    X_rows_processed NUMBER(15);
    X_whse_orgn      VARCHAR2(4);
    X_map_whse_co    VARCHAR2(4);
    X_map_orgn_co    VARCHAR2(4);
    X_map_orgn_code  VARCHAR2(4);
    x_co_code        sy_orgn_mst.co_code%TYPE;
    CURSOR Cur_sevtacct_ttl IS
      SELECT map_orgn_ind,
	     acct_ttl_type
	FROM gl_sevt_ttl
      WHERE  sub_event_type = v_sub_event_type;

    CURSOR Cur_get_company(v_org_code VARCHAR2) IS
      SELECT co_code
	FROM sy_orgn_mst
      WHERE  orgn_code = v_org_code;

    CURSOR Cur_get_whse_orgn(v_whs_code VARCHAR2) IS
      SELECT orgn_code
      FROM   ic_whse_mst
      WHERE  whse_code = v_whs_code;
  BEGIN
    /* This cursor fetches the co_code of specified organizaton.*/
    IF (v_orgn_code IS NOT NULL) THEN
      OPEN Cur_get_company(v_orgn_code);
      FETCH Cur_get_company INTO X_map_orgn_co;
      CLOSE Cur_get_company;
    END IF;

    IF (v_whse_code IS NOT NULL) THEN
      OPEN Cur_get_whse_orgn(v_whse_code);
      FETCH Cur_get_whse_orgn INTO X_whse_orgn;
      CLOSE Cur_get_whse_orgn;
    END IF;

    IF (X_whse_orgn IS NOT NULL) THEN
      OPEN Cur_get_company(X_whse_orgn);
      FETCH Cur_get_company INTO X_map_whse_co;
      CLOSE Cur_get_company;
    END IF;


    i := 0;
    FOR Cur_subevtacct_ttl IN Cur_sevtacct_ttl LOOP
      /*get the priorities for the account title*/
       X_sqlstmt := 'SELECT '||'NVL(co_code,'||''''||' '||''''||')'||',orgn_code_pri,
		            whse_code_pri,icgl_class_pri,
                            custgl_class_pri,vendgl_class_pri
                            ,item_pri,customer_pri,
 			     vendor_pri,tax_auth_pri,';

       --
       -- Bug 2031374 - umoogala : Added gl_business_class_pri and gl_product_line_pri
       -- Bug 2468912 - umoogala : Added line_type
       -- Bug 2423983 - umoogala : Added ar_trx_type_pri
       --
       X_sqlstmt1 :=       'charge_pri,currency_code_pri,
			     reason_code_pri,routing_pri,
			     aqui_cost_code_pri,resource_pri,
			     cost_cmpntcls_pri,cost_analysis_pri,
      			     order_type_pri, gl_business_class_pri,
			     gl_product_line_pri, line_type_pri, ar_trx_type_pri
			     FROM gl_acct_hrc ';

      /*X_sqlstmt2 :=   ' WHERE  acct_ttl_type = '||to_char(Cur_subevtacct_ttl.acct_ttl_type)||
                             ' AND (co_code = '||''''||v_co_code||''''||' OR co_code IS NULL)'||
                             ' AND delete_mark = 0 ORDER BY 1 desc'; */

       X_sqlstmt2 :=   ' WHERE  acct_ttl_type = :pacct_ttl_type'||
                             ' AND (co_code = :pco_code OR co_code IS NULL) AND delete_mark = 0 ORDER BY 1 desc';

       X_cursor_handle := DBMS_SQL.OPEN_CURSOR;

       DBMS_SQL.PARSE(X_cursor_handle,X_sqlstmt||X_sqlstmt1||X_sqlstmt2,DBMS_SQL.V7);

       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pacct_ttl_type',Cur_subevtacct_ttl.acct_ttl_type);
       DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pco_code',v_co_code);

       -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
       -- Bug 2423983: 22 to 23
       FOR k IN 2..23 LOOP
         DBMS_SQL.DEFINE_COLUMN(X_cursor_handle,k,x_tmp1);
       END LOOP;
        X_rows_processed := DBMS_SQL.EXECUTE(X_cursor_handle);
       /*selecting the acct_id in gl_acct_map
         create the order_by based on the priority retrieved above.
         company is always the first column selected */

         -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
         -- Bug 2423983: 22 to 23
         FOR z IN 1..23 LOOP
           X_order_by(z) := 0;
         END LOOP;

        X_my_order_by := 'ORDER BY 1 desc';

        IF (dbms_sql.fetch_rows(X_cursor_handle) > 0)  THEN
          -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
          -- Bug 2423983: 22 to 23
          FOR j IN 2..23 LOOP
            DBMS_SQL.COLUMN_VALUE(X_cursor_handle,j,x_tmp1);
            IF (X_tmp1 > 0) THEN
              x_tmp1:=x_tmp1 + 1;
              X_order_by(x_tmp1) := j;
            END IF;
          END LOOP;
        END IF;

        -- Bug 2031374 - umoogala : 19 -> 21 for 2 new attributes, Bug 2468912: 21 to 22,
        -- Bug 2423983: 22 to 23
        FOR z IN 2..23 LOOP
          IF (X_order_by(z) > 0) THEN
            X_my_order_by := X_my_order_by||','||to_char(x_order_by(z))||' desc ';
          END IF;
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR(X_cursor_handle);

        IF (Cur_subevtacct_ttl.map_orgn_ind = 1) THEN
          X_map_orgn_code := V_orgn_code;
          X_co_code :=   X_map_orgn_co;
        ELSE
          X_co_code := X_map_whse_co;
          X_map_orgn_code := X_whse_orgn;
        END IF;

        /* X_sqlwhere := 'WHERE acct_ttl_type     = '||to_char(Cur_subevtacct_ttl.acct_ttl_type)||
                       ' AND co_code             = '||''''||NVL(X_co_code,v_co_code)||''''||
                       ' AND (whse_code          = '||''''||v_whse_code||''''||' OR whse_code IS NULL)'; */

           X_sqlwhere := 'WHERE acct_ttl_type  = :pacct_ttl_type '||
                       ' AND co_code           = :pco_code '||
                       ' AND (whse_code        = :pwhse_code OR whse_code IS NULL)';



        /* X_sqlwhere1:= ' AND (orgn_code          = '||''''||nvl(X_map_orgn_code,v_orgn_code)||''''||' OR orgn_code IS NULL )'||
                       ' AND (item_id    	 = '||to_char(nvl(v_item_id,0))||' OR item_id IS NULL)'||
		       ' AND (vendor_id          = '||to_char(nvl(v_vendor_id,0))||' OR vendor_id IS NULL )'; */

         X_sqlwhere1:= ' AND (orgn_code          =  :pmap_orgn_code OR orgn_code IS NULL )'||
                       ' AND (item_id    	 =  :pitem_id OR item_id IS NULL)'||
		       ' AND (vendor_id          =  :pvendor_id OR vendor_id IS NULL )';


/*         X_sqlwhere2:=   ' AND (cust_id        = '||to_char(nvl(v_cust_id,0))||' OR cust_id IS NULL)'||
                       ' AND (reason_code        = '||''''||v_reason_code||''''||' OR reason_code IS NULL)'||
		       ' AND (icgl_class         = '||''''||v_icgl_class||''''||' OR icgl_class IS NULL)'; */

           X_sqlwhere2:= ' AND (cust_id          = :pcust_id OR cust_id IS NULL)'||
                         ' AND (reason_code      = :preason_code OR reason_code IS NULL)'||
		         ' AND (icgl_class       = :picgl_class OR icgl_class IS NULL)';



     /*     X_sqlwhere3:=   ' AND (vendgl_class       = '||''''||v_vendgl_class||''''||' OR vendgl_class IS NULL)'||
		       ' AND (custgl_class      = '||''''||v_custgl_class||''''||' OR custgl_class IS NULL) '; */




         X_sqlwhere3:=   ' AND (vendgl_class    = :pvendgl_class OR vendgl_class IS NULL)'||
		         ' AND (custgl_class    = :pcustgl_class OR custgl_class IS NULL) ';

        /* X_sqlwhere4:=   ' AND (currency_code      = '||''''||v_currency_code||''''||' OR currency_code IS NULL )'||
	   	         ' AND (routing_id         = '||to_char(nvl(v_routing_id,0))||' OR routing_id IS NULL)'; */

         X_sqlwhere4:=   ' AND (currency_code      = :pcurrency_code OR currency_code IS NULL )'||
	   	         ' AND (routing_id         = :prouting_id OR routing_id IS NULL)';


/*         X_sqlwhere5:=   ' AND (charge_id          = '||to_char(nvl(v_charge_id,0))||' OR charge_id IS NULL)'||
     		         ' AND (taxauth_id         = '||to_char(nvl(v_taxauth_id,0))||' OR taxauth_id IS NULL)'||
		         ' AND (aqui_cost_id       = '||to_char(nvl(v_aqui_cost_id,0))||' OR aqui_cost_id IS NULL)'; */


         X_sqlwhere5:=   ' AND (charge_id          = :pcharge_id OR charge_id IS NULL)'||
     		         ' AND (taxauth_id         = :ptaxauth_id OR taxauth_id IS NULL)'||
		         ' AND (aqui_cost_id       = :paqui_cost_id OR aqui_cost_id IS NULL)';


/*         X_sqlwhere6:=   ' AND (resources        = '||''''||v_resources||''''||' OR resources IS NULL)'||
 	                 ' AND (cost_cmpntcls_id   = '||to_char(nvl(v_cost_cmpntcls_id,0))||' OR Cost_cmpntcls_id IS NULL)'||
    	                 ' AND (cost_analysis_code = '||''''||v_cost_analysis_code||''''||' OR cost_analysis_code IS NULL)'; */


    	  X_sqlwhere6:=  ' AND (resources          = :presources OR resources IS NULL)'||
 	                 ' AND (cost_cmpntcls_id   = :pcost_cmpntcls_id OR cost_cmpntcls_id IS NULL)'||
    	                 ' AND (cost_analysis_code = :pcost_analysis_code OR cost_analysis_code IS NULL)';

	 X_sqlwhere7:=   ' AND  delete_mark = 0 ';

	/**
	* RS B1408077 Based on the source passed add condition on the source type column
	*/
	IF( (v_order_type IS NOT NULL) AND (v_order_type <> 0 ) )
	THEN
		IF( v_source = 11 )
		THEN
                        /* Bug 2431861
                        X_sqlwhere7:=  X_sqlwhere7 ||  ' AND ( source_type = 11 AND (order_type = '||
				to_char(nvl(v_order_type,0))||' OR order_type IS NULL) ) ';

                        X_sqlwhere7:=  X_sqlwhere7 || ' AND (( source_type = 11 AND order_type = '||
					to_char(nvl(v_order_type,0))||')'||' OR order_type IS NULL ) '; */

			X_sqlwhere7:=  X_sqlwhere7 || ' AND ((source_type = 11 AND order_type = :porder_type) OR order_type IS NULL ) ';

		ELSE
			/*X_sqlwhere7:=  X_sqlwhere7 ||  ' AND ( source_type IS NULL AND (order_type       = '||to_char(nvl(v_order_type,0))||' OR order_type IS NULL) ) '; */

			X_sqlwhere7:=  X_sqlwhere7 ||  ' AND ((source_type IS NULL AND order_type = :porder_type) OR order_type IS NULL) ';
		END IF;

	ELSE
		/* Do it as before */
		 --X_sqlwhere7:=  X_sqlwhere7 ||  ' AND (order_type         = '||to_char(nvl(v_order_type,0))||' OR order_type IS NULL) ';
		 X_sqlwhere7:=  X_sqlwhere7 ||  ' AND (order_type = :porder_type OR order_type IS NULL) ';
	END IF;
	/* End B1408077 */

       /*
       * Bug 2031374 - umoogala : Added gl_business_class_pri and gl_product_line_pri
       * Bug 2468912 - umoogala : Added line_type
       * Bug 2423983 - umoogala : Added ar_trx_type_id
       */
/*        X_sqlwhere7 := X_sqlwhere7 || ' AND (gl_business_class_cat_id = ' || to_char(nvl(v_business_class_cat_id,0)) ||
					   ' OR gl_business_class_cat_id IS NULL) ' ||
				      ' AND (gl_product_line_cat_id = ' || to_char(nvl(v_product_line_cat_id,0)) ||
                                           ' OR gl_product_line_cat_id IS NULL) ' ||
				      ' AND (line_type = ' || to_char(nvl(v_line_type,0)) ||
                                           ' OR line_type IS NULL) ' ||
				      ' AND (ar_trx_type_id = ' || to_char(nvl(v_ar_trx_type_id,0)) ||
                                           ' OR ar_trx_type_id IS NULL) ' ; */


          X_sqlwhere7 := X_sqlwhere7 || ' AND (gl_business_class_cat_id = :pbusiness_class_cat_id '||
					  ' OR gl_business_class_cat_id IS NULL) ' ||
				      ' AND (gl_product_line_cat_id = :pproduct_line_cat_id OR gl_product_line_cat_id IS NULL) ' ||
				      ' AND (line_type = :pline_type OR line_type IS NULL) ' ||
				      ' AND (ar_trx_type_id =:par_trx_type_id OR ar_trx_type_id IS NULL) ' ;


        /* End Bug 2031374 */


 	   /* Changed the selection of acct_id to be the last column to be
              selected. If not since the order by is by field position no the
              correct acct_id doesnot get picked up if there are more than 1 record  */

           X_sqlcolumns:=   ' SELECT co_code,'||
  			     'nvl(orgn_code,'||''''||' '||''''||'),'||
				     'nvl(whse_code,'||''''||' '||''''||'),'||
				     'nvl(icgl_class,'||''''||' '||''''||'),'||
				     'nvl(custgl_class,'||''''||' '||''''||'),'||
				     'nvl(vendgl_class,'||''''||' '||''''||'),';

	   X_sqlcolumns1:=           'nvl(item_id,0),'||
				     'nvl(cust_id,0),'||
				     'nvl(vendor_id,0),'||
				     'nvl(taxauth_id,0),'||
				     'nvl(charge_id,0),'||
				     'nvl(currency_code,'||''''||' '||''''||'),'||
				     'nvl(reason_code,'||''''||' '||''''||'),';

       	  --
       	  -- Bug 2468912 - umoogala
       	  -- here nvl(line_type,-99) is done to sort the values properly in case of
       	  -- ingredients (line_type = -1).
       	  -- In case of nvl..0, when we sort, 0 will come first then -1.
       	  -- nvl..-99 will put null line type after -1. Other values of line type, 1 and 2,
       	  -- will not have any issue as they are > 0
       	  --
	   X_sqlcolumns2:=	     'nvl(routing_id,0),'||
				     'nvl(aqui_cost_id,0),'||
				     'nvl(resources,'||''''||' '||''''||'),'||
				     'nvl(cost_cmpntcls_id,0),'||
				     'nvl(cost_analysis_code,'||''''||' '||''''||'),'||
				     'nvl(order_type,0),'||
                            	     'nvl(gl_business_class_cat_id,0), '||	-- Bug 2031374 - umoogala
                            	     'nvl(gl_product_line_cat_id,0), ' ||	-- Bug 2031374 - umoogala
                            	     'nvl(line_type,-99), ' ||			-- Bug 2468912 - umoogala
                            	     'nvl(ar_trx_type_id,0), ' ||		-- Bug 2423983 - umoogala
                            	     'acct_id ' ;

           X_sqlordby:= X_my_order_by;
           X_cursor_handle := DBMS_SQL.OPEN_CURSOR;


         DBMS_SQL.PARSE(X_cursor_handle,X_sqlcolumns||X_sqlcolumns1||X_sqlcolumns2||' FROM gl_acct_map '||X_sqlwhere||X_sqlwhere1||X_sqlwhere2||X_sqlwhere3||X_sqlwhere4||X_sqlwhere5||X_sqlwhere6||X_sqlwhere7||X_sqlordby,DBMS_SQL.V7);
         DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pacct_ttl_type',Cur_subevtacct_ttl.acct_ttl_type);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pco_code',nvl(x_co_code,v_co_code));
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pwhse_code',v_whse_code);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pmap_orgn_code',nvl(X_map_orgn_code,v_orgn_code));
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pitem_id',v_item_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pvendor_id',v_vendor_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcust_id',v_cust_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':preason_code',v_reason_code);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':picgl_class',v_icgl_class);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pvendgl_class',v_vendgl_class);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcustgl_class',v_custgl_class);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcurrency_code',v_currency_code);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':prouting_id',v_routing_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcharge_id',v_charge_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':ptaxauth_id',v_taxauth_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':paqui_cost_id',v_aqui_cost_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':presources',v_resources);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcost_cmpntcls_id',v_cost_cmpntcls_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pcost_analysis_code',v_cost_analysis_code);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':porder_type',v_order_type);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pBusiness_class_cat_id',v_business_class_cat_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pproduct_line_cat_id',v_product_line_cat_id);
       	 DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':pline_type',v_line_type);
         DBMS_SQL.BIND_VARIABLE(x_cursor_handle,':par_trx_type_id',v_ar_trx_type_id);

	   -- Bug 2031374 - umoogala: 20 -> 22 , Bug 2468912: 22 to 23
	   -- Bug 2423983 - umoogala: 23 -> 24
           DBMS_SQL.DEFINE_COLUMN(X_cursor_handle,24,x_num_col);

           x_rows_processed := DBMS_SQL.EXECUTE(X_cursor_handle);
           IF (dbms_sql.fetch_rows(X_cursor_handle) > 0) THEN
             i:= i + 1;
	     -- Bug 2031374 - umoogala: 20 -> 22, Bug 2468912: 22 to 23
	     -- Bug 2423983 - umoogala: 23 -> 24
             DBMS_SQL.COLUMN_VALUE(X_cursor_handle,24,gmf_get_mappings.my_accounts(i).acct_id);
             gmf_get_mappings.my_accounts(i).acct_ttl_type := Cur_subevtacct_ttl.acct_ttl_type;
           END IF;
           DBMS_SQL.CLOSE_CURSOR(x_cursor_handle);
       END LOOP;
       no_of_rows := i;
 END get_account_mappings;


  /* ##################################################
  #  NAME get_account_value
  #
  #  SYNOPSIS
  #    Proc get_account_value
  #    Parms
  #  DESCRIPTION
  #     This function returns acct_id value retrieved for
  #     a particular acct_ttl_type.
  ################################################### */


  FUNCTION get_account_value(v_acct_ttl_type NUMBER) RETURN NUMBER IS
  BEGIN
    IF (gmf_get_mappings.no_of_rows > 0) THEN
      FOR i IN 1..no_of_rows LOOP
        IF (gmf_get_mappings.my_accounts(i).acct_ttl_type = v_acct_ttl_type) THEN
          RETURN(nvl(gmf_get_mappings.my_accounts(i).acct_id,0));
        END IF;
      END LOOP;
    ELSE
      RETURN(-1);    /* No row retrieved.*/
    END IF;
    RETURN(-1);
  END get_account_value;

   /*################################################################
  #  NAME get_opm_segment_values
  #
  #  SYNOPSIS
  #    Proc get_opm_segment_values
  #    Parms
  # AUTHOR
  #  Sukarna Reddy Created Dt 25-Jan-2001
  #  DESCRIPTION
  #     This functions parses Account value by delimiter and stores
  #  Individual value segments in to an array and returns the array.
  #################################################################### */


  FUNCTION get_opm_segment_values(p_account_value IN VARCHAR2,
                                  p_co_code IN VARCHAR2,
                                  p_type    IN NUMBER) RETURN my_opm_seg_values IS

    CURSOR Cur_get_seg_deli(pco_code VARCHAR2) IS
      SELECT segment_delimiter
      FROM   gl_plcy_mst
      WHERE  co_code = p_co_code
           AND delete_mark = 0;

    CURSOR Cur_get_seg_cnttyp(pco_code VARCHAR2,
                              ptype NUMBER) IS
      SELECT COUNT(*)
      FROM   gl_plcy_seg
      WHERE  co_code = pco_code
       AND   type = ptype
       AND   delete_mark = 0;

    CURSOR Cur_get_segment_del(v_co_code VARCHAR2) IS
      SELECT segment_delimiter
      FROM   gl_plcy_mst
      WHERE  co_code = v_co_code
           AND delete_mark = 0;

    CURSOR Cur_get_seg_cnt(pco_code VARCHAR2) IS
      SELECT COUNT(*)
      FROM   gl_plcy_seg
      WHERE  co_code = pco_code
        AND  delete_mark = 0;

    l_account_value gl_acct_mst.acct_no%TYPE;
    l_start         NUMBER DEFAULT 1;
    l_end           NUMBER DEFAULT 0;
    l_deli_process  NUMBER DEFAULT 0;
    l_delimiter_cnt NUMBER DEFAULT 0;
    l_count         NUMBER DEFAULT 0;
    l_opm_seg_values my_opm_seg_values;
    l_segment_delimiter gl_plcy_mst.segment_delimiter%TYPE;
    l_acct_no      gl_acct_mst.acct_no%TYPE;
  BEGIN

    -- Fetch Segment delimiter
    OPEN Cur_get_seg_deli(p_co_code);
    FETCH Cur_get_seg_deli INTO l_segment_delimiter;
    CLOSE Cur_get_seg_deli;

    -- Get Count of no of segments
    OPEN Cur_get_seg_cnt(p_co_code);
    FETCH Cur_get_seg_cnt INTO l_count;
    CLOSE Cur_get_seg_cnt;

    -- Initialize empty rows in an array.
    FOR i IN 1..l_count LOOP
      l_opm_seg_values(i) := NULL;
    END LOOP;

    -- Get Count of segments based on type.
    IF (p_type IN (0,1)) THEN
      OPEN Cur_get_seg_cnttyp(p_co_code,p_type);
      FETCH Cur_get_seg_cnttyp INTO l_count;
      CLOSE Cur_get_seg_cnttyp;
    END IF;

    -- Delimiter count should always be less by one then total count of segments.
    l_delimiter_cnt := l_count - 1;

    /*The variable below is used only to identify last segment
      after the last delimiter is processed.  */

    l_deli_process := 1;

    l_start := 1;  /* Stores the starting position of the segment value in the string. */
    l_acct_no := p_account_value;

    FOR i IN 1..l_count LOOP
      -- Condition to ensure there are no other delimiters to be considered.
      IF (l_deli_process <= l_delimiter_cnt) THEN
        l_end := instr(l_acct_no,l_segment_delimiter,1);

        l_account_value := SUBSTR(l_acct_no,l_start,l_end - 1);
        l_acct_no := SUBSTR(l_acct_no,l_end+1);
        l_opm_seg_values(i) := l_account_value;
        l_deli_process := l_deli_process + 1;
      ELSE
          l_account_value := SUBSTR(l_acct_no,l_start);
          l_opm_seg_values(i) := l_account_value;
      END IF;
    END LOOP;
    RETURN (l_opm_seg_values);
  END get_opm_segment_values;

 /* ################################################################
 # NAME parse_ccid
 #
 # DESCRIPTION
 #	Function to return au and acct from ccid
 # HISTORY
 #	16-Mar-2001 Rajesh Seshadri Bug 1763233 - Common Receiving
 #	21-Sep-2001 Rajesh Seshadri Bug 1801417 - retrieve
 #	   segment description also for the accu/acct descriptions
 #	12-Aug-2002 Rajesh Seshadri Bug 2485772 - get the account
 #	  uom (non-null segment uom) and insert into account master
 #        Update accu-desc, acct-desc, acct-uom if needed.
 ################################################################# */
FUNCTION parse_ccid(
	pi_co_code IN gl_plcy_mst.co_code%TYPE,
	pi_code_combination_id IN NUMBER,
	pi_create_acct IN NUMBER DEFAULT 1)
   RETURN opm_account
AS
	-- Dependencies:
	--
	-- segment_num order returned by FND_FLEX_EXT api
	-- is in ascending order of segment_num in GL
	--
	-- OPM does not allow account to be defined before accounting units
	-- segment_no and segment_ref are display only fields in the application
	-- and the segment_no in gl_plcy_seg is always put in ascending order
	--
	-- Can OPM have a subset of GL segments and others in GL might be
	-- disabled?
	--

	l_code_combination_id	NUMBER;
	l_n_gl_segs	NUMBER(5);
	l_gl_segs	fnd_flex_ext.SegmentArray;
	l_dummy	BOOLEAN;
	l_flex_code VARCHAR2(32) := 'GL#';
	l_app_name VARCHAR2(32) := 'SQLGL';
	l_segment_num NUMBER;

	l_user_id NUMBER;

	l_chart_of_accounts_id		number(15);
	l_opm_company		sy_orgn_mst.orgn_code%TYPE;
	l_opm_accu_id	gl_accu_mst.acctg_unit_id%TYPE;
	l_opm_acct_id	gl_acct_mst.acct_id%TYPE;

	l_opm_delimiter gl_plcy_mst.segment_delimiter%TYPE;
	l_n_accu	NUMBER(5);
	l_n_acct	NUMBER(5);
	l_opm_accu	VARCHAR2(255);
	l_opm_accu_desc	VARCHAR2(2000);
	l_opm_acct	VARCHAR2(255);
	l_opm_acct_desc	VARCHAR2(2000);

	l_opm_account	opm_account;
	l_opm_account_err opm_account;

	TYPE rectype_opm_seg IS RECORD(
		segment_no	NUMBER(5),
		short_name	gl_plcy_seg.short_name%TYPE,
		type		gl_plcy_seg.type%TYPE,
		segment_ref	gl_plcy_seg.segment_ref%TYPE,
		gl_seg_val	varchar2(255),
		segment_desc	fnd_flex_values_vl.description%TYPE
	);

	TYPE tabtype_gl_plcy_seg IS TABLE OF rectype_opm_seg
		INDEX BY BINARY_INTEGER;

	lt_gl_plcy_seg tabtype_gl_plcy_seg;

	CURSOR cur_opm_plcy_seg(p_opm_company gl_plcy_mst.co_code%TYPE) IS
	SELECT
		segment_no,
		short_name,
		type,
		nvl(segment_ref, 0) segment_ref
	FROM gl_plcy_seg
	WHERE
		co_code = p_opm_company
	ORDER BY segment_ref;

	l_opm_seg_count NUMBER;
	l_seg_count2 NUMBER;

	CURSOR cur_seg_num(
		p_app_id NUMBER, p_flex_code VARCHAR2,
		p_chart_of_accounts_id NUMBER, p_seg_name VARCHAR2)
	IS
	SELECT segment_num
	FROM fnd_id_flex_segments
	WHERE
		application_id = p_app_id
	AND	id_flex_code = p_flex_code
	AND	id_flex_num = p_chart_of_accounts_id
	AND	segment_name = p_seg_name;

	CURSOR cur_opm_accu(
		p_co_code	sy_orgn_mst.orgn_code%TYPE,
		p_acctg_unit_no	gl_accu_mst.acctg_unit_no%TYPE
		)
	IS
	SELECT
		acctg_unit_id, acctg_unit_desc
	FROM
		gl_accu_mst
	WHERE
		co_code = p_co_code
	AND	acctg_unit_no = p_acctg_unit_no;

	CURSOR cur_opm_acct(
		p_co_code       sy_orgn_mst.orgn_code%TYPE,
		p_acct_no	gl_acct_mst.acct_no%TYPE
		)
	IS
	SELECT
		acct_id, acct_desc, quantity_um
	FROM
		gl_acct_mst
	WHERE
		co_code = p_co_code
	AND	acct_no = p_acct_no;

	-- exceptions
	e_segment_not_found	EXCEPTION;
	e_segment_setup_error	EXCEPTION;
	e_incorrect_type	EXCEPTION;
	e_accu_not_found	EXCEPTION;
	e_acct_not_found	EXCEPTION;

	-- for Seg. Value descriptions
	l_startdate	fnd_flex_values.start_date_active%TYPE;
	l_enddate	fnd_flex_values.end_date_active%TYPE;
	l_sobname	gl_plcy_mst.set_of_books_name%TYPE;
	l_segmentname	fnd_id_flex_segments.segment_name%TYPE;
	l_segmentnum	fnd_id_flex_segments.segment_num%TYPE;
	l_segmentval	fnd_flex_values.flex_value%TYPE;
	l_segmentdesc	fnd_flex_values_vl.description%TYPE;
	l_row_to_fetch	NUMBER DEFAULT 1;
	l_statuscode	NUMBER DEFAULT 0;
	l_segmentuom	gl_stat_account_uom.unit_of_measure%TYPE;

	-- RS B2485772
	l_acct_uom	gl_acct_mst.quantity_um%TYPE := null;
	l_opm_db_acct_desc	gl_acct_mst.acct_desc%TYPE;
	l_opm_db_acct_uom	gl_acct_mst.quantity_um%TYPE;
	l_opm_db_accu_desc	gl_accu_mst.acctg_unit_desc%TYPE;

BEGIN

	l_opm_account_err.acctg_unit_id := -1;
	l_opm_account_err.acct_id := -1;

	l_user_id := FND_GLOBAL.USER_ID;

	-- Set the input values
	l_code_combination_id := pi_code_combination_id;
	l_opm_company := pi_co_code;

	-- Get the chart of accounts id
	SELECT
		sob.chart_of_accounts_id
	INTO
		l_chart_of_accounts_id
	FROM
		gl_sets_of_books sob,
		gl_plcy_mst plc
	WHERE
		sob.set_of_books_id	= plc.sob_id
	AND	plc.co_code = l_opm_company;

	-- Call get_segments()
	IF( fnd_flex_ext.get_segments(l_app_name, l_flex_code,
		l_chart_of_accounts_id, l_code_combination_id,
		l_n_gl_segs, l_gl_segs) = FALSE )
	THEN
		RAISE e_segment_not_found;
	ELSE
		FOR i IN 1..l_n_gl_segs LOOP
			null;
		END LOOP;

	END IF;

	-- get opm segment delimiter
	SELECT segment_delimiter, set_of_books_name
	INTO l_opm_delimiter, l_sobname
	FROM gl_plcy_mst
	WHERE co_code = l_opm_company;

	SELECT count(*) INTO l_opm_seg_count
	FROM gl_plcy_seg
	WHERE co_code = l_opm_company;

	IF( l_opm_seg_count <> l_n_gl_segs )
	THEN
		RAISE e_segment_setup_error;
	END IF;


	l_seg_count2 := 0;
	FOR r_seg IN cur_opm_plcy_seg(l_opm_company)
	LOOP
		IF( r_seg.segment_ref = 0 )
		THEN
			RAISE e_segment_setup_error;
		END IF;

		l_seg_count2 := l_seg_count2 + 1;


		lt_gl_plcy_seg(r_seg.segment_no).segment_no := r_seg.segment_no;
		lt_gl_plcy_seg(r_seg.segment_no).short_name := r_seg.short_name;
		lt_gl_plcy_seg(r_seg.segment_no).type := r_seg.type;
		lt_gl_plcy_seg(r_seg.segment_no).segment_ref := r_seg.segment_ref;

		lt_gl_plcy_seg(r_seg.segment_no).gl_seg_val := l_gl_segs(l_seg_count2);

		-- Get the segment description
		l_startdate := NULL;
		l_enddate := NULL;
		l_segmentname := NULL;
		l_segmentnum := r_seg.segment_ref;
		l_segmentval := l_gl_segs(l_seg_count2);
		l_segmentdesc := NULL;
		l_row_to_fetch := 1;
		l_statuscode := NULL;
		l_segmentuom := NULL;

		BEGIN
			gmf_fnd_get_segment_val.proc_get_segment_val(
				l_startdate,
				l_enddate,
				l_sobname,
				l_segmentname,
				l_segmentnum,
				l_segmentval,
				l_segmentdesc,
				l_row_to_fetch,
				l_statuscode,
				l_segmentuom
			);

			lt_gl_plcy_seg(r_seg.segment_no).segment_desc := l_segmentdesc;

			-- RS B2485772
			IF( l_segmentuom IS NOT NULL )
			THEN
				IF( LENGTHB(l_segmentuom) <= 4 )
				THEN
					l_acct_uom := l_segmentuom;
				END IF;
			END IF;

		EXCEPTION
			WHEN others THEN
				lt_gl_plcy_seg(r_seg.segment_no).segment_desc := l_gl_segs(l_seg_count2);
		END;

	END LOOP;

	-- construct the OPM accounting unit and account

	l_n_accu := 0;
	l_n_acct := 0;
	l_opm_accu := NULL;
	l_opm_accu_desc := NULL;
	l_opm_acct := NULL;
	l_opm_acct_desc := NULL;

	FOR opm_seg_idx IN 1..l_n_gl_segs
	LOOP

		IF( lt_gl_plcy_seg(opm_seg_idx).type = 0 )
		THEN
			-- it's an accu
			l_n_accu := l_n_accu + 1;
			IF( l_n_accu > 1 )
			THEN
				l_opm_accu := l_opm_accu || l_opm_delimiter || lt_gl_plcy_seg(opm_seg_idx).gl_seg_val;
				l_opm_accu_desc := l_opm_accu_desc || l_opm_delimiter || lt_gl_plcy_seg(opm_seg_idx).segment_desc;
			ELSE
				l_opm_accu := lt_gl_plcy_seg(opm_seg_idx).gl_seg_val;
				l_opm_accu_desc := lt_gl_plcy_seg(opm_seg_idx).segment_desc;
			END IF;

		ELSE
			-- it's an acct
			l_n_acct := l_n_acct + 1;
			IF( l_n_acct > 1 )
			THEN
				l_opm_acct := l_opm_acct || l_opm_delimiter || lt_gl_plcy_seg(opm_seg_idx).gl_seg_val;
				l_opm_acct_desc := l_opm_acct_desc || l_opm_delimiter || lt_gl_plcy_seg(opm_seg_idx).segment_desc;
			ELSE
				l_opm_acct := lt_gl_plcy_seg(opm_seg_idx).gl_seg_val;
				l_opm_acct_desc := lt_gl_plcy_seg(opm_seg_idx).segment_desc;
			END IF;
		END IF;

	END LOOP;

	l_opm_accu_desc := SUBSTRB(l_opm_accu_desc, 1, 70);
	l_opm_acct_desc := SUBSTRB(l_opm_acct_desc, 1, 70);


	l_n_accu := 0;
	l_n_acct := 0;

	OPEN cur_opm_accu(l_opm_company, l_opm_accu);
	FETCH cur_opm_accu INTO l_opm_accu_id, l_opm_db_accu_desc;
	IF( cur_opm_accu%NOTFOUND )
	THEN
		-- if accounting unit is not to be created then error out
		IF( pi_create_acct = 0 )
		THEN
			CLOSE cur_opm_accu;
			RAISE e_accu_not_found;
		END IF;

		SELECT gem5_acctg_id_s.NEXTVAL
		INTO l_opm_accu_id
		FROM dual;

		-- insert the accounting unit into OPM
		INSERT INTO gl_accu_mst(
			ACCTG_UNIT_ID,
			ACCTG_UNIT_NO,
			CO_CODE,
			ACCTG_UNIT_DESC,
			START_DATE,
			END_DATE,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			TRANS_CNT,
			TEXT_CODE,
			DELETE_MARK
		)
		VALUES
		(
			l_opm_accu_id,
			l_opm_accu,
			l_opm_company,
			l_opm_accu_desc,
			NULL,		-- start_date
			NULL,		-- end_date
			SYSDATE,
			l_user_id,
			SYSDATE,
			l_user_id,
			NULL,		-- last_update_login
			0,		-- trans_cnt
			NULL,		-- text_code
			0		-- delete_mark
		);
	ELSE
		-- accu found, update desc if necessary
		IF( (l_opm_db_accu_desc <> l_opm_accu_desc) OR
			(l_opm_db_accu_desc IS NULL AND l_opm_accu_desc IS NOT NULL) OR
			(l_opm_db_accu_desc IS NOT NULL AND l_opm_accu_desc IS NULL) )
		THEN
			UPDATE gl_accu_mst
			SET
				acctg_unit_desc = l_opm_accu_desc
			WHERE
				co_code = l_opm_company AND
				acctg_unit_id = l_opm_accu_id
			;
		END IF;
	END IF;
	CLOSE cur_opm_accu;

	OPEN cur_opm_acct(l_opm_company, l_opm_acct);
	FETCH cur_opm_acct INTO l_opm_acct_id, l_opm_db_acct_desc, l_opm_db_acct_uom;
	IF( cur_opm_acct%NOTFOUND )
	THEN

		-- if account is not to be created then error out
		IF( pi_create_acct = 0 )
		THEN
			CLOSE cur_opm_acct;
			RAISE e_acct_not_found;
		END IF;

		SELECT gem5_acct_id_s.NEXTVAL
		INTO l_opm_acct_id
		FROM dual;

		-- insert the account into OPM
		INSERT INTO gl_acct_mst(
			ACCT_ID,
			ACCT_NO,
			CO_CODE,
			ACCT_DESC,
			ACCT_TYPE_CODE,
			ACCT_CLASS_CODE,
			ACCT_USAGE_CODE,
			ACCT_BAL_TYPE,
			SUMMARY_IND,
			QTY_IND,
			QUANTITY_UM,
			START_DATE,
			END_DATE,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			TRANS_CNT,
			TEXT_CODE,
			DELETE_MARK
		)
		VALUES
		(
			l_opm_acct_id,
			l_opm_acct,
			l_opm_company,
			l_opm_acct_desc,
			NULL,		-- type
			NULL,		-- class
			NULL,		-- usage
			0,		-- acct_bal_type
			0,		-- summary_ind
			0,		-- qty_ind
			l_acct_uom,		-- qty_um
			NULL,		-- start_date
			NULL,		-- end_date
			SYSDATE,	-- creation date
			l_user_id,	-- created by
			SYSDATE,	-- last update date
			l_user_id,	-- last updated by
			NULL,		-- last update login
			0,		-- trans cnt
			NULL,		-- text code
			0		-- delete_mark
		);
	ELSE
		-- acct found. check desc and uom and update if necessary
		IF( (l_opm_db_acct_uom <> l_acct_uom) OR
			(l_opm_db_acct_uom IS NOT NULL AND l_acct_uom IS NULL) OR
			(l_opm_db_acct_uom IS NULL AND l_acct_uom IS NOT NULL) OR
			(l_opm_db_acct_desc <> l_opm_acct_desc) OR
			(l_opm_db_acct_desc IS NOT NULL AND l_opm_acct_desc IS NULL) OR
			(l_opm_db_acct_desc IS NULL AND l_opm_acct_desc IS NOT NULL) )
		THEN
			UPDATE gl_acct_mst
			SET
				acct_desc = l_opm_acct_desc,
				quantity_um = l_acct_uom
			WHERE
				co_code = l_opm_company AND
				acct_id = l_opm_acct_id
			;
		END IF;
	END IF;
	CLOSE cur_opm_acct;

	l_opm_account.acctg_unit_id := l_opm_accu_id;
	l_opm_account.acct_id := l_opm_acct_id;

	RETURN l_opm_account;

EXCEPTION
	WHEN e_accu_not_found THEN
		RETURN l_opm_account_err;
	WHEN e_acct_not_found THEN
		RETURN l_opm_account_err;
	WHEN e_segment_not_found THEN
		RETURN l_opm_account_err;
	WHEN e_segment_setup_error THEN
		RETURN l_opm_account_err;
	WHEN e_incorrect_type THEN
		RETURN l_opm_account_err;
	WHEN others THEN
		RETURN l_opm_account_err;

END parse_ccid;

END GMF_GET_MAPPINGS;

/
