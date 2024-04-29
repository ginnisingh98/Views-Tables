--------------------------------------------------------
--  DDL for Package MSC_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_EVENT" AUTHID CURRENT_USER as
/* $Header: MSCEVNTS.pls 120.0 2005/06/16 23:49:48 appldev noship $ */

ERROR     varchar2(100) := 'ERROR';
WARNING   varchar2(100) := 'WARNING';
SUCCESS   varchar2(100) := 'SUCCESS';
PKG_NAME  varchar2(100) := 'MSC_EVENT';


function user_name_changed ( p_subscription_guid in     raw
                           , p_event             in out nocopy wf_event_t
                           ) return varchar2;

function handleError       ( p_pkg_name          in     varchar2
                           , p_function_name     in     varchar2
                           , p_event             in out nocopy wf_event_t
                           , p_subscription_guid in     raw
                           , p_error_type        in     varchar2
                           ) return varchar2;

procedure log (msg in varchar2);

end msc_event;

 

/
