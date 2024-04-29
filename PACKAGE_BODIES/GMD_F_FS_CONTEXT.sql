--------------------------------------------------------
--  DDL for Package Body GMD_F_FS_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_F_FS_CONTEXT" AS
/* $Header: GMDFSFCB.pls 115.3 2002/03/18 11:12:51 pkm ship      $ */

  PROCEDURE set_formula_attr IS
   begin
      DBMS_SESSION.SET_CONTEXT('f_fs_context','formula_ind','Yes');
   end;

  PROCEDURE set_non_formula_attr IS
   begin
      DBMS_SESSION.SET_CONTEXT('f_fs_context','formula_ind','No');
   end;

end;


/
