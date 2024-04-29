--------------------------------------------------------
--  DDL for Package CSD_REPAIR_TASK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_TASK_UTIL" AUTHID CURRENT_USER as
/* $Header: csdvrtus.pls 120.1 2005/08/09 16:26:43 sangigup noship $ csdtacts.pls */

g_txn_number NUMBER := 2005;

TYPE number_array_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

procedure string_to_array( p_x_string IN OUT NOCOPY varchar2, x_result_ids OUT NOCOPY number_array_type);

--function to get the plan name from the plan id
function get_plan_name (p_plan_id IN NUMBER ) return varchar2;

 --procedure to return plan ids for the collection ids. This will return all the plan ids
 -- for which data was collected for a given collection id.
PROCEDURE get_planIds_for_CIds(p_local_cids_array IN number_array_type,
                       x_local_plan_ids_array out NOCOPY number_array_type);

END CSD_REPAIR_TASK_UTIL;
 

/
