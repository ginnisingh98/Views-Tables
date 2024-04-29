--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_INVOICE_LINES_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_INVOICE_LINES_ID" AS
/*       $Header: gmfinvsb.pls 115.2 2002/11/11 00:39:50 rseshadr ship $ */
PROCEDURE get_invoice_lines_id
	(t_trx_type    				IN	OUT	NOCOPY VARCHAR2,
   	t_trx_type_name                 	IN	OUT     NOCOPY VARCHAR2,
	t_invoice_number			IN 	OUT	NOCOPY VARCHAR2,
	invoice_index 				IN 		NUMBER,
   	t_line_id 			      	OUT   	        NOCOPY VARCHAR2,
	row_to_fetch				IN 	OUT	NOCOPY NUMBER,
	error_status				OUT		NOCOPY NUMBER)  IS

	BEGIN

		if(invoice_index = 1) then
			if NOT cur_get_inv_lines_id1%ISOPEN then
			 	OPEN cur_get_inv_lines_id1(t_trx_type, t_trx_type_name, t_invoice_number);
			end if;

			FETCH cur_get_inv_lines_id1 INTO
				t_invoice_number,
				t_trx_type_name,
   				t_line_id;

			if cur_get_inv_lines_id1%NOTFOUND and
			   cur_get_inv_lines_id1%rowcount > 0 then
				error_status := 100;
				close cur_get_inv_lines_id1;
			elsif cur_get_inv_lines_id1%NOTFOUND and
			   cur_get_inv_lines_id1%rowcount = 0 then
				error_status := 5;
				close cur_get_inv_lines_id1;
			end if;

			if row_to_fetch = 1 and cur_get_inv_lines_id1%ISOPEN then
				close cur_get_inv_lines_id1;
			end if;
		end if;

		if(invoice_index = 6) then
			if NOT cur_get_inv_lines_id2%ISOPEN then
			 	OPEN cur_get_inv_lines_id2(t_trx_type, t_trx_type_name, t_invoice_number);
			end if;

			FETCH cur_get_inv_lines_id2 INTO
				t_invoice_number,
				t_trx_type_name,
   				t_line_id;

			if cur_get_inv_lines_id2%NOTFOUND and
			   cur_get_inv_lines_id2%rowcount > 0 then
				error_status := 100;
				close cur_get_inv_lines_id2;
			elsif cur_get_inv_lines_id2%NOTFOUND and
			   cur_get_inv_lines_id2%rowcount = 0 then
				error_status := 5;
				close cur_get_inv_lines_id2;
			end if;

			if row_to_fetch = 1 and cur_get_inv_lines_id2%ISOPEN then
				close cur_get_inv_lines_id2;
			end if;
		end if;

		if(invoice_index = 7) then
			if NOT cur_get_inv_lines_id3%ISOPEN then
			 	OPEN cur_get_inv_lines_id3(t_trx_type, t_trx_type_name, t_invoice_number);
			end if;

			FETCH cur_get_inv_lines_id3 INTO
				t_invoice_number,
				t_trx_type_name,
   				t_line_id;

			if cur_get_inv_lines_id3%NOTFOUND and
			   cur_get_inv_lines_id3%rowcount > 0 then
				error_status := 100;
				close cur_get_inv_lines_id3;
			elsif cur_get_inv_lines_id3%NOTFOUND and
			   cur_get_inv_lines_id3%rowcount = 0 then
				error_status := 5;
				close cur_get_inv_lines_id3;
			end if;

			if row_to_fetch = 1 and cur_get_inv_lines_id3%ISOPEN then
				close cur_get_inv_lines_id3;
			end if;
		end if;

		if(invoice_index = 8) then
			if NOT cur_get_inv_lines_id4%ISOPEN then
			 	OPEN cur_get_inv_lines_id4(t_trx_type, t_trx_type_name, t_invoice_number);
			end if;

			FETCH cur_get_inv_lines_id4 INTO
				t_invoice_number,
				t_trx_type_name,
   				t_line_id;

			if cur_get_inv_lines_id4%NOTFOUND and
			   cur_get_inv_lines_id4%rowcount > 0 then
				error_status := 100;
				close cur_get_inv_lines_id4;
			elsif cur_get_inv_lines_id4%NOTFOUND and
			   cur_get_inv_lines_id4%rowcount = 0 then
				error_status := 5;
				close cur_get_inv_lines_id4;
			end if;

			if row_to_fetch = 1 and cur_get_inv_lines_id4%ISOPEN then
				close cur_get_inv_lines_id4;
			end if;
		end if;

		if(invoice_index = 9) then
			if NOT cur_get_inv_lines_id5%ISOPEN then
			 	OPEN cur_get_inv_lines_id5(t_trx_type, t_trx_type_name, t_invoice_number);
			end if;

			FETCH cur_get_inv_lines_id5 INTO
				t_invoice_number,
				t_trx_type_name,
   				t_line_id;

			if cur_get_inv_lines_id5%NOTFOUND and
			   cur_get_inv_lines_id5%rowcount > 0 then
				error_status := 100;
				close cur_get_inv_lines_id5;
			elsif cur_get_inv_lines_id5%NOTFOUND and
			   cur_get_inv_lines_id5%rowcount = 0 then
				error_status := 5;
				close cur_get_inv_lines_id5;
			end if;

			if row_to_fetch = 1 and cur_get_inv_lines_id5%ISOPEN then
				close cur_get_inv_lines_id5;
			end if;
		end if;

		if(invoice_index = 2 or invoice_index = 3 or invoice_index = 4 or invoice_index = 5) then
			if NOT cur_get_inv_lines_id6%ISOPEN then
			 	OPEN cur_get_inv_lines_id6(t_trx_type, t_trx_type_name, t_invoice_number);
			end if;

			FETCH cur_get_inv_lines_id6 INTO
				t_invoice_number,
				t_trx_type_name,
   				t_line_id;

			if cur_get_inv_lines_id6%NOTFOUND and
			   cur_get_inv_lines_id6%rowcount > 0 then
				error_status := 100;
				close cur_get_inv_lines_id6;
			elsif cur_get_inv_lines_id6%NOTFOUND and
			   cur_get_inv_lines_id6%rowcount = 0 then
				error_status := 5;
				close cur_get_inv_lines_id6;
			end if;

			if row_to_fetch = 1 and cur_get_inv_lines_id6%ISOPEN then
				close cur_get_inv_lines_id6;
			end if;
		end if;

	EXCEPTION

		when others then
		error_status := SQLCODE;
	END get_invoice_lines_id;
END GMF_AR_GET_INVOICE_LINES_ID;

/
