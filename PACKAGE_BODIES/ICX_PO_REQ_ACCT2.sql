--------------------------------------------------------
--  DDL for Package Body ICX_PO_REQ_ACCT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PO_REQ_ACCT2" AS
/* $Header: ICXRQA3B.pls 115.6 99/07/17 03:22:19 porting ship $ */

/* if passing in only cart id and cart line id, all distribution lines for
   that cart line will be validated.   Otherwise, if line number and account id
   are passed in, it only validates that account, without searching through the
   database table */
PROCEDURE validate_charge_account(v_cart_id IN NUMBER,
                                  v_cart_line_id IN NUMBER,
				  v_line_number IN NUMBER default NULL,
				  v_account_id IN NUMBER default NULL,
				  v_oo_id IN NUMBER default NULL) is

 v_error_message varchar(1000);
 v_structure number;
 v_exist number;
 v_return_code varchar2(200);
 v_n_segments number;
 l_dist_number number;
 l_line_number number := 0;
 l_account_id number;

 cursor dist_acct is
    select a.code_combination_id code_combination_id
    from po_req_distributions a,
         po_requisition_lines b,
         po_requisition_headers c
    where a.requisition_line_id = v_cart_line_id
    and   a.requisition_line_id = b.requisition_line_id
    and   b.requisition_header_id = v_cart_id
    and   b.requisition_header_id = c.requisition_header_id
    and nvl(a.org_id,-9999) = nvl(v_oo_id,-9999)
    order by distribution_id;

 cursor acct_exist(acct_id number) is
    select count(*)
    from gl_sets_of_books gsb,
         financials_system_parameters fsp,
         gl_code_combinations gl
    where gsb.SET_OF_BOOKS_ID = fsp.set_of_books_id
    and   gsb.CHART_OF_ACCOUNTS_ID = gl.CHART_OF_ACCOUNTS_ID
    and   gl.CODE_COMBINATION_ID = acct_id;

 cursor get_line_number(cartid number, cartline_id number, oo_id number) is
    select a.line_num
    from po_requisition_lines a,
         po_requisition_headers b
    where a.requisition_line_id = cartline_id
    and   a.requisition_header_id = cartid
    and   a.requisition_header_id = b.requisition_header_id
    and nvl(a.org_id,-9999) = nvl(oo_id,-9999);
/*
 cursor get_line_number(cartid number, cartline_id number, oo_id number) is
    select line_num
    from po_requisition_lines
    where requisition_line_id = cartline_id
    and   requisition_header_id = cartid
    and nvl(org_id,-9999) = nvl(oo_id,-9999);
*/


BEGIN

  if icx_sec.validatesession(c_commit => FALSE)  then

    if v_line_number is not NULL then
       l_dist_number := v_line_number;
    end if;

    -- if v_cart_id is not NULL and
    if v_cart_line_id is not NULL then

       open get_line_number(v_cart_id, v_cart_line_id, v_oo_id);
       fetch get_line_number into l_line_number;
       close get_line_number;
    end if;

    -- account is null
    if v_account_id is NULL and
       v_cart_id is NULL and
       v_cart_line_id is NULL then

       FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
       FND_MESSAGE.SET_TOKEN('ITEM_TOKEN',' ');
       v_error_message := FND_MESSAGE.GET;
       FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
       v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;

       icx_util.add_error(v_error_message);
       -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number);

    elsif v_account_id is not NULL then
       l_account_id := v_account_id;

       open acct_exist(l_account_id);
       fetch acct_exist into v_exist;
       close acct_exist;
       if (v_exist = 0) then
          --add error
          FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
          FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_line_number);
          v_error_message := FND_MESSAGE.GET;
          FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
          v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
          icx_util.add_error(v_error_message);
          -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);
       end if;

    else
       l_dist_number := 1;
       for prec in dist_acct loop
           if prec.code_combination_id is not NULL then
	      l_account_id := prec.code_combination_id;
	      open acct_exist(l_account_id);
	      fetch acct_exist into v_exist;
	      close acct_exist;
              if (v_exist = 0) then
                --add error
                FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
                FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_line_number);
                v_error_message := FND_MESSAGE.GET;
                FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
		v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
                icx_util.add_error(v_error_message);
                -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);
	       end if;
	    else
                FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
                FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_line_number);
                v_error_message := FND_MESSAGE.GET;
		FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
		v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
                icx_util.add_error(v_error_message);
                -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);
            end if;
	    l_dist_number := l_dist_number + 1;
       end loop;
    end if;
 end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
    FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_line_number);
    v_error_message := FND_MESSAGE.GET || ': ' || substr(SQLERRM,1,512);
    FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
    v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
    icx_util.add_error(v_error_message);
    --  ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);
end;


PROCEDURE insert_row(v_cart_line_id IN NUMBER,
		     v_oo_id IN NUMBER,
                     v_cart_id IN NUMBER,
	             v_account_id IN NUMBER default NULL,
		     v_n_segments IN NUMBER default NULL,
	             v_segments IN fnd_flex_ext.SegmentArray,
                     v_account_num IN VARCHAR2 default NULL,
                     v_allocation_type IN VARCHAR2 default NULL,
                     v_allocation_value IN NUMBER default NULL,
                     v_line_quantity IN NUMBER default NULL) is



    v_col_name varchar2(100);
    l_insert_sql varchar2(8000);
    l_shopper_id number;
    l_cur_seg number;
    l number;
    l_call INTEGER;
    l_ret  INTEGER;
    l_return_code  VARCHAR2(30);
    l_err_pos NUMBER;
    l_error_message VARCHAR2(2000);
    l_err_num NUMBER;
    l_err_mesg VARCHAR2(240);
    l_alloc_type VARCHAR2(20) := 'PERCENT';
    l_alloc_percent NUMBER := 100;
    v_variance_acct_id NUMBER := NULL;
    v_budget_acct_id NUMBER := NULL;
    v_accrual_acct_id NUMBER := NULL;
    v_return_code varchar2(200) := NULL;
    l_dist_num number := NULL;
    l_num_ak_cols number := 0;
    l_charge_account_num number := 0;

    l_req_line_number NUMBER := 0;
    l_emp_id          NUMBER := NULL;
    v_set_of_books_id  NUMBER := NULL;
    v_code_combination_id  NUMBER := NULL;

    -- record structure to hold the values for custom account
    v_custom_value_rec custom_validate_values;

-- bug 689962
    v_distribution_id number;
