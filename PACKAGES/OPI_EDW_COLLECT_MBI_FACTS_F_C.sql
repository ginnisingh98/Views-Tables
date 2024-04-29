--------------------------------------------------------
--  DDL for Package OPI_EDW_COLLECT_MBI_FACTS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_COLLECT_MBI_FACTS_F_C" AUTHID CURRENT_USER AS
/* $Header: OPICFCTS.pls 120.1 2005/06/10 13:40:45 appldev  $ */
  PROCEDURE PUSH (Errbuf      in out  nocopy Varchar2,
                Retcode       in out  nocopy Varchar2,
                p_from_date   IN      varchar2,
                p_to_date     IN      varchar2,
                p_fact_name   IN      VARCHAR2,
                p_staging_TABLE IN    VARCHAR2 );
END OPI_EDW_COLLECT_MBI_FACTS_F_C;

 

/
