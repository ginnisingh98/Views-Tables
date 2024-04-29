--------------------------------------------------------
--  DDL for Package Body CCT_IKEY_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_IKEY_UPG" as
/* $Header: cctupikb.pls 115.1 2003/08/25 18:25:36 gvasvani noship $ */

procedure Change_CustomerID
IS
    l_upgraded        NUMERIC;
    status NUMERIC;
    l_loop_count          INTEGER := 0;
    BEGIN
      BEGIN
        SELECT Count(*) INTO l_upgraded
        FROM cct_interaction_keys
        WHERE interaction_key_id = 7 and interaction_key='PARTY_ID' ;
      EXCEPTION
	When Others Then
	  status := SQLCODE;
	  --dbms_output.put_line('In Change_CustomerID Proc '||SQLERRM(STATUS));
    return;
      END;
      if (l_upgraded > 0) THEN
         --dbms_output.put_line('CustomerID is Already Upgraded');
         return;
      END IF;

    update cct_interaction_keys set interaction_key='PARTY_ID' where interaction_key_id = 7;
    update CCT_CLASSIFICATION_RULES set key='PARTY_ID' where nvl(f_deletedflag,'N')<>'D' and key='CustomerID';
    --Since cct_route_params also stores dynamic route's plsql param, "sequence is not null" determines
    --that we are updating plsql params only.
    update cct_route_params set value='PARTY_ID' where value='CustomerID' and sequence is not null and nvl(f_deletedflag,'N')<>'D';
    update cct_route_params set param='PARTY_ID' where param='CustomerID' and sequence is not null and nvl(f_deletedflag,'N')<>'D';
    update cct_plsql_function_params set value='PARTY_ID' where value='CustomerID' and nvl(f_deletedflag,'N')<>'D' ;

  --dbms_output.put_line(' ');

   END Change_CustomerID;


END CCT_IKEY_UPG;

/
