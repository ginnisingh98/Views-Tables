--------------------------------------------------------
--  DDL for Package BOM_DELETE_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DELETE_GROUPS_API" AUTHID CURRENT_USER AS
/* $Header: BOMPDELS.pls 120.2.12000000.2 2007/02/20 11:26:55 bbpatel ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMPDELB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Delete_Groups_Api
--
--  NOTES
--
--  HISTORY
--
--  02-SEP-02   Vani Hymavathi    Initial Creation
***************************************************************************/

TYPE TOKEN_RECORD is RECORD(
inventory_item_id NUMBER,
organization_id NUMBER,
bill_sequence_id NUMBER,
routing_sequence_id NUMBER,
component_sequence_id NUMBER,
operation_sequence_id NUMBER,
del_group_seq_id NUMBER, -- added for bug 5546629
component_item_id NUMBER   /* Token added for bug 5726408 */
);

TYPE BIND_RECORD is RECORD(
bind_name VARCHAR2(50),
bind_value NUMBER);

TYPE BIND_TABLE is TABLE of BIND_RECORD INDEX BY BINARY_INTEGER;


 /*****************************************************************
  * Procedure : delete groups
  * Parameters IN :
  *    delete_group_id,action_type,delete_type,archive
  * Parameters OUT: ERRBUF, RETCODE
  * Purpose : Main procedure for checking and deleting a delete group
  ******************************************************************/

PROCEDURE delete_groups
(ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
 delete_group_id  IN NUMBER:= '0',
  action_type IN NUMBER:='1',
  delete_type IN NUMBER:= '1',
  archive IN NUMBER:='1',
  process_errored_rows IN VARCHAR2
  ) ;

PROCEDURE delete_groups
(ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
 delete_group_id  IN NUMBER:= '0',
  action_type IN NUMBER:='1',
  delete_type IN NUMBER:= '1',
  archive IN NUMBER:='1'
  ) ;

END;

 

/
