--------------------------------------------------------
--  DDL for Package MST_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_WORKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: MSTEXWFS.pls 115.1 2003/12/22 14:27:25 rshenwai noship $ */

PROCEDURE launch_workflow (errbuf   out nocopy varchar2
                          ,retcode  out nocopy number
                          ,p_plan_id in number);


PROCEDURE StartWFProcess ( p_item_type         in varchar2 default null
                         , p_item_key          in varchar2
                         , p_message           in varchar2
                         , p_workflow_process  in varchar2);


PROCEDURE Select_Planner( itemtype  in  varchar2
                        , itemkey   in  varchar2
                        , actid     in  number
                        , funcmode  in varchar2
                        , resultout out NOCOPY varchar2);


FUNCTION GetPlannerMsgName
RETURN varchar2;


PROCEDURE DeleteActivities( arg_plan_id in number);

PROCEDURE submit_workflow_request (p_request_id   out nocopy number
                                  ,p_plan_id      in         number);

/*
Procedure launch_background_program(p_planner in varchar2,
                                    p_item_type in varchar2,
                                    p_item_key in varchar2,
                                    p_request_id out NOCOPY number);

Procedure start_deferred_activity(
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_item_type varchar2,
                           p_item_key varchar2);

*/

END MST_WORKFLOW_PKG;

 

/
