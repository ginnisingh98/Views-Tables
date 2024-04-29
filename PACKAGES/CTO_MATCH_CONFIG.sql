--------------------------------------------------------
--  DDL for Package CTO_MATCH_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_MATCH_CONFIG" AUTHID CURRENT_USER as
/* $Header: CTOMCFGS.pls 120.1.12010000.2 2009/12/07 11:55:17 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : CTOMCFGS.pls						      |
| DESCRIPTION :								      |
|               This file creates packaged functions that check for matching  |
|		configurations.		                                      |
|               This file creates packaged functions that check for matching  |
|               configurations and insert unique configurations into          |
|               BOM_ATO_CONFIGURATIONS.                                       |
|                                                                             |
|               check_config_match - checks BOM_ATO_CONFIGURATIONS for        |
|               configurations that match the ordered configuration.  It      |
|               is called from the Match Configuration Workflow activity      |
|               and from the Create Configuration batch process.              |
|                                                                             |
|               can_configurations - inserts unique configurations into       |
|               BOM_ATO_CONFIGURATIONS.  It is called from the Create         |
|               Configuration batch process and the Create Configuration      |
|               Item and BOM workflow activity.                        	      |
|									      |
| HISTORY     :  							      |
|									      |
| ksarkar  07/02/03     Bugfix 2986192: Introduce new global variable
|
| kkonada  09/05/2003   added prcodures for pacthset-J
|                       ATP's (GOP) match enhancement
|
| kkonada  02/23/2003  bugfix 3259017
|                      added no copy chnages for new procedures added
|                      as part of 11.5.10
=============================================================================*/

gUserID         number       ;
gLoginId        number       ;
-- new global variable for bugfix 2986192
-- Initialized to 0
-- If matched , set this to 1 in the package body
-- reset this to 0 in create_in_src_orgs
gMatch          number       := 0;

procedure match_and_create_all_items(
        pModelLineId         in  number,
        xReturnStatus         out NOCOPY varchar2,
        xMsgCount             out NOCOPY number,
        xMsgData              out NOCOPY varchar2
        );

function check_config_match(
        p_model_line_id in      number,
        x_config_match_id out NOCOPY    number,
        x_error_message   out NOCOPY     VARCHAR2,   /* 70 bytes to hold  msg */
        x_message_name    out NOCOPY    VARCHAR2   /* 30 bytes to hold  name */
        )
return integer;


function can_configurations(
        p_model_line_id   in     number,
        prg_appid       in     number,
        prg_id          in     number,
        req_id          in     number,
        user_id         in     number,
        login_id        in     number,
        error_msg       out NOCOPY    varchar2,
        msg_name        out NOCOPY   varchar2
        )
return integer;


PROCEDURE xfer_tab_to_rec(
                p_match_rec_of_tab IN	       CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
                x_tab_of_rec       OUT  NOCOPY CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE,
		x_return_status    OUT	NOCOPY       VARCHAR2,
		x_msg_count	   OUT	NOCOPY       NUMBER,
		x_msg_data         OUT	NOCOPY       VARCHAR2

                );


PROCEDURE xfer_rec_to_tab(
                p_tab_of_rec       IN		 CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE,
		p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
		x_return_status    OUT	  NOCOPY	VARCHAR2,
		x_msg_count	   OUT	  NOCOPY	NUMBER,
		x_msg_data         OUT	  NOCOPY	VARCHAR2

                );


PROCEDURE prepare_bcol_temp_data(
                p_source           IN varchar2,
		p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
                x_return_status    OUT	  NOCOPY	VARCHAR2,
		x_msg_count	   OUT	  NOCOPY	NUMBER,
		x_msg_data         OUT	  NOCOPY	VARCHAR2
	       );

PROCEDURE Insert_into_bcol_gt(
                p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
		x_return_status    OUT	  NOCOPY	VARCHAR2,
		x_msg_count	   OUT	  NOCOPY	NUMBER,
		x_msg_data         OUT	  NOCOPY	VARCHAR2
	       );



PROCEDURE CTO_REUSE_CONFIGURATION(
		p_ato_line_id	   IN  number default null,
		X_config_change    OUT NOCOPY varchar2,
		X_return_status	   OUT NOCOPY varchar2,
		X_msg_count	   OUT NOCOPY number,
		X_msg_data	   OUT NOCOPY varchar2

		 );

PROCEDURE perform_match
 (
   p_ato_line_id     in number,
 --  p_custom_match_profile  in VARCHAR2,
   x_return_status   OUT NOCOPY	VARCHAR2,
   x_msg_count	     OUT NOCOPY	NUMBER,
   x_msg_data        OUT NOCOPY	VARCHAR2
  );



TYPE MATCH_FLAG_REC_TYPE IS RECORD
( LINE_ID		number,
  PARENT_ATO_LINE_ID    number,
  ATO_LINE_ID           number,
  MATCH_FLAG            varchar2(1)
);


--Bugfix 9148706: Indexing by LONG
--TYPE MATCH_FLAG_TBL_TYPE IS TABLE OF  MATCH_FLAG_REC_TYPE INDEX BY BINARY_INTEGER ;
TYPE MATCH_FLAG_TBL_TYPE IS TABLE OF  MATCH_FLAG_REC_TYPE INDEX BY LONG;

-- This procedure will get the Match_attribute from mtl_system_items_b
-- Will process those flags.
--Eg:
-- Model levels	  Match_ttribute	perform_match
--                (from Item form)      (calculated)
-- M1                 Y                  N
--  ---M2             N                  N
--      ----M3        Y                  Y
PROCEDURE Evaluate_N_Pop_Match_Flag
(
  p_match_flag_tab        IN	     MATCH_FLAG_TBL_TYPE,
  x_sparse_tab            OUT NOCOPY MATCH_FLAG_TBL_TYPE,
  x_return_status	  OUT NOCOPY	     VARCHAR2,
  x_msg_count		  OUT NOCOPY	     NUMBER,
  x_msg_data		  OUT NOCOPY	     VARCHAR2

);



TYPE number_arr_tbl_type	 IS TABLE OF number		index by binary_integer;
TYPE char1_arr_tbl_type		 IS TABLE of varchar2(1)	index by binary_integer;

TYPE Match_flag_rec_of_tab IS RECORD
(
  LINE_ID	number_arr_tbl_type,
  MATCH_FLAG    char1_arr_tbl_type

);




--This will transfer sparse record to record of tables
PROCEDURE xfer_match_flag_to_rec_of_tab
(

  p_sparse_tab            IN		   MATCH_FLAG_TBL_TYPE,
  x_match_flag_rec        OUT   NOCOPY     Match_flag_rec_of_tab,
  x_return_status	  OUT	NOCOPY	  VARCHAR2,
  x_msg_count		  OUT	NOCOPY	  NUMBER,
  x_msg_data		  OUT	NOCOPY	  VARCHAR2

);


PROCEDURE Update_BCOLGT_with_match_flag
(
  x_return_status	  OUT NOCOPY  VARCHAR2,
  x_msg_count		  OUT NOCOPY  NUMBER,
  x_msg_data		  OUT NOCOPY  VARCHAR2

);


end CTO_MATCH_CONFIG;

/
