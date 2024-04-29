--------------------------------------------------------
--  DDL for Package Body MSC_CL_ISP_SUPPLIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_ISP_SUPPLIER" AS -- body
/* $Header: MSCXISPB.pls 115.0 2002/05/21 22:41:38 pkm ship        $ */

	FUNCTION GET_PO_VENDOR_ID(p_user_name varchar2) return NUMBER IS
        user_id NUMBER;
        dpl_string varchar2(2000);

    BEGIN

	    dpl_string := 'SELECT POS_VENDOR_UTIL_PKG.get_po_vendor_id_for_user(:user_name) from dual';

	    execute immediate dpl_string  into user_id using p_user_name;

	    RETURN user_id;

	EXCEPTION WHEN OTHERS THEN

		if SQLCODE = -904 THEN
		   --dbms_output.put_line('Error while getting supplier_id');
		   --dbms_output.put_line(SQLERRM);
		   return -1;
	    end if;

	END;


END MSC_CL_ISP_SUPPLIER;

/
