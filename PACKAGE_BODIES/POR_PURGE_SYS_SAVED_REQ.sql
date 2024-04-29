--------------------------------------------------------
--  DDL for Package Body POR_PURGE_SYS_SAVED_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_PURGE_SYS_SAVED_REQ" AS
/* $Header: PORSSPGB.pls 120.1.12000000.2 2007/10/15 09:20:14 ssachdev ship $ */

PROCEDURE purge_req(x_updated_days  IN NUMBER default 1) is

cursor c_req (p_date number) is
select distinct prh.requisition_header_id
from po_requisition_headers_all prh, po_requisition_lines_all prl
where prh.authorization_status ='SYSTEM_SAVED'
      and prh.requisition_header_id = prl.requisition_header_id (+)
      and prh.last_update_date < (sysdate-p_date)
      and prl.line_location_id is null
order by prh.requisition_header_id;

/*
select requisition_header_id
from po_requisition_headers_all
where authorization_status ='SYSTEM_SAVED'
      and last_update_date < (sysdate-p_date)
order by requisition_header_id;
*/
age number := 1;
syssaved_req_header_id number := -9999;
x_progress         varchar2(3) := null;


BEGIN

  x_progress := '000';
  age := 1;

  if(x_updated_days>1) then
    age := x_updated_days;
  end if;

  open c_req(age);

  loop
    fetch c_req into syssaved_req_header_id;

    exit when c_req%NOTFOUND;

    -- dbms_output.put_line('deleting ' || to_char(syssaved_req_header_id));

    -- bluk: call the API to delete headers, lines, and other information for the req

    --por_util_pkg.delete_requisition(syssaved_req_header_id);
    --commented the call to function delete_requsition().
    --Instead put a call to function purge_requisition(),
    --that has been added to por_util_pkg as a part of fix for bug#6368269
    por_util_pkg.purge_requisition(syssaved_req_header_id);

/*
    delete po_approval_list_lines
     where APPROVAL_LIST_HEADER_ID in
       ( select approval_list_header_id
           from po_approval_list_headers
          where document_id = syssaved_req_header_id
            and document_type = 'REQUISITION');

    delete po_approval_list_headers
     where document_id = syssaved_req_header_id
     and document_type = 'REQUISITION';

    delete PO_REQ_DISTRIBUTIONS_ALL
     where REQUISITION_LINE_ID in
       ( select requisition_line_id
           from PO_REQUISITION_LINES_ALL
          where REQUISITION_HEADER_ID = syssaved_req_header_id);

    delete PO_REQUISITION_LINES_ALL
     where REQUISITION_HEADER_ID = syssaved_req_header_id;

    delete PO_REQUISITION_HEADERS_ALL
      where REQUISITION_HEADER_ID = syssaved_req_header_id;
*/
    commit;

  end loop;
  close c_req;

exception

  when others then
    rollback;
    po_message_s.sql_error('POR_PURGE_SYS_SAVED_REQ', x_progress, sqlcode);
    raise;
end;

end POR_PURGE_SYS_SAVED_REQ;

/
