--------------------------------------------------------
--  DDL for Package Body HXC_STATIC_TIMECARD_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_STATIC_TIMECARD_UTILITIES" AS
/* $Header: hxcstutil.pkb 115.6 2002/06/10 00:37:50 pkm ship      $ */

FUNCTION oracle_internal_id RETURN NUMBER IS

CURSOR c_oracle_internal IS
   SELECT bld_blk_info_type_id
     FROM hxc_bld_blk_info_types
    WHERE bld_blk_info_type = 'ORACLE_INTERNAL';

l_oracle_internal hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;

BEGIN

  OPEN c_oracle_internal;
  FETCH c_oracle_internal INTO l_oracle_internal;
  CLOSE c_oracle_internal;

  RETURN l_oracle_internal;

END oracle_internal_id;

END hxc_static_timecard_utilities;

/
