--------------------------------------------------------
--  DDL for Package EDW_HR_MVMNT_TYP_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_MVMNT_TYP_M_C" AUTHID CURRENT_USER AS
/*$Header: hriepmvt.pkh 120.1 2005/06/07 05:56:01 anmajumd noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_HR_MVMT_MVMNTS_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_GAIN_1_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_LOSS_1_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_RCTMNT_1_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_SPRTN_1_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_GAIN_2_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_LOSS_2_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_RCTMNT_2_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_SPRTN_2_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_GAIN_3_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_LOSS_3_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_RCTMNT_3_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_HR_MVMT_SPRTN_3_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_HR_MVMNT_TYP_M_C;

 

/