-- end

    cursor get_dist_num is
      select max(a.distribution_num)
      from po_req_distributions a,
           po_requisition_lines b,
           po_requisition_headers c
      where a.requisition_line_id = v_cart_line_id
      and   b.requisition_line_id = a.requisition_line_id
      and   b.requisition_header_id = v_cart_id
      and   b.requisition_header_id = c.requisition_header_id
      and   nvl(a.org_id,-9999) = nvl(v_oo_id,-9999);

    cursor get_req_line_number is
      select a.line_num
      from po_requisition_lines a,
           po_requisition_headers b
      where a.requisition_line_id = v_cart_line_id
      and   a.requisition_header_id = v_cart_id
      and   a.requisition_header_id = b.requisition_header_id
      and nvl(a.org_id,-9999) = nvl(v_oo_id,-9999);

    cursor get_custom_values(reqline_id number,emp_id number) is
        select  hecv.default_code_combination_id employee_default_account_id,
                hecv.organization_id employee_org_id,
                hecv.business_group_id employee_bus_group_id,
                fsp.org_id po_org_id,
                isc.NEED_BY_DATE,
                isc.DESTINATION_TYPE_CODE,
                isc.DESTINATION_ORGANIZATION_ID,
                isc.DELIVER_TO_LOCATION_ID,
                fsp.set_of_books_id,
                isc.ITEM_ID,
                isc.ITEM_REVISION,
                isc.item_description,
                msi.expense_account,
                isc.UNIT_MEAS_LOOKUP_CODE,
                isc.QUANTITY,
                isc.UNIT_PRICE,
                isc.CATEGORY_ID,
                isc.LINE_TYPE_ID,
                isc.SUGGESTED_VENDOR_NAME,
                isc.SUGGESTED_VENDOR_LOCATION
        FROM    financials_system_parameters fsp,
                hr_employees_current_v hecv,
                mtl_system_items msi,
                po_requisition_lines isc
        where   isc.requisition_line_id = reqline_id
        and     msi.INVENTORY_ITEM_ID (+) = isc.ITEM_ID
        and     nvl(msi.ORGANIZATION_ID, isc.DESTINATION_ORGANIZATION_ID) = isc.DESTINATION_ORGANIZATION_ID
        and     hecv.EMPLOYEE_ID = emp_id
        and     nvl(isc.org_id, -9999) = nvl(v_oo_id, -9999);

    cursor get_emp_id(line_id number) is
        select to_person_id
        from po_requisition_lines a,
             po_requisition_headers b
        where a.requisition_line_id = line_id
        and   a.requisition_header_id = v_cart_id
        and   a.requisition_header_id = b.requisition_header_id
        and nvl(a.org_id,-9999) = nvl(v_oo_id,-9999);

    cursor set_of_books is
      SELECT fsp.set_of_books_id
      FROM financials_system_parameters fsp,
	   gl_sets_of_books gsob
      WHERE gsob.set_of_books_id = fsp.set_of_books_id
      AND   nvl(fsp.org_id, -9999) = nvl(v_oo_id, -9999);

begin

  if icx_sec.validatesession(c_commit => FALSE)  then

    l_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

    open get_emp_id(v_cart_line_id);
    fetch get_emp_id into l_emp_id;
    close get_emp_id;

    open get_req_line_number;
    fetch get_req_line_number into l_req_line_number;
    close get_req_line_number;

    open get_dist_num;
    fetch get_dist_num into l_dist_num;
    close get_dist_num;

    if l_dist_num is NULL then
       l_dist_num := 1;
    else
       l_dist_num := l_dist_num + 1;
    end if;

    if v_allocation_type is not NULL  and
       v_allocation_value is not NULL then
       l_alloc_type := v_allocation_type;
       l_alloc_percent := v_allocation_value;
    end if;

    -- Get the set of books id
    open set_of_books;
    fetch set_of_books into v_set_of_books_id;
    close set_of_books;

-- bug 689962
    select po_req_distributions_s.nextval into v_distribution_id
    from sys.dual;
-- end

    -- Insert the new column in po_req_distribution
    INSERT INTO po_req_distributions (distribution_id,
                                      last_update_date,
                                      last_updated_by,
                                      requisition_line_id,
                                      set_of_books_id,
                                      code_combination_id,
                                      req_line_quantity,
                                      last_update_login,
                                      creation_date,
                                      created_by,
                                      distribution_num,
                                      allocation_type,
                                      allocation_value)
                VALUES (v_distribution_id, -- bug 689962
                        sysdate,
                        l_shopper_id,
                        v_cart_line_id,
                        v_set_of_books_id,
                        v_account_id,
                        v_line_quantity,
                        l_shopper_id,
                        sysdate,
                        l_shopper_id,
                        l_dist_num,
                        v_allocation_type,
                        v_allocation_value);

    -- Update the various other accounts
    -- The budget and variance accounts are updated with the
    -- code combination id. This is becuase the Web Reqs alwyas use
    -- 'EXPENSE' as the destination_type_code.
    UPDATE po_req_distributions
    SET accrual_account_id=
                (SELECT accrued_code_combination_id
                 FROM po_system_parameters),
        budget_account_id = v_account_id,
        variance_account_id = v_account_id
    WHERE requisition_line_id = v_cart_line_id
-- bug 689962 only the current distribution needs to be update
    AND distribution_id = v_distribution_id
