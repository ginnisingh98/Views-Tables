--------------------------------------------------------
--  DDL for Package JTF_TERR_CHANGES_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_CHANGES_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftrrcs.pls 120.0 2005/06/02 18:21:48 appldev ship $ */

PROCEDURE report_wrapper
    ( p_response IN varchar2,
      --p_manager  in varchar2,
      p_sd_date  IN varchar2,
      p_sm_date  IN varchar2,
      p_sy_date  IN varchar2,
      p_ed_date  IN varchar2,
      p_em_date  IN varchar2,
      p_ey_date  IN varchar2);

     --------------------------------------------------------------------------------------------------------------------
   PROCEDURE XLS (
   --p_manager in varchar2,
   l_from_date in date,
   l_to_date in date
  );

END; -- Package spec

 

/
