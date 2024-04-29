--------------------------------------------------------
--  DDL for Package Body BOM_SET_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_SET_CONTEXT" AS
/* $Header: BOMSCTXB.pls 120.1 2005/09/28 04:47:13 earumuga noship $*/
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMSCTXB.pls
--
--  DESCRIPTION
--
--      Package body Bom_Set_Context
--	This will be used for setting the values in context STRUCT_TYPE_CTX
--
--  NOTES
--
--  HISTORY
--
--  24-SEP-2003 Deepak Jebar      Initial Creation
--  03-SEP-2004 Hari Gelli        Added code to store the StructureTypeId of
--                                'Packaging Heirarchy' into the session.
   PROCEDURE  set_struct_type_context(p_struct_type IN VARCHAR2 DEFAULT NULL) IS
     l_structure_type_id NUMBER;
     l_pkghier_type_id NUMBER;
   BEGIN
      SELECT structure_type_id
      INTO l_structure_type_id
      FROM bom_structure_types_b
      WHERE structure_type_name = nvl(p_struct_type,'All-Structure Types');

      DBMS_SESSION.SET_CONTEXT('Struct_Type_Ctx','struct_type_id',l_structure_type_id);

      l_pkghier_type_id := null;
      BEGIN
        SELECT structure_type_id
          INTO l_pkghier_type_id
        FROM bom_structure_types_b
        WHERE structure_type_name = 'Packaging Hierarchy';
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      DBMS_SESSION.SET_CONTEXT('Struct_Type_Ctx','pkg_struct_type_id',l_pkghier_type_id);
   END set_struct_type_context;

   PROCEDURE set_application_id IS
     resp_appl_id NUMBER;
   BEGIN
      SELECT fnd_global.resp_appl_id INTO resp_appl_id
        FROM dual;
      DBMS_SESSION.SET_CONTEXT('Struct_Type_Ctx', 'appl_id', resp_appl_id);
      set_struct_type_context('Asset BOM');
   END set_application_id;

   PROCEDURE set_application_id (p_appl_resp_id IN NUMBER) IS
   BEGIN
      DBMS_SESSION.SET_CONTEXT('Struct_Type_Ctx', 'appl_id', p_appl_resp_id);
      set_struct_type_context('Asset BOM');
   END set_application_id;
END Bom_Set_Context;

/
