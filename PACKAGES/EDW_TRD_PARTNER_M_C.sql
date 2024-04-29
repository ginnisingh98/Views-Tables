--------------------------------------------------------
--  DDL for Package EDW_TRD_PARTNER_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_TRD_PARTNER_M_C" AUTHID CURRENT_USER AS
/* $Header: poapptps.pls 120.0 2005/06/01 14:22:31 appldev noship $ */

   Procedure Push_TPartner_Loc(Errbuf		out NOCOPY Varchar2,
	       Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL);
   Procedure Push_Trade_Partner(Errbuf          out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL);
   Procedure Push_P1_TPartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL);
   Procedure Push_P2_TPartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL);
   Procedure Push_P3_TPartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL);
   Procedure Push_P4_Tpartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL);

   Procedure push(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Varchar2 := NULL,
               p_to_date            Varchar2 := NULL);

End EDW_TRD_PARTNER_M_C;

 

/
