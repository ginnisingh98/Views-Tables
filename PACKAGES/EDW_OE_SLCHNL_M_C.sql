--------------------------------------------------------
--  DDL for Package EDW_OE_SLCHNL_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OE_SLCHNL_M_C" AUTHID CURRENT_USER AS
/*$Header: ISCSCD3S.pls 115.3 2002/12/19 01:00:44 scheung ship $ */

   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);

   Procedure Push_EDW_OE_SCHN_SCHN_LSTG(p_from_date IN date, p_to_date IN DATE);

End EDW_OE_SLCHNL_M_C;

 

/
