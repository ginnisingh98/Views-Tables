--------------------------------------------------------
--  DDL for Package Body PO_POXREQIM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXREQIM_XMLP_PKG" AS
/* $Header: POXREQIMB.pls 120.1 2007/12/25 11:42:15 krreddy noship $ */

function AfterReport return boolean is
begin

begin



         if P_interface_source_code is NULL
        and P_batch_id is NULL
        and P_delete_flag = 'Y' then
             DELETE po_interface_errors
              WHERE interface_type = 'REQIMPORT';
             DELETE po_requisitions_interface
              WHERE process_flag = 'ERROR';
              DELETE po_req_dist_interface
	      WHERE process_flag='ERROR';

      elsif
            P_interface_source_code is not NULL
        and P_batch_id is NULL
        and P_delete_flag = 'Y' then
             DELETE po_interface_errors
              WHERE interface_type = 'REQIMPORT'
                AND interface_transaction_id IN
                   (SELECT transaction_id
                      FROM po_requisitions_interface
                     WHERE process_flag = 'ERROR'
                      AND interface_source_code = P_interface_source_code
                   );
             DELETE po_requisitions_interface
              WHERE process_flag = 'ERROR'
                AND interface_source_code = P_interface_source_code;
             DELETE po_req_dist_interface
	      WHERE process_flag='ERROR'
		AND  interface_source_code = P_interface_source_code;
        elsif
            P_interface_source_code is NULL
        and P_batch_id is not NULL
        and P_delete_flag = 'Y' then
             DELETE po_interface_errors
              WHERE interface_type = 'REQIMPORT'
                AND interface_transaction_id IN
                   (SELECT transaction_id
                      FROM po_requisitions_interface
                     WHERE process_flag = 'ERROR'
                      AND batch_id = P_batch_id
                   );
             DELETE po_requisitions_interface
              WHERE process_flag = 'ERROR'
                AND batch_id = P_batch_id ;
             DELETE po_req_dist_interface
              WHERE process_flag='ERROR'
		AND batch_id=P_batch_id;

    elsif
            P_interface_source_code is not NULL
        and P_batch_id is not NULL
        and P_delete_flag = 'Y' then
            DELETE po_interface_errors
             WHERE interface_type = 'REQIMPORT'
               AND interface_transaction_id IN
                  (SELECT transaction_id
                     FROM po_requisitions_interface
                    WHERE process_flag = 'ERROR'
                      AND interface_source_code = P_interface_source_code
                      AND batch_id = P_batch_id
                  );
            DELETE po_requisitions_interface
             WHERE process_flag = 'ERROR'
               AND interface_source_code = P_interface_source_code
               AND batch_id = P_batch_id;
           DELETE po_req_dist_interface
	      WHERE process_flag='ERROR'
		AND interface_source_code=P_interface_source_code
		AND  batch_id=P_batch_id;


      end if;
end;
/*SRW.USER_EXIT('FND SRWEXIT');*/null;

return (TRUE);
end;

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  RETURN TRUE;
END;  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXREQIM_XMLP_PKG ;


/
