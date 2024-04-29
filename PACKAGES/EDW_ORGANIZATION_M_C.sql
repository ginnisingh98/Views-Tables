--------------------------------------------------------
--  DDL for Package EDW_ORGANIZATION_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ORGANIZATION_M_C" AUTHID CURRENT_USER AS
/* $Header: hrieporg.pkh 120.1 2005/06/07 05:17:08 anmajumd noship $ */

   Procedure Push( Errbuf           OUT NOCOPY Varchar2
                  ,Retcode          OUT NOCOPY Varchar2
                  ,p_from_date      IN  Varchar2
                  ,p_to_date        IN  Varchar2
		);

End EDW_ORGANIZATION_M_C;

 

/
