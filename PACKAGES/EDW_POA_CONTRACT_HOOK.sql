--------------------------------------------------------
--  DDL for Package EDW_POA_CONTRACT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_POA_CONTRACT_HOOK" AUTHID CURRENT_USER as
/*$Header: poahkcts.pls 115.1 2002/01/24 17:54:24 pkm ship    $ */

function Pre_Fact_Collect(p_object_name varchar2) return boolean;
END EDW_POA_CONTRACT_HOOK;


 

/