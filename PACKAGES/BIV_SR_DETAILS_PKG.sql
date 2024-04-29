--------------------------------------------------------
--  DDL for Package BIV_SR_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_SR_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: bivcsrds.pls 115.4 2002/11/15 16:39:13 smisra noship $ */
  procedure get_data (errbuf  out nocopy varchar2,
                      retcode out nocopy number  );
  procedure get_reclose_date(p_incident_id         number,
                             p_reopen_date         date,
                             x_reclose_date in out nocopy date);
  procedure update_reopen_reclose_date(p_incident_id  number,
                                       p_reopen_date  date,
                                       p_reclose_date date);
  procedure update_escalation_level;
  procedure get_group_levels (errbuf  out nocopy varchar2,
                              retcode out nocopy number  );
  function  get_response_time(p_incident_id number,
                              p_incident_date date) return number;
end;

 

/
