--------------------------------------------------------
--  DDL for Package PSA_MF_GL_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MF_GL_CONC" 
/* $Header: PSAMFGTS.pls 120.2 2006/09/13 13:03:59 agovil noship $ */
AUTHID CURRENT_USER as

procedure gl_conc(errbuf in varchar2, retcode in varchar2,posting_control_id in number);
end;

 

/
