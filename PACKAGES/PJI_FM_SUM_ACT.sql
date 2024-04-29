--------------------------------------------------------
--  DDL for Package PJI_FM_SUM_ACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_SUM_ACT" AUTHID CURRENT_USER as
  /* $Header: PJISF08S.pls 120.1 2005/10/17 12:02:21 appldev noship $ */

  procedure BASE_SUMMARY (p_worker_id in number);
  procedure CLEANUP (p_worker_id in number);

end PJI_FM_SUM_ACT;

 

/
