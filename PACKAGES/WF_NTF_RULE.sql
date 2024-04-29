--------------------------------------------------------
--  DDL for Package WF_NTF_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NTF_RULE" AUTHID CURRENT_USER as
/* $Header: WFNRULES.pls 120.1 2005/07/02 03:16:08 appldev noship $ */

--Variables
Type custom_col_rec is record (
  rule_Name             varchar2(30),
  column_name           varchar2(30),
  attribute_name        varchar2(30),
  display_name          varchar2(32000),
  customization_level   varchar2(1),
  phase                 number,
  override              varchar2(1)
);

TYPE custom_col_type is table of custom_col_rec index by binary_integer;

--APIs
function Submit_Conc_Program_RF( p_sub_guid  in            RAW,
                                 p_event     in out NOCOPY WF_EVENT_T)
                              return VARCHAR2;

procedure simulate_rules (p_message_type        in  varchar2,
			 p_message_name         in  varchar2,
                         p_customization_level  in  varchar2,
                         x_custom_col_tbl       out nocopy custom_col_type);

end WF_NTF_RULE;


 

/
