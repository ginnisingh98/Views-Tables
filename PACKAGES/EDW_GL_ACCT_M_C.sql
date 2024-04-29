--------------------------------------------------------
--  DDL for Package EDW_GL_ACCT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_GL_ACCT_M_C" AUTHID CURRENT_USER AS
/*$Header: EDWVBHPS.pls 120.0 2005/05/31 18:29:03 appldev noship $*/
   VERSION                 CONSTANT CHAR(80) :=
      '$Header: EDWVBHPS.pls 120.0 2005/05/31 18:29:03 appldev noship $';

 g_instance_code varchar2(30);
 g_target_link VARCHAR2(128);

 PROCEDURE  Push(Errbuf         out NOCOPY  Varchar2,
                 Retcode        out NOCOPY  Varchar2,
                 p_from_date    IN   Varchar2,
                 p_to_date      IN   Varchar2,
                 p_dimension_name IN varchar2);
END EDW_GL_ACCT_M_C;


 

/
