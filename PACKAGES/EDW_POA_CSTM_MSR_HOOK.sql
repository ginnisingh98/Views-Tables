--------------------------------------------------------
--  DDL for Package EDW_POA_CSTM_MSR_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_POA_CSTM_MSR_HOOK" AUTHID CURRENT_USER as
/*$Header: poahkcms.pls 115.1 2002/01/24 17:54:21 pkm ship    $ */
function Pre_Fact_Collect(p_object_name varchar2) return boolean;
END EDW_POA_CSTM_MSR_HOOK;


 

/
