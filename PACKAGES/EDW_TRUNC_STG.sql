--------------------------------------------------------
--  DDL for Package EDW_TRUNC_STG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_TRUNC_STG" AUTHID CURRENT_USER AS
 /*$Header: EDWTRCTS.pls 115.6 2002/11/23 00:09:47 vsurendr noship $*/

Procedure truncate_Table(p_stg_name in varchar2);
Procedure Truncate_Dimension(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2,p_dim_name in varchar2);
Procedure Truncate_One_Dimension(p_dim_name in varchar2);
Procedure Truncate_All_Dimensions;

Procedure truncate_Fact(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2,p_fact_name in varchar2);
Procedure truncate_One_Fact(p_fact_name in varchar2);
Procedure truncate_All_Facts;


END; -- Package Specification EDW_TRUNC_STG

 

/
