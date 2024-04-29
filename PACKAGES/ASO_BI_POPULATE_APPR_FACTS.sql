--------------------------------------------------------
--  DDL for Package ASO_BI_POPULATE_APPR_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_POPULATE_APPR_FACTS" AUTHID CURRENT_USER AS
 /* $Header: asovbiapfs.pls 115.2 2003/11/06 10:28:19 rkoratag noship $ */

 --This is the Main Procedure for Initial load of approvals and rules fact table

  PROCEDURE Init_Load_Appr(errbuf    OUT NOCOPY VARCHAR2,
                           retcode     OUT NOCOPY NUMBER,
                           p_from_date IN  VARCHAR2,
                           p_to_date   IN  VARCHAR2 );

  PROCEDURE Incr_Load_Appr(errbuf    OUT NOCOPY VARCHAR2,
                           retcode     OUT NOCOPY NUMBER,
                           p_from_date IN  VARCHAR2,
                           p_to_date   IN  VARCHAR2 );

END ASO_BI_POPULATE_APPR_FACTS;

 

/