-- end
    AND nvl(org_id,-9999) = nvl(v_oo_id,-9999);

    -- Get the values for the custom account build call
    open get_custom_values(v_cart_line_id, l_emp_id);
    fetch get_custom_values into v_custom_value_rec;
    close get_custom_values;

    -- Call the custom build
    icx_req_custom.po_custom_build_req_account2(EMPLOYEE_ID => l_emp_id,
     employee_default_account_id => v_custom_value_rec.employee_default_account_id,
     employee_org_id => v_custom_value_rec.employee_org_id,
     employee_bus_group_id => v_custom_value_rec.employee_bus_group_id,
     po_org_id => v_custom_value_rec.po_org_id,
     NEED_BY_DATE => v_custom_value_rec.NEED_BY_DATE,
     DESTINATION_TYPE => v_custom_value_rec.DESTINATION_TYPE_CODE,
     DESTINATION_ORG_ID => v_custom_value_rec.DESTINATION_ORGANIZATION_ID,
     SITE_ID => v_custom_value_rec.DELIVER_TO_LOCATION_ID,
     set_of_books_id =>  v_custom_value_rec.set_of_books_id,
     ITEM_ID => v_custom_value_rec.ITEM_ID,
     ITEM_REVISION => v_custom_value_rec.ITEM_REVISION,
     ITEM_DESCRIPTION => v_custom_value_rec.ITEM_DESCRIPTION,
     item_default_account_id => v_custom_value_rec.expense_account,
     UNIT_OF_MEASURE => v_custom_value_rec.UNIT_MEAS_LOOKUP_CODE,
     QUANTITY => v_custom_value_rec.QUANTITY,
     PRICE => v_custom_value_rec.UNIT_PRICE,
     SUPPLIER_ITEM_NUM => NULL,
     CATEGORY_ID => v_custom_value_rec.CATEGORY_ID,
     LINE_TYPE => v_custom_value_rec.LINE_TYPE_ID,
     SUPPLIER => v_custom_value_rec.SUGGESTED_VENDOR_NAME,
     SUPPLIER_SITE => v_custom_value_rec.SUGGESTED_VENDOR_LOCATION,
     SOURCE_DOC_NUM => NULL,
     SOURCE_LINE_NUM => NULL,
     CHARGE_ACCT_LINE_SEGMENTS => v_account_num,
     ACCOUNT_NUM => l_charge_account_num,
     CHARGE_ACCOUNT_ID => v_code_combination_id,
     VARIANCE_ACCOUNT_ID => v_variance_acct_id,
     BUDGET_ACCOUNT_ID => v_budget_acct_id,
     ACCRUAL_ACCOUNT_ID => v_accrual_acct_id,
     RETURN_CODE => l_return_code);

     -- Update the custom returned value if the values are not null
     update po_req_distributions a
     set a.ACCRUAL_ACCOUNT_ID = NVL(v_accrual_acct_id, a.accrual_account_id),
     a.VARIANCE_ACCOUNT_ID = NVL(v_variance_acct_id, a.variance_account_id),
     a.BUDGET_ACCOUNT_ID = NVL(v_budget_acct_id, a.budget_account_id)
     where a.requisition_line_id = v_cart_line_id
-- bug 689962, only apply customization to current distribution
     and a.distribution_id = v_distribution_id
-- end
     and nvl(a.org_id,-9999) = nvl(v_oo_id,-9999);

  end if;
exception
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
     FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',l_req_line_number);
     l_err_num := SQLCODE;
     l_error_message := SQLERRM;
     select substr(l_error_message,12,512) into l_err_mesg from dual;
     l_err_mesg := FND_MESSAGE.GET || ': ' || l_err_mesg;
     FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
     l_err_mesg := '(' || FND_MESSAGE.GET || ' ' || l_dist_num || ') ' || l_err_mesg;
     icx_util.add_error(l_err_mesg);
     -- ICX_REQ_SUBMIT.storeerror(v_cart_id, l_err_mesg,l_dist_num,v_cart_line_id);

end;



PROCEDURE update_row(v_cart_line_id IN NUMBER,
		     v_oo_id IN NUMBER,
		     v_cart_id IN NUMBER,
		     v_distribution_id IN NUMBER,
		     v_line_number IN NUMBER,
	             v_account_id IN NUMBER default NULL,
		     v_n_segments IN NUMBER default NULL,
	             v_segments IN fnd_flex_ext.SegmentArray,
                     v_account_num IN VARCHAR2 default NULL,
		     v_allocation_type IN VARCHAR2 default NULL,
		     v_allocation_value IN NUMBER default NULL,
		     v_line_quantity IN NUMBER default NULL) is


 cursor get_ak_columns is
        select  ltrim(rtrim(d.COLUMN_NAME)) COL_NAME
        from       ak_region_items a,
        ak_attributes b,
        ak_regions c,
        ak_object_attributes d
        where      a.NODE_DISPLAY_FLAG = 'Y'
        and        a.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
        and        a.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
        and        b.DATA_TYPE = 'VARCHAR2'
        and        c.REGION_APPLICATION_ID = 601
        and        a.REGION_CODE = c.REGION_CODE
        and        a.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        and        c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
        and        a.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
        and        a.region_code = 'ICX_CART_LINE_DISTRIBUTIONS_R'
        and        d.COLUMN_NAME like 'CHARGE_ACCOUNT_SEGMENT%'
        order by a.display_sequence;

    v_col_name varchar2(100);
    l_insert_sql varchar2(8000);
    l_shopper_id number;
    l_cur_seg number;
    l number;
    l_call INTEGER;
    l_ret  INTEGER;
    l_err_pos NUMBER;
    l_error_message VARCHAR2(2000);
    l_err_num NUMBER;
    l_err_mesg VARCHAR2(240);
    l_alloc_type VARCHAR2(20) := 'PERCENT';
    l_alloc_percent NUMBER := 100;
    v_variance_acct_id NUMBER := NULL;
    v_budget_acct_id NUMBER := NULL;
    v_accrual_acct_id NUMBER := NULL;
    v_return_code varchar2(200) := NULL;
    l_cart_line_number NUMBER := 0;

    cursor get_cart_line_number is
      select cart_line_number
      from icx_shopping_cart_lines
      where cart_id = v_cart_id
      and cart_line_id = v_cart_line_id;


/* New Vars added to take care of Binary Vars code ***/

    v_cursor_id   INTEGER;

    v_segment_bind   fnd_flex_ext.SegmentArray;

begin

  if icx_sec.validatesession(c_commit => FALSE)  then

    l_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

    open get_cart_line_number;
    fetch get_cart_line_number into l_cart_line_number;
    close get_cart_line_number;

/* Modified to take care of Bind vars code ***/


