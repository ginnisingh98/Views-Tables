--------------------------------------------------------
--  DDL for Package Body MSC_CONC_PROG_MONITOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CONC_PROG_MONITOR" AS
	/* $Header: MSCCPRGB.pls 120.0 2005/05/25 20:10:59 appldev noship $*/

function child_requests_completed(p_request_id number) return number  is
i number := 1;
l_call_status boolean;
             l_phase            varchar2(80);
              l_status           varchar2(80);
              l_dev_phase        varchar2(80);
              l_dev_status       varchar2(80);
              l_message          varchar2(2048);
l_request_id number;
begin
    dbms_output.put_line('request id is ' || p_request_id);
    while fnd_concurrent.get_sub_requests(p_request_id).exists(i) loop
    dbms_output.put_line('sub request is ' || fnd_concurrent.get_sub_requests(p_request_id)(i).request_id ||
                                          fnd_concurrent.get_sub_requests(p_request_id)(i).dev_phase);
      if fnd_concurrent.get_sub_requests(p_request_id)(i).dev_phase <> 'COMPLETE' then
         return 0;
      end if;
      if child_requests_completed(fnd_concurrent.get_sub_requests(p_request_id)(i).request_id) <> 1 then
         return 0;
      end if;
    i:= i+ 1;
    end loop;
    l_request_id := p_request_id;
                  l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                                      ( l_request_id,
                                        NULL,
                                        NULL,
                                        l_phase,
                                        l_status,
                                        l_dev_phase,
                                        l_dev_status,
                                        l_message);
     if l_dev_phase <> 'COMPLETE' then
       return 0;
     else
       return 1;
     end if;
end;

END Msc_conc_prog_monitor;

/
