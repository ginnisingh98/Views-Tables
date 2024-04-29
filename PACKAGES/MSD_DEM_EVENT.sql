--------------------------------------------------------
--  DDL for Package MSD_DEM_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_EVENT" AUTHID CURRENT_USER as
/* $Header: msddemevnts.pls 120.0.12000000.2 2007/09/24 11:01:45 nallkuma noship $ */

ERROR     varchar2(100) := 'ERROR';
WARNING   varchar2(100) := 'WARNING';
SUCCESS   varchar2(100) := 'SUCCESS';
PKG_NAME  varchar2(100) := 'MSD_DEM_EVENT';


function user_change       ( p_subscription_guid in     raw, p_event             in out nocopy wf_event_t
                           ) return varchar2;

function handleError       ( p_pkg_name          in     varchar2
                           , p_function_name     in     varchar2
                           , p_event             in out nocopy wf_event_t
                           , p_subscription_guid in     raw
                           , p_error_type        in     varchar2
                           ) return varchar2;

procedure log (msg in varchar2);

end msd_dem_event;

 

/
