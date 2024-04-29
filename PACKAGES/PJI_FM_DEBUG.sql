--------------------------------------------------------
--  DDL for Package PJI_FM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_DEBUG" AUTHID CURRENT_USER as
  /* $Header: PJISF11S.pls 115.2 2002/09/27 21:47:56 svermett noship $ */

  procedure CONC_REQUEST_HOOK (p_process in varchar2);
  procedure CLEANUP_HOOK      (p_process in varchar2);

end PJI_FM_DEBUG;

 

/
