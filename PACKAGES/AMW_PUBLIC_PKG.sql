--------------------------------------------------------
--  DDL for Package AMW_PUBLIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PUBLIC_PKG" AUTHID CURRENT_USER as
/*$Header: amwpbpks.pls 115.0 2004/04/28 19:50:22 abedajna noship $*/

FUNCTION get_proc_org_opinion_status(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2;
FUNCTION get_proc_org_opinion_date(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2;

END AMW_PUBLIC_PKG;

 

/
