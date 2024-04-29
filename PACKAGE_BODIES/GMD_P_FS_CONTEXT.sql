--------------------------------------------------------
--  DDL for Package Body GMD_P_FS_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_P_FS_CONTEXT" AS
/* $Header: GMDFSCTB.pls 115.4 2002/03/15 10:23:50 pkm ship      $ */

  PROCEDURE set_additional_attr IS
   begin
      DBMS_SESSION.SET_CONTEXT('m_fs_context','pc_ind','Yes');
   end;


end;


/
