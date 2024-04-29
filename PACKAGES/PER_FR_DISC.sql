--------------------------------------------------------
--  DDL for Package PER_FR_DISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_DISC" AUTHID CURRENT_USER as
/* $Header: hrfrdisc.pkh 115.5 2002/11/26 10:22:08 sfmorris noship $ */

procedure exec_dyn_sql (string in varchar2);

procedure grant_hr_summary (errbuf out nocopy varchar2,
                            retcode out nocopy number,
                            db_connect_string in varchar2,
                            eul_user in varchar2,
                            eul_password in varchar2);

end per_fr_disc;

 

/
