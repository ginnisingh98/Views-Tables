--------------------------------------------------------
--  DDL for Package Body CTO_ENI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_ENI_WRAPPER" AS
/* $Header: CTOENIIB.pls 120.0 2005/05/25 05:25:11 appldev noship $  */

/*===========================================================================+
 |  Copyright (c) 2003 Oracle Corporation Belmont, California, USA           |
 |                       All rights reserved                                 |
 +===========================================================================+
 |                                                                           |
 | FILENAME                                                                  |
 |      CTOENIIB.pls                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 | Stubbed version of the package. This version will be called for all
 | non-dbi customers
 |                                                                           |
 | PUBLIC PROCEDURES                                                         |
 |      CTO_ENI_WRAPPER
 |
 | PUBLIC FUNCTIONS                                                          |
 |      <None>                                                               |
 |                                                                           |
 | PRIVATE PROCEDURES                                                        |
 |      <None>                                                               |
 |                                                                           |
 | PRIVATE FUNCTIONS                                                         |
 |      <None>                                                               |
 |                                                                           |
 |                                                                           |
 | HISTORY                                                                   |
 |  sbag                  09-09-03                                           |
 |
 |                   This file is owned by ENI and should not be modified by
 |		     anybody other than the ENI team. Please contact
 |                   Kiran Konada or Usha Arora if you have any questions regarding
 |                   this file.
 |
 |                   Bug: 3070429
 |                   Desc: CONFIG ITEMS WERE NOT GETTING CREATED IN THE STAR TABLE
 |
 |		     During purchase order, users can create a config. item.
 |		     This item is created in mtl_system_items_b but was not
 |		     getting propagated to the STAR table. This is because,
 |                   while creation of the config items the item is directly
 |                   inserted into mtl_system_items_b and the INV API is not
 |                   used.
 |
 |                   This file is the wrapper file around the main file that
 |                   inserts into the STAR table.
 |
 |                   Resolution:
 |                   Added a new API, create_config_items that would be called
 |                   when a config item is created.
 |
 |	             Dependency: Please refer to the bug
 |                   CTO files CTOMCFGB.pls and CTOCCFGB.pls are dependent
 |                   on the spec and body
 |
 |                   This is stubbed version.
 |                   Body with actual call to ENi procedure would be in branch
 |                   Stubbed main version is created for CTO pre-req's to be applied
 |                   on releases till 11.5.3 where ENI product doesnot exist
 |
 |                   branch version would only go as part of DBi family pack
 |                   branch version would not be part of DM family pack
 |
 +===========================================================================*/

Procedure CTO_CALL_TO_ENI(p_api_version NUMBER,
                          p_init_msg_list VARCHAR2 := 'F',
                          p_star_record CTO_ENI_WRAPPER.star_rec_type,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2)
IS

BEGIN

     X_RETURN_STATUS := 'S';

END;

END CTO_ENI_WRAPPER;


/