/*
    l_insert_sql := 'Update icx_cart_line_distributions set
                     last_updated_by = ' || l_shopper_id
		    || ' ,last_update_login = ' || l_shopper_id
                    || ' ,last_update_date = sysdate';

    if v_allocation_type is not NULL then
	l_insert_sql := l_insert_sql || ', allocation_type = ''' || v_allocation_type || '''';
    end if;
    if v_allocation_value is not NULL then
        l_insert_sql := l_insert_sql || ', allocation_value = ' || v_allocation_value;
    end if;
    if v_account_id is not NULL then
        l_insert_sql := l_insert_sql || ', charge_account_id = ' || v_account_id;
    end if;
    if v_account_num is not NULL then
        l_insert_sql := l_insert_sql || ', charge_account_num = ''' || v_account_num || '''';
    end if;
***/

    l_insert_sql := 'Update icx_cart_line_distributions
	set last_updated_by = :last_updated_by,
	last_update_login = :last_update_login ,
	last_update_date = :last_update_date,
	allocation_type = decode(:allocation_type, null, allocation_type, :allocation_type ),
	allocation_value = decode( :allocation_value, null, allocation_value, :allocation_value ),
	charge_account_id = decode( :charge_account_id , null, charge_account_id, :charge_account_id ),
	charge_account_num = decode( :charge_account_num, null, charge_account_num, :charge_account_num )';


    if v_n_segments > 0 then
        l := 1;
        for prec in get_ak_columns loop
              l_insert_sql :=   l_insert_sql || ',' || prec.COL_NAME || ' = ''' || ':a' || to_char(l) || '''';
              v_segment_bind(l) := v_segments(l);

           if l = v_n_segments then
              exit;
           end if;
              l := l + 1;

        end loop;
     end if;

/**
     l_insert_sql := l_insert_sql || ' where cart_id = ' || v_cart_id ||
		     ' and cart_line_id = ' || v_cart_line_id || ' and distribution_id = ' || v_distribution_id;
***/

     l_insert_sql := l_insert_sql || ' where cart_id = :cart_id and cart_line_id = :cart_line_id and distribution_id = :distribution_id ';

    v_cursor_id := dbms_sql.open_cursor;
     dbms_sql.parse( v_cursor_id, l_insert_sql, DBMS_SQL.native);

     l_err_pos := dbms_sql.LAST_ERROR_POSITION;

     dbms_sql.bind_variable(v_cursor_id, ':cart_line_id', v_cart_line_id );
     dbms_sql.bind_variable(v_cursor_id, ':cart_id', v_cart_id );
     dbms_sql.bind_variable(v_cursor_id, ':distribution_id', v_distribution_id );
     dbms_sql.bind_variable(v_cursor_id, ':charge_account_id', v_account_id );
     dbms_sql.bind_variable(v_cursor_id, ':charge_account_num', v_account_num );
     dbms_sql.bind_variable(v_cursor_id, ':allocation_type', v_allocation_type );
     dbms_sql.bind_variable(v_cursor_id, ':allocation_value', v_allocation_value );
     dbms_sql.bind_variable(v_cursor_id, ':last_updated_by', l_shopper_id );
     dbms_sql.bind_variable(v_cursor_id, ':last_update_date', sysdate );
     dbms_sql.bind_variable(v_cursor_id, ':last_update_login', l_shopper_id );

     for ix in 1..l loop
     dbms_sql.bind_variable(v_cursor_id, ':a' || to_char(ix), v_segment_bind(ix) );
     end loop;
/*
     l_call := dbms_sql.open_cursor;
     dbms_sql.parse(l_call,l_insert_sql ,dbms_sql.native);
     l_err_pos := dbms_sql.LAST_ERROR_POSITION;
     l_ret := dbms_sql.execute(l_call);
     dbms_sql.close_cursor(l_call);
***/
     l_ret := dbms_sql.execute(v_cursor_id);
     dbms_sql.close_cursor(v_cursor_id);


     -- update the other account id based on charge account id
     icx_req_custom.cart_custom_build_req_account2(v_cart_line_id,
                                                v_variance_acct_id,
                                                v_budget_acct_id,
                                                v_accrual_acct_id,
                                                v_return_code);

     update icx_cart_line_distributions
     set ACCRUAL_ACCOUNT_ID = v_accrual_acct_id,
     VARIANCE_ACCOUNT_ID = v_variance_acct_id,
     BUDGET_ACCOUNT_ID = v_budget_acct_id
     where CART_LINE_ID = v_cart_line_id
     and CART_ID = v_cart_id
     and DISTRIBUTION_ID = v_distribution_id;

  end if;

exception
  WHEN OTHERS THEN
     l_err_num := SQLCODE;
     l_error_message := SQLERRM;
     FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
     FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',l_cart_line_number);
     select substr(l_error_message,12,512) into l_err_mesg from dual;
     l_err_mesg := FND_MESSAGE.GET || ': ' || l_err_mesg;
     FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
     l_err_mesg := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || l_err_mesg;
    icx_util.add_error(l_err_mesg);
     ICX_REQ_SUBMIT.storeerror(v_cart_id, l_err_mesg,v_line_number,v_cart_line_id);
     if dbms_sql.IS_OPEN(v_cursor_id) then
       dbms_sql.close_cursor(v_cursor_id);
     end if;
end;


/* get account id, segments by con-catenated segments pass in at v_account_num */
PROCEDURE get_acct_by_con(v_cart_id IN NUMBER,
		           v_line_number IN NUMBER,
                           v_account_num IN VARCHAR2,
			   v_structure  IN NUMBER,
			   v_cart_line_id IN NUMBER,
			   v_cart_line_number IN NUMBER default NULL,
                           v_n_segments OUT NUMBER,
			   v_segments OUT fnd_flex_ext.SegmentArray,
                           v_account_id OUT NUMBER) is
  v_delimiter varchar2(10);
  l_n_segments NUMBER := NULL;
  l_segments fnd_flex_ext.SegmentArray;
  l_account_id NUMBER := NULL;
  l_ret_cd BOOLEAN;
  v_error_message varchar2(1000);

begin

   -- get con-seg delimiter
   v_delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#',v_structure);
   l_account_id := fnd_flex_ext.get_ccid('SQLGL',
		       'GL#',
		       v_structure,
		       to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
		       v_account_num);

   if l_account_id is not NULL then

      v_account_id := l_account_id;
      l_ret_cd := fnd_flex_ext.get_segments('SQLGL',
				'GL#',
			        v_structure,
				l_account_id,
			        v_n_segments,
				v_segments);
      if l_ret_cd = FALSE then
         v_error_message := FND_MESSAGE.GET;
         FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
         FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',v_cart_line_number);
         v_error_message := FND_MESSAGE.GET || ' ' || v_error_message;
         FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
	 v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ' ) ' || v_error_message;
         icx_util.add_error(v_error_message);
         ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
      end if;


   end if;

exception
  when others then
     v_error_message :=  substr(SQLERRM,1,512);
     FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
     FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',v_cart_line_number);
     v_error_message := FND_MESSAGE.GET || ' ' || v_error_message;
     FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
     v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
     icx_util.add_error(v_error_message);
     ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
end;


/* get account id,con-catenated segments based on segments */
PROCEDURE get_acct_by_segs(v_cart_id IN NUMBER,
                           v_line_number IN NUMBER,
                           v_segments IN fnd_flex_ext.SegmentArray,
			   v_structure  IN NUMBER,
                           v_cart_line_id IN NUMBER,
                           v_cart_line_number IN NUMBER default NULL,
                           v_n_segments OUT NUMBER,
			   v_account_num OUT VARCHAR2,
                           v_account_id OUT NUMBER) is

  v_delimiter varchar2(10);
  l_n_segments NUMBER := NULL;
  l_account_num VARCHAR2(2000) := NULL;
  l_account_id NUMBER := NULL;
  l_ret_cd BOOLEAN;
  v_error_message varchar2(1000);

begin

   -- get con-seg delimiter
   v_delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#',v_structure);
   l_n_segments := v_segments.COUNT;
   v_n_segments := l_n_segments;

   l_account_num := fnd_flex_ext.concatenate_segments(l_n_segments,
                                v_segments,
                                v_delimiter);
   v_account_num := l_account_num;

   if l_account_num is not NULL then

      l_account_id := fnd_flex_ext.get_ccid('SQLGL',
                       'GL#',
                       v_structure,
                       to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
                       l_account_num);


      v_account_id := l_account_id;
   else
      v_account_id := NULL;
   end if;

exception
  when others then
     v_error_message :=  substr(SQLERRM,1,512);
     FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
     FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',v_cart_line_number);
     v_error_message := FND_MESSAGE.GET || ' ' || v_error_message;
     FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
     v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
     icx_util.add_error(v_error_message);
     -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
end;


/* main procedure to call to get segments,concatenated segments based on an
 * account id */
PROCEDURE get_account_segments(v_cart_id IN NUMBER,
			       v_line_number IN NUMBER,
  			       v_account_id IN NUMBER,
			       v_structure IN NUMBER,
			       v_cart_line_id IN NUMBER,
			       v_cart_line_number IN NUMBER default NULL,
			       v_n_segments OUT NUMBER,
			       v_segments OUT fnd_flex_ext.SegmentArray,
                               v_account_num OUT VARCHAR2) is

  v_delimiter varchar2(10);
  l_n_segments NUMBER := NULL;
  l_segments fnd_flex_ext.SegmentArray;
  l_ret_cd BOOLEAN;
  v_error_message varchar2(1000);

begin
  -- get con-seg delimiter
  v_delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#',v_structure);

  -- get segments and put into the plsql table
  l_ret_cd := fnd_flex_ext.get_segments('SQLGL',
		            'GL#',
			    v_structure,
			    v_account_id,
			    l_n_segments,
			    l_segments);

  if l_ret_cd = FALSE then
     v_error_message := FND_MESSAGE.GET;
     FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
     FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',v_cart_line_number);
     v_error_message :=  FND_MESSAGE.GET || ' ' || v_error_message;
     FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
     v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
     icx_util.add_error(v_error_message);
     ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
  end if;

  -- if returns segments generate con-segs
  if l_n_segments is not NULL and
     l_n_segments <> 0 then

     v_n_segments := l_n_segments;
     v_segments := l_segments;

     v_account_num := fnd_flex_ext.concatenate_segments(n_segments => l_n_segments,
						        segments => l_segments,
							delimiter =>  v_delimiter);

  end if;
exception
  when others then
     v_error_message :=  substr(SQLERRM,1,512);
     FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
     FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',v_cart_line_number);
     v_error_message := FND_MESSAGE.GET || ' ' || v_error_message;
     FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
     v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
     icx_util.add_error(v_error_message);
     ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);

end;


/* Find Account Id based on concatenated segments passin and update the account
 * distribution tables based on account id found.
 * Pass in distribution id to update existing account, and insert a new row
 * if distiribution id is not passed.*/
/* NOTE: this is used when no segments are turned on in AK for display  or
   update, so only update the charge account id and charge account num */
PROCEDURE update_account_num(v_cart_id IN NUMBER,
			 v_cart_line_id IN NUMBER,
                         v_oo_id IN NUMBER,
			 v_account_num IN VARCHAR2,
			 v_distribution_id IN NUMBER default NULL,
			 v_line_number IN NUMBER default NULL,
			 v_allocation_type IN VARCHAR2 default NULL,
			 v_allocation_value IN NUMBER default NULL,
			 v_validate_flag IN VARCHAR2 default 'Y',
                         v_line_quantity IN VARCHAR2 default NULL) is

 v_error_message varchar(1000);
 v_structure number;
 v_expense_account number;
 v_exist number;
 v_return_code varchar2(200);
 v_n_segments number;
 v_segments fnd_flex_ext.SegmentArray;
 v_account_id number := NULL;
 l_line_number number := NULL;

      cursor get_dist_num(cartline_id number,oo_id number) is
         select max(a.distribution_num)
      from po_req_distributions a,
           po_requisition_lines b,
           po_requisition_headers c
      where a.requisition_line_id = cartline_id
      and   a.requisition_line_id = b.requisition_line_id
      and   b.requisition_header_id = v_cart_id
      and   b.requisition_header_id = c.requisition_header_id
      and nvl(a.org_id, -9999) = nvl(oo_id,-9999);

      CURSOR chart_account_id IS
      SELECT CHART_OF_ACCOUNTS_ID
      FROM gl_sets_of_books,
           financials_system_parameters fsp
      WHERE gl_sets_of_books.SET_OF_BOOKS_ID = fsp.set_of_books_id;

      cursor get_line_number(cartline_id number, oo_id number) is
	 select a.line_num
      from po_requisition_lines a,
           po_requisition_headers b
      where a.requisition_line_id = cartline_id
      and   a.requisition_header_id = v_cart_id
      and   a.requisition_header_id = b.requisition_header_id
      and nvl(a.org_id, -9999) = nvl(oo_id,-9999);

      l_dist_number NUMBER := 0;

BEGIN

  if icx_sec.validatesession(c_commit => FALSE)  then

    -- get structure number
    open chart_account_id;
    fetch chart_account_id into v_structure;
    close chart_account_id;

    open get_line_number(v_cart_line_id, v_oo_id);
    fetch get_line_number into l_line_number;
    close get_line_number;

    -- if v_distribution_id is pass in as null then this is a new line
    -- get a new dist line number
    if v_distribution_id is NULL then
       open get_dist_num(v_cart_line_id,v_oo_id);
       fetch get_dist_num into l_dist_number;
       close get_dist_num;

       if l_dist_number is NULL then
          l_dist_number := 1;
       else
          l_dist_number := l_dist_number + 1;
       end if;
    else
       l_dist_number := v_line_number;
    end if;

    /* get the account id */
    v_account_id := fnd_flex_ext.get_ccid('SQLGL',
                       'GL#',
                       v_structure,
                       to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
                       v_account_num);

    /* if the account number passing in does not generate a valid account id
       error out immediately */
    if v_account_id is NULL then
       FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
       FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_line_number);
       v_error_message := FND_MESSAGE.GET;
       FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
       v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
       icx_util.add_error(v_error_message);
       -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);
    else

       if v_validate_flag = 'Y' then
          validate_charge_account(v_cart_id,v_cart_line_id,l_line_number,v_account_id, v_oo_id);
       end if;
    end if;

    /* No Segments are passed in , so set v_n_segments to 0 to avoid updating
      any segment in the insert_row or update_row procedure */
    v_n_segments := 0;
    if v_distribution_id is NULL then
         insert_row(v_cart_line_id,v_oo_id,v_cart_id, v_account_id,v_n_segments,v_segments,v_account_num,v_allocation_type,v_allocation_value, v_line_quantity);
    else

         update_row(v_cart_line_id,v_oo_id,v_cart_id,v_distribution_id,v_line_number,v_account_id,v_n_segments,v_segments,v_account_num,v_allocation_type,v_allocation_value);
    end if;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
    FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_line_number || ': ' || substr(SQLERRM,1,512));
    v_error_message := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
    v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
    icx_util.add_error(v_error_message);
    -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);
    icx_util.add_error(substr(SQLERRM, 12, 512));
end;




/* Find Account Id based on table of segments passin and update the account
 * distribution tables based on account id found
 * Pass in distribution id to update existing account, and insert a new row
 * if distiribution id is not passed.*/
PROCEDURE update_account(v_cart_id IN NUMBER,
                         v_cart_line_id IN NUMBER,
                         v_oo_id IN NUMBER,
			 v_segments IN fnd_flex_ext.SegmentArray,
			 v_distribution_id IN NUMBER default NULL,
			 v_line_number IN NUMBER default NULL,
			 v_allocation_type IN VARCHAR2 default NULL,
			 v_allocation_value IN NUMBER default NULL,
                         v_validate_flag IN VARCHAR2 default 'Y',
                         v_line_quantity IN VARCHAR2 default NULL) is

 v_error_message varchar(1000);
 v_structure number;
 v_expense_account number;
 v_exist number;
 v_return_code varchar2(200);
 v_n_segments number;
 v_account_num varchar2(2000) := NULL;
 v_account_id number := NULL;
 l_dist_number number := NULL;

      cursor get_dist_number(reqline_id number,oo_id number) is
         select max(a.distribution_num)
      from po_req_distributions a,
           po_requisition_lines b,
           po_requisition_headers c
      where a.requisition_line_id = reqline_id
      and   a.requisition_line_id = b.requisition_line_id
      and   b.requisition_header_id = v_cart_id
      and   b.requisition_header_id = c.requisition_header_id
      and nvl(a.org_id, -9999) = nvl(v_oo_id,-9999);

      CURSOR chart_account_id IS
      SELECT CHART_OF_ACCOUNTS_ID
      FROM gl_sets_of_books,
           financials_system_parameters fsp
      WHERE gl_sets_of_books.SET_OF_BOOKS_ID = fsp.set_of_books_id;

      cursor get_req_line_number(reqline_id number) is
	select a.line_num
	from po_requisition_lines a,
             po_requisition_headers b
	where a.requisition_line_id = reqline_id
	and   a.requisition_header_id = v_cart_id
	and   a.requisition_header_id = b.requisition_header_id
        and nvl(a.org_id, -9999) = nvl(v_oo_id,-9999);

      l_req_line_number NUMBER := 0;

BEGIN

  if icx_sec.validatesession(c_commit => FALSE)  then

    open get_req_line_number(v_cart_line_id);
    fetch get_req_line_number into l_req_line_number;
    close get_req_line_number;


    -- get structure number
    open chart_account_id;
    fetch chart_account_id into v_structure;
    close chart_account_id;

    -- if v_distribution_id is pass in as null then this is a new line
    -- get a new dist line number
    if v_distribution_id is NULL then
       open get_dist_number(v_cart_line_id, v_oo_id);
       fetch get_dist_number into l_dist_number;
       close get_dist_number;

       if l_dist_number is NULL then
          l_dist_number := 1;
       else
          l_dist_number := l_dist_number + 1;
       end if;
    else
       l_dist_number := v_line_number;
    end if;

    get_acct_by_segs(v_cart_id,
                     l_dist_number,
                     v_segments,
                     v_structure,
                     v_cart_line_id,
                     l_req_line_number,
                     v_n_segments,
                     v_account_num,
                     v_account_id);

    if v_n_segments > 0 then

      if v_validate_flag = 'Y' then
         -- validate_charge_account(v_cart_id,v_cart_line_id,l_dist_number,v_account_id, v_oo_id);
         -- validate_charge_account(v_cart_line_id,l_dist_number,v_account_id, v_oo_id);
         validate_charge_account(v_cart_id => v_cart_id,
                                 v_cart_line_id  => v_cart_line_id,
				 v_line_number => l_dist_number,
				 v_account_id => v_account_id,
				 v_oo_id => v_oo_id);
      end if;

      if v_distribution_id is NULL then

         insert_row(v_cart_line_id,v_oo_id,v_cart_id, v_account_id,v_n_segments,v_segments,v_account_num,v_allocation_type,v_allocation_value, to_number(v_line_quantity));
      else
         update_row(v_cart_line_id,v_oo_id,v_cart_id,v_distribution_id,v_line_number,v_account_id,v_n_segments,v_segments,v_account_num,v_allocation_type,v_allocation_value);
      end if;

    else

       --add error
       FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
       FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_req_line_number);
       v_error_message := FND_MESSAGE.GET;
       FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
       v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
       icx_util.add_error(v_error_message);
       -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);


    end if;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
    FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_req_line_number || ': ' || substr(SQLERRM,1,512));
    v_error_message := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
    v_error_message := '(' || FND_MESSAGE.GET || ' ' || l_dist_number || ') ' || v_error_message;
    icx_util.add_error(v_error_message);
    -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,l_line_number,v_cart_line_id);
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
end;



PROCEDURE get_default_account (v_cart_id IN NUMBER,
                               v_cart_line_id IN NUMBER,
                               v_emp_id IN NUMBER,
                               v_oo_id IN NUMBER,
                               v_account_id IN OUT NUMBER,
                               v_account_num IN OUT VARCHAR2

) IS

 v_error_message varchar(1000);
 v_structure number;
 v_expense_account number;
 v_line_number number;
 v_exist number;
 v_return_code varchar2(200);
 v_n_segments number;
 v_segments fnd_flex_ext.SegmentArray;

 CURSOR line_default_account is
        SELECT  default_code_combination_id employee_default_account_id
        from hr_employees_current_v
        where employee_id = v_emp_id;

 CURSOR item_expense_account is
     select msi.expense_account
     from mtl_system_items msi,
     icx_shopping_carts isc,
     icx_shopping_cart_lines iscl
     where msi.inventory_item_id(+) = iscl.item_id
       AND     nvl(msi.ORGANIZATION_ID,
                        nvl(isc.DESTINATION_ORGANIZATION_ID,
                            iscl.DESTINATION_ORGANIZATION_ID)) =
                    nvl(isc.DESTINATION_ORGANIZATION_ID,
                        iscl.DESTINATION_ORGANIZATION_ID)
     and iscl.cart_id = isc.cart_id
     and iscl.cart_id = v_cart_id
     and iscl.cart_line_id = v_cart_line_id
     and nvl(isc.org_id,-9999) = nvl(v_oo_id,-9999)
     and nvl(iscl.org_id,-9999) = nvl(v_oo_id,-9999);

      CURSOR chart_account_id IS
      SELECT CHART_OF_ACCOUNTS_ID
      FROM gl_sets_of_books,
           financials_system_parameters fsp
      WHERE gl_sets_of_books.SET_OF_BOOKS_ID = fsp.set_of_books_id;

      cursor get_cart_line_number is
	select cart_line_number
      from icx_shopping_cart_lines
      where cart_id = v_cart_id
      and cart_line_id = v_cart_line_id
      and nvl(org_id, -9999) = nvl(v_oo_id,-9999);

      l_cart_line_number NUMBER := 0;

BEGIN

  if icx_sec.validatesession(c_commit => FALSE)  then
    open get_cart_line_number;
    fetch get_cart_line_number into l_cart_line_number;
    close get_cart_line_number;

    v_line_number := 1;

    -- get structure number
    open chart_account_id;
    fetch chart_account_id into v_structure;
    close chart_account_id;

    -- get account from customer default
    v_account_id := NULL;
    v_account_num := NULL;
    icx_req_custom.cart_custom_build_req_account(v_cart_line_id,
					         v_account_num,
						 v_account_id,
						 v_return_code);

    -- if customer does not return any account id or con-seg of the account
    if (v_account_num is NULL) and (v_account_id is NULL) then

       -- get the default account
       open line_default_account;
       fetch line_default_account into v_account_id;
       close line_default_account;
       if v_account_id is NULL then
          open item_expense_account;
          fetch item_expense_account into v_account_id;
          close item_expense_account;
       end if;
       if v_account_id is not NULL then
          select count(*) into v_exist
          from gl_sets_of_books gsb,
               financials_system_parameters fsp,
               gl_code_combinations gl
          where gsb.SET_OF_BOOKS_ID = fsp.set_of_books_id
          and   gsb.CHART_OF_ACCOUNTS_ID = gl.CHART_OF_ACCOUNTS_ID
          and   gl.CODE_COMBINATION_ID = v_account_id;
          if (v_exist = 0) then
             --add error
             FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
             FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_cart_line_number);
             v_error_message := FND_MESSAGE.GET;
             FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
	     v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
             icx_util.add_error(v_error_message);
             ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number);
          else -- get con-seg based on account id
             get_account_segments(v_cart_id,v_line_number,v_account_id,v_structure,v_cart_line_id,l_cart_line_number,v_n_segments,v_segments,v_account_num);
          end if;
       else
             --add error
             FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
             FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_cart_line_number);
             v_error_message := FND_MESSAGE.GET;
             FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
             v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
             icx_util.add_error(v_error_message);
             ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);

       end if;

    elsif v_account_num is not NULL then
       get_acct_by_con(v_cart_id,v_line_number,v_account_num,v_structure,v_cart_line_id,l_cart_line_number,v_n_segments,v_segments,v_account_id);

       if (v_account_id is null) or (v_account_id = 0) then
          --add error
          FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
          FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_cart_line_number);
          v_error_message := FND_MESSAGE.GET;
          FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
          v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
          icx_util.add_error(v_error_message);
          ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
          v_account_id := null;
       end if;

    end if;

    insert_row(v_cart_line_id,v_oo_id,v_cart_id,v_account_id,v_n_segments,v_segments,v_account_num);

   end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
    FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_cart_line_number || ': ' || substr(SQLERRM,1,512));
    v_error_message := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
    v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
    icx_util.add_error(v_error_message);
    ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
    -- icx_util.add_error(substr(SQLERRM, 12, 512));

END get_default_account;


/* call this to get the default account in a segment table */
PROCEDURE get_default_segs (v_cart_id IN NUMBER,
                               v_cart_line_id IN NUMBER,
                               v_emp_id IN NUMBER,
                               v_oo_id IN NUMBER,
			       v_segments OUT fnd_flex_ext.SegmentArray) IS

 v_error_message varchar(1000);
 v_structure number;
 v_expense_account number;
 v_line_number number;
 v_exist number;
 v_return_code varchar2(200);
 v_n_segments number;
 v_account_id number;
 v_account_num varchar2(2000);
 l_ret_cd BOOLEAN;
 v_delimiter varchar2(100);

 CURSOR line_default_account is
        SELECT  default_code_combination_id employee_default_account_id
        from hr_employees_current_v
        where employee_id = v_emp_id;

 CURSOR item_expense_account is
     select msi.expense_account
     from mtl_system_items msi,
     po_requisition_headers poh,
     po_requisition_lines pol
     where msi.inventory_item_id(+) = pol.item_id
       AND     nvl(msi.ORGANIZATION_ID,
                            NVL(pol.DESTINATION_ORGANIZATION_ID, -999)) =
                    nvl(pol.DESTINATION_ORGANIZATION_ID, -999)
     and pol.requisition_header_id = poh.requisition_header_id
     and pol.requisition_header_id = v_cart_id
     and pol.requisition_line_id = v_cart_line_id
     and nvl(poh.org_id,-9999) = nvl(v_oo_id,-9999)
     and nvl(pol.org_id,-9999) = nvl(v_oo_id,-9999);


      CURSOR chart_account_id IS
      SELECT CHART_OF_ACCOUNTS_ID
      FROM gl_sets_of_books,
           financials_system_parameters fsp
      WHERE gl_sets_of_books.SET_OF_BOOKS_ID = fsp.set_of_books_id;

      cursor get_req_line_number is
	select a.line_num
      from po_requisition_lines a,
           po_requisition_headers b
      where a.requisition_header_id = v_cart_id
      and   a.requisition_header_id = b.requisition_header_id
      and   a.requisition_line_id = v_cart_line_id;

      l_req_line_number NUMBER := 0;

BEGIN

  if icx_sec.validatesession(c_commit => FALSE)  then
    open get_req_line_number;
    fetch get_req_line_number into l_req_line_number;
    close get_req_line_number;

    -- get structure number
    open chart_account_id;
    fetch chart_account_id into v_structure;
    close chart_account_id;

    -- get account from customer default
    v_account_id := NULL;
    v_account_num := NULL;

    -- Call po custom account build procedure
    /* to remove icx custom
    icx_req_custom.cart_custom_build_req_account(v_cart_line_id,
					         v_account_num,
						 v_account_id,
						 v_return_code);
    */

    -- if customer does not return any account id or con-seg of the account
    if (v_account_num is NULL) and (v_account_id is NULL) then

       -- get the default account
       open line_default_account;
       fetch line_default_account into v_account_id;
       close line_default_account;
       if v_account_id is NULL then
          open item_expense_account;
          fetch item_expense_account into v_account_id;
          close item_expense_account;
       end if;

       if v_account_id is not NULL then
          l_ret_cd := fnd_flex_ext.get_segments('SQLGL',
				             'GL#',
					     v_structure,
					     v_account_id,
				             v_n_segments,
				 	     v_segments);
       end if;

    elsif v_account_num is not NULL then

      v_delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#',v_structure);
      v_account_id := fnd_flex_ext.get_ccid('SQLGL',
                       'GL#',
                       v_structure,
                       to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
                       v_account_num);
      if v_account_id is not NULL then

         l_ret_cd := fnd_flex_ext.get_segments('SQLGL',
                                'GL#',
                                v_structure,
                                v_account_id,
                                v_n_segments,
                                v_segments);
       end if;

    end if;

    if l_ret_cd = FALSE then
     v_error_message := FND_MESSAGE.GET;
     FND_MESSAGE.SET_NAME('ICX','ICX_LINE_NUMBER');
     FND_MESSAGE.SET_TOKEN('LINE_NUM_TOKEN',l_req_line_number);
     v_error_message :=  FND_MESSAGE.GET || ' ' || v_error_message;
     -- FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
     -- v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
     icx_util.add_error(v_error_message);
     -- ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
    end if;


 end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
    FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', l_req_line_number || ': ' || substr(SQLERRM,1,512));
    v_error_message := FND_MESSAGE.GET;
    ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);
    -- icx_util.add_error(substr(SQLERRM, 12, 512));

END get_default_segs;


PROCEDURE update_account_by_id(v_cart_id IN NUMBER,
			       v_cart_line_id IN NUMBER,
			       v_oo_id IN NUMBER,
                               v_distribution_id IN NUMBER,
			       v_line_number IN NUMBER) is

 v_segments fnd_flex_ext.SegmentArray;
 v_n_segments number;
 v_structure number;
 v_cart_line_number number;
 v_error_message varchar2(2000);

 CURSOR chart_account_id IS
 SELECT CHART_OF_ACCOUNTS_ID
 FROM gl_sets_of_books,
      financials_system_parameters fsp
 WHERE gl_sets_of_books.SET_OF_BOOKS_ID = fsp.set_of_books_id;

 v_account_id number;
 v_account_num varchar2(2000);
 l_ret_cd BOOLEAN;

 cursor get_account_id(cartid number,cartline_id number,oo_id number,dist_id number) is
   select charge_account_id
 from icx_cart_line_distributions
 where cart_id = cartid
 and cart_line_id = cartline_id
 and distribution_id = dist_id
 and nvl(org_id,-9999) = nvl(oo_id,-9999);

 cursor get_cart_line_number(cartid number, cartline_id number) is
    select cart_line_number
    from icx_shopping_cart_lines
    where cart_id = cartid
    and cart_line_id = cartline_id;


begin

  if icx_sec.validatesession(c_commit => FALSE)  then

    open get_cart_line_number(v_cart_id,v_cart_line_id);
    fetch get_cart_line_number into v_cart_line_number;
    close get_cart_line_number;

    -- get structure number
    open chart_account_id;
    fetch chart_account_id into v_structure;
    close chart_account_id;

    -- get account id
    open get_account_id(v_cart_id,v_cart_line_id,v_oo_id,v_distribution_id);
    fetch get_account_id into v_account_id;
    close get_account_id;

    if v_account_id is not NULL then
       l_ret_cd := fnd_flex_ext.get_segments('SQLGL',
                                             'GL#',
                                             v_structure,
                                             v_account_id,
                                             v_n_segments,
                                             v_segments);
    end if;

    if l_ret_cd <> FALSE  and v_n_segments > 0 then

       icx_req_acct2.get_acct_by_segs(v_cart_id,v_line_number,v_segments,
				      v_structure,v_cart_line_id,v_cart_line_number,
				      v_n_segments,v_account_num,v_account_id);

       icx_req_acct2.update_row(v_cart_line_id,v_oo_id,v_cart_id,v_distribution_id,
  			        v_line_number,v_account_id,v_n_segments,v_segments,
				v_account_num);

    else

          FND_MESSAGE.SET_NAME('ICX', 'ICX_INVALID_ACCOUNT');
          FND_MESSAGE.SET_TOKEN('ITEM_TOKEN', v_cart_line_number);
          v_error_message := FND_MESSAGE.GET;
          FND_MESSAGE.SET_NAME('PO','PO_ZMVOR_DISTRIBUTION');
          v_error_message := '(' || FND_MESSAGE.GET || ' ' || v_line_number || ') ' || v_error_message;
          icx_util.add_error(v_error_message);
          ICX_REQ_SUBMIT.storeerror(v_cart_id, v_error_message,v_line_number,v_cart_line_id);


    end if;

  end if;
end;

END icx_po_req_acct2;

/
