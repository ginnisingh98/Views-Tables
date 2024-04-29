--------------------------------------------------------
--  DDL for Package Body BOM_ALT_DESIGS_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_ALT_DESIGS_POLICY" AS
/* $Header: BOMSPOLB.pls 120.0 2005/05/25 06:08:48 appldev noship $*/
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMSPOLB.pls
--
--  DESCRIPTION
--
--      Package Bom_alt_desigs_policy
--	This is the package used to set the fine-grained security
--	policy for bom_alternate_designators table
--
--  NOTES
--
--  HISTORY
--
--  24-SEP-2003 Deepak Jebar      Initial Creation
--  31-MAR-2004 Deepu             Corrected cursor to include policy_owner
--  03-SEP-2004 Hari Gelli        Modified the get_alt_predicate function to handle the structures of
--                                'Packaging Hierarchy'. Structures of this type can be viewed from the product
--                                'Advanced Product Catalog'
--  23-DEC-2004 Hari Gelli        Modifed the ADD/DROP policy functions to pass object schema name as BOM
--
   PROCEDURE  add_policy IS
   p_policy_owner   FND_ORACLE_USERID.ORACLE_USERNAME%TYPE;
   l_status          VARCHAR2(1);
   l_industry        VARCHAR2(1);
   l_Prod_Schema     VARCHAR2(30);

   cursor c1 is
   select 1
   from   all_policies
   where  object_owner = p_policy_owner
   and    object_name  = 'BOM_ALTERNATE_DESIGNATORS'
   and    policy_name  = 'STRUCT_TYPE_ALTS';

   CURSOR prod_policy IS
   SELECT 1   FROM   All_Policies
   WHERE  Object_Owner = l_Prod_Schema
   AND    Object_Name  = 'BOM_ALTERNATE_DESIGNATORS'
   AND    Policy_Name  = 'STRUCT_TYPE_ALTS';

   BEGIN
      SELECT oracle_username
      into p_policy_owner
      from fnd_oracle_userid
      where read_only_flag = 'U';

      -- Checking whether policy is already defined under universal schema. (APPS)
      FOR crec IN C1 LOOP
          RETURN;
      END LOOP;

      IF NOT FND_INSTALLATION.GET_APP_INFO('BOM', l_status, l_industry, l_Prod_Schema) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Checking whether policy is already defined under product schema.
      FOR pprec IN prod_policy LOOP
          RETURN;
      END LOOP;

      DBMS_RLS.ADD_POLICY(OBJECT_SCHEMA   => l_Prod_Schema, -- We will add the policy to the BOM schema
			  OBJECT_NAME     => 'BOM_ALTERNATE_DESIGNATORS',
			  POLICY_NAME     => 'STRUCT_TYPE_ALTS',
			  --FUNCTION_SCHEMA => 'APPS',
			  POLICY_FUNCTION => 'Bom_alt_desigs_policy.get_alt_predicate',
			  STATEMENT_TYPES => 'SELECT');
      EXCEPTION
         WHEN OTHERS THEN
	    NULL;
   END add_policy;

   PROCEDURE drop_policy IS
   l_status          VARCHAR2(1);
   l_industry        VARCHAR2(1);
   l_Prod_Schema     VARCHAR2(30);
   BEGIN

      IF NOT FND_INSTALLATION.GET_APP_INFO('BOM', l_status, l_industry, l_Prod_Schema) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      BEGIN
            DBMS_RLS.DROP_POLICY(--OBJECT_SCHEMA   => l_Prod_Schema, -- We will drop the policy from the universal schema
			   OBJECT_NAME     => 'BOM_ALTERNATE_DESIGNATORS',
			   POLICY_NAME     => 'STRUCT_TYPE_ALTS');
      EXCEPTION
         WHEN OTHERS THEN
	    NULL;
      END;
      DBMS_RLS.DROP_POLICY(OBJECT_SCHEMA   => l_Prod_Schema, -- We will drop the policy from the BOM schema
			   OBJECT_NAME     => 'BOM_ALTERNATE_DESIGNATORS',
			   POLICY_NAME     => 'STRUCT_TYPE_ALTS');
      EXCEPTION
         WHEN OTHERS THEN
	    NULL;
   END drop_policy;

   FUNCTION get_alt_predicate( p_namespace in varchar2
			     , p_object in varchar2)
   RETURN VARCHAR2 IS
      l_return VARCHAR2(100);
      l_current_appl_id varchar2(10);
      l_pkghier_type_id VARCHAR2(100);
   BEGIN
	select sys_context('Struct_Type_Ctx', 'appl_id')
	into l_current_appl_id
	from dual;
	if (l_current_appl_id = to_char(G_EAM_APPLICATION)) then
		l_return := 'structure_type_id = SYS_CONTEXT(''Struct_Type_Ctx'',''struct_type_id'')';
    elsif (l_current_appl_id <> to_char(G_EGO_APPLICATION)) then
		l_pkghier_type_id := SYS_CONTEXT('Struct_Type_Ctx','pkg_struct_type_id');
		if(l_pkghier_type_id IS NULL) THEN
		  l_return := '1 = 1';
		else
		  l_return := 'structure_type_id <> ' || l_pkghier_type_id;
		end if;
	else
		l_return := '1 = 1';
	end if;
	RETURN (l_return);
   EXCEPTION
   WHEN OTHERS THEN
	l_return := '1 = 1';
	RETURN (l_return);
   END get_alt_predicate;

END Bom_alt_desigs_policy;

/
