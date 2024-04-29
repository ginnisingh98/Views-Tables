--------------------------------------------------------
--  DDL for Package PAY_SE_POPULATE_COUNTRIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_POPULATE_COUNTRIES" AUTHID CURRENT_USER AS
/* $Header: pysepop.pkh 120.0 2005/05/29 02:17:20 appldev noship $ */
PROCEDURE POPULATE_COUNTRIES
      (p_errbuf			OUT nocopy	VARCHAR2
      ,p_retcode		OUT nocopy	NUMBER
      ,p_business_group_id      IN  NUMBER );
END PAY_SE_POPULATE_COUNTRIES;

 

/
