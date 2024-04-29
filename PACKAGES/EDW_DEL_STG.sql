--------------------------------------------------------
--  DDL for Package EDW_DEL_STG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DEL_STG" AUTHID CURRENT_USER AS
/*$Header: EDWDELS.pls 115.6 2002/12/05 00:54:47 arsantha ship $*/

Procedure Delete_Table(p_stg_name in varchar2);
Procedure Delete_Dimension(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2,p_dim_name in varchar2, p_purge_option in number);
Procedure Delete_One_Dimension(p_dim_name in varchar2);
Procedure Delete_All_Dimensions;

Procedure Delete_Fact(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2,p_fact_name in varchar2, p_purge_option in number);
Procedure Delete_One_Fact(p_fact_name in varchar2);
Procedure Delete_All_Facts;
End EDW_DEL_STG;

 

/
