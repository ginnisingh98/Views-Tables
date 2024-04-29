--------------------------------------------------------
--  DDL for Package CTO_ENI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_ENI_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: CTOENIIS.pls 115.0 2003/09/11 04:38:07 kkonada noship $  */


/*===========================================================================+
 |  Copyright (c) 2003 Oracle Corporation Belmont, California, USA           |
 |                       All rights reserved                                 |
 +===========================================================================+
 |                                                                           |
 | FILENAME                                                                  |
 |      CTOENIIS.pls                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 | Wrapper to call the ENI API to populate the STAR table after a config item
 | is created
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
 |  sbag                                        09-09-03                     |
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
 +===========================================================================*/


  type STAR_REC_TYPE is RECORD
  (
      inventory_item_id  mtl_system_items_b.inventory_item_id%TYPE
      , organization_id  mtl_system_items_b.organization_id%TYPE
      , column1          number     -- for future use
      , column2          number     -- for future use
      , column3          varchar2(150)   -- for future use
      , column4          varchar2(150)   -- for future use
      , column5          date       -- for future use
   );

  Procedure CTO_CALL_TO_ENI(p_api_version NUMBER,
                          p_init_msg_list VARCHAR2 := 'F',
                          p_star_record CTO_ENI_WRAPPER.star_rec_type,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2);


END CTO_ENI_WRAPPER;

 

/
