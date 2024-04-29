--------------------------------------------------------
--  DDL for Package BIM_LEAD_MV_REFRESH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_LEAD_MV_REFRESH_PKG" AUTHID CURRENT_USER AS
/*$Header: bimldrss.pls 115.4 2002/11/11 20:55:03 snallapa noship $*/

   Function VALIDATE_TIME_DIM return boolean;

   Procedure GH_SUM_REFRESH (Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2);

   Procedure GEN_SG_REFRESH (Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2);

   Procedure GEN_RS_REFRESH (Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2);

   Procedure AGING_REFRESH (Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2);
   Procedure COST_REFRESH (Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2);


End BIM_LEAD_MV_REFRESH_PKG;

 

/
