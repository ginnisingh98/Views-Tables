--------------------------------------------------------
--  DDL for Package JTF_ICXSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ICXSES" AUTHID CURRENT_USER as
/* $Header: jtficxses.pls 115.6 2003/12/10 19:57:29 sayarram noship $ */

procedure updateSessionInfo(sessionid in number, nametab in jtf_varchar2_table_100,
valtab in jtf_varchar2_table_2000, delNameTab in jtf_varchar2_Table_100 );

end jtf_icxses;

 

/
