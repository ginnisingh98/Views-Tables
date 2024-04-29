--------------------------------------------------------
--  DDL for Package ASO_BI_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_MV_REFRESH" AUTHID CURRENT_USER AS
/*$Header: asovbimvrss.pls 115.5.1159.1 2003/06/24 08:42:08 kraghura noship $*/
  PROCEDURE OPEN_REFRESH (Errbuf        in out NOCOPY Varchar2,
                      Retcode       in out NOCOPY Varchar2);

  PROCEDURE QOT_REFRESH (Errbuf        in out NOCOPY Varchar2,
                      Retcode       in out NOCOPY Varchar2);

  Procedure Qot_Opty_REFRESH (Errbuf        in out NOCOPY Varchar2,
                              Retcode       in out NOCOPY Varchar2);

End ASO_BI_MV_REFRESH;

 

/
