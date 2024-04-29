--------------------------------------------------------
--  DDL for Package Body WSH_AR_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_AR_INTERFACE_PUB" as
/* $Header: WSHARMGB.pls 115.0 99/07/16 08:17:48 porting ship $ */

  --
  -- PUBLIC FUNCTIONS
  --
  PROCEDURE wsh_ar_null_group_cols(
	  col_names                       IN     cnameTabTyp,
	  col_values                      IN OUT cvalTabTyp) IS
    i BINARY_INTEGER;
  Begin

    WSH_UTIL.Write_Log('Enter wsh_ar_null_grouping_rules');
    For i IN 1..col_names.count LOOP
	WSH_UTIL.Write_Log(col_names(i) || ': ' || col_values(i));
	-- test case
	--if ( col_names(i) = col_orig_bill_contact_id ) then
	    --col_values(i) := NULL;
        --end if;
    END LOOP;

    --VEHGPRLS.VEH_WSH_AR_GRP (col_names, col_values);

    WSH_UTIL.Write_Log('Exit wsh_ar_null_grouping_rules');
    return;

  End wsh_ar_null_group_cols;

END WSH_AR_INTERFACE_PUB;

/
