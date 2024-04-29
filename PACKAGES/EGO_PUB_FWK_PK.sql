--------------------------------------------------------
--  DDL for Package EGO_PUB_FWK_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_PUB_FWK_PK" AUTHID CURRENT_USER AS
/* $Header: EGOPFWKS.pls 120.0.12010000.8 2009/10/22 23:05:53 trudave noship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 2003 Oracle Corporation    RedwoodShores, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : EGOPFWKS.pls
|
|DESCRIPTION : Contains modules to :
|
|
|HISTORY     :
|	      05-14-2009   Created by CHULHALE
|	      Group API to be used by other products
|	      and internally for matching
|--------------------------------------------------------------------------------
*/

TYPE BAT_ENT_OBJ_TYPE IS RECORD
(
  batch_id		    NUMBER
  ,pk1_value		  VARCHAR2(150)
  ,pk2_value		  VARCHAR2(150)
  ,pk3_value		  VARCHAR2(150)
  ,pk4_value		  VARCHAR2(150)
  ,pk5_value		  VARCHAR2(150)
  ,user_entered   VARCHAR2(1)
 );

TYPE TBL_OF_BAT_ENT_OBJ_TYPE IS TABLE OF BAT_ENT_OBJ_TYPE INDEX BY BINARY_INTEGER;

TYPE BAT_ENT_OBJ_STAT_TYPE IS RECORD
(
   batch_id		    NUMBER
  ,pk1_value		  VARCHAR2(150)
  ,pk2_value		  VARCHAR2(150)
  ,pk3_value		  VARCHAR2(150)
  ,pk4_value		  VARCHAR2(150)
  ,pk5_value		  VARCHAR2(150)
  ,system_code            VARCHAR2(30)
  ,status                  VARCHAR2(1)
  ,message                VARCHAR2(4000)
 );
TYPE TBL_OF_BAT_ENT_OBJ_STAT_TYPE IS TABLE OF BAT_ENT_OBJ_STAT_TYPE INDEX BY BINARY_INTEGER;

TYPE BAT_ENT_OBJ_RET_STAT_TYPE IS RECORD
(
   batch_id		    NUMBER
  ,pk1_value		  VARCHAR2(150)
  ,pk2_value		  VARCHAR2(150)
  ,pk3_value		  VARCHAR2(150)
  ,pk4_value		  VARCHAR2(150)
  ,pk5_value		  VARCHAR2(150)
  ,system_code            VARCHAR2(30)
  ,ret_status             VARCHAR2(1)
  ,ret_err_msg            VARCHAR2(4000)
  ,ret_err_code         VARCHAR2(4000) --!!!!!! TYPE from Ego_Publication_Batch_GT
  ,ret_err_msg_lang       VARCHAR2(4) --!!!!!!!! TYPE fromm Ego_Publication_Batch_GT
);
TYPE TBL_OF_BAT_ENT_OBJ_RSTS_TYPE IS TABLE OF BAT_ENT_OBJ_RET_STAT_TYPE INDEX BY BINARY_INTEGER;

TYPE  NUMBER_ARR_TBL_TYPE IS TABLE OF NUMBER   INDEX BY BINARY_INTEGER;
TYPE  CHAR_ARR_TBL_TYPE    IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE  CHAR1_ARR_TBL_TYPE  IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE  CHAR4_ARR_TBL_TYPE  IS TABLE OF VARCHAR2(4)   INDEX BY BINARY_INTEGER;
TYPE  CHAR30_ARR_TBL_TYPE     IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
TYPE CHAR150_ARR_TBL_TYPE IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

C_NO CONSTANT VARCHAR(1) := 'N';
C_YES CONSTANT VARCHAR(1) := 'Y';
C_IN_PROCESS CONSTANT VARCHAR(1) := 'I';
C_BATCH_MODE NUMBER := 0; -- 8773131
C_BATCH_SYSTEM_MODE NUMBER := 1;
C_BATCH_SYSTEM_ENTITY_MODE NUMBER := 2;
C_SUCCESS VARCHAR2(1) := 'S';
C_FAILED VARCHAR2(1) := 'F';
C_WARNING VARCHAR2(1) := 'W';

C_PARAM_TYPE_BATCH NUMBER(1) := 1; --batch parameter type
C_PARAM_TYPE_DEST NUMBER(1) :=2; --Dest parameters or System Type

-- Insert Entity Rows from Table of record into GT Table
PROCEDURE add_derived_entities
(
  der_bat_ent_objs  IN TBL_OF_BAT_ENT_OBJ_TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
);



Procedure Update_Pub_Status_Thru_AIA(p_batch_id IN NUMBER
				    ,p_mode In Number
				    ,x_return_status  OUT NOCOPY  VARCHAR2
				    ,x_msg_count      OUT NOCOPY  NUMBER
	                            ,x_msg_data       OUT NOCOPY  VARCHAR2);

Procedure Update_Pub_Status(	p_batch_id IN NUMBER
			       ,p_mode IN NUMBER
			       ,p_bat_status_in  IN  TBL_OF_BAT_ENT_OBJ_STAT_TYPE
                               ,x_bat_status_out OUT NOCOPY TBL_OF_BAT_ENT_OBJ_RSTS_TYPE
			       ,x_return_status  OUT NOCOPY  VARCHAR2
			       ,x_msg_count      OUT NOCOPY  NUMBER
	                       ,x_msg_data       OUT NOCOPY  VARCHAR2);

Procedure DeleteGTTableData(x_return_status OUT NOCOPY  VARCHAR2);

END EGO_PUB_FWK_PK;

/
