--------------------------------------------------------
--  DDL for Package WF_TEMP_LOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_TEMP_LOB" AUTHID CURRENT_USER as
/* $Header: wflobs.pls 115.0 2003/05/07 15:24:44 vshanmug noship $*/

TYPE wf_temp_lob_rec_type IS RECORD
(
  temp_lob clob,
  free     boolean
);

TYPE wf_temp_lob_table_type IS TABLE OF
  wf_temp_lob_rec_type INDEX BY BINARY_INTEGER;

function GetLob(p_lob_tab in out nocopy wf_temp_lob_table_type)
return pls_integer;

procedure ReleaseLob(
  p_lob_tab in out nocopy wf_temp_lob_table_type,
  loc in pls_integer);

procedure ShowLob(p_lob_tab in out nocopy wf_temp_lob_table_type);

END WF_TEMP_LOB;

 

/
