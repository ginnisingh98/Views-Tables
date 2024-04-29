--------------------------------------------------------
--  DDL for Package WRITE_AUDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WRITE_AUDIT" AUTHID CURRENT_USER as
/* $Header: payustextio.pkh 120.0.12010000.2 2009/05/29 09:31:44 pannapur noship $ */

procedure open(p_reportname in varchar2);
procedure put(p_char in varchar2);
procedure close;

END write_audit;

/
