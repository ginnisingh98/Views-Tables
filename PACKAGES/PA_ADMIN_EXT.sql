--------------------------------------------------------
--  DDL for Package PA_ADMIN_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADMIN_EXT" AUTHID CURRENT_USER as
/* $Header: PAXTRX1S.pls 115.2 99/07/16 15:35:55 porting ship  $ */


  FUNCTION  allowed_all (X_person_id IN NUMBER) return varchar2;
  PRAGMA RESTRICT_REFERENCES ( allowed_all, WNDS, WNPS );

  FUNCTION  allowed_current (X_person_id IN NUMBER, X_ending_date IN DATE) return varchar2;
  PRAGMA RESTRICT_REFERENCES ( allowed_current, WNDS, WNPS );


end pa_admin_ext;

 

/
