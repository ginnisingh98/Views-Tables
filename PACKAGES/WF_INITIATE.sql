--------------------------------------------------------
--  DDL for Package WF_INITIATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_INITIATE" AUTHID CURRENT_USER as
/* $Header: wfinits.pls 115.11 2002/11/11 05:34:53 rosthoma ship $ */

-- complex name#type identifiers from the web page
type name_array is table of varchar2(320) index by binary_integer;
-- values from the web page.
type value_array is table of varchar2(2000) index by binary_integer;


-- display all itemtypes in the database
procedure ItemType;

-- create input form for all data
-- required to run the process
procedure Process(
  ItemType in varchar2 default 'WFDEMO');

-- SubmitWorkflow
--   Submit the workflow
-- IN
procedure SubmitWorkflow(
  itemtype      in varchar2 default null,
  itemkey       in varchar2 default null,
  userkey       in varchar2 default null,
  process       in varchar2 default null,
  Owner  	in varchar2 default null,
  display_Owner in varchar2 default null,
  h_fnames      in Name_Array,
  h_fvalues     in Value_Array,
  h_fdocnames   in Value_Array,
  h_counter     in varchar2);



end WF_INITIATE;

 

/
