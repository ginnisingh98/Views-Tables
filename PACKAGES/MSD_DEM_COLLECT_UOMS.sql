--------------------------------------------------------
--  DDL for Package MSD_DEM_COLLECT_UOMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COLLECT_UOMS" AUTHID CURRENT_USER AS
/* $Header: msddemuomcls.pls 120.0.12000000.2 2007/09/24 11:46:00 nallkuma noship $ */

procedure collect_uom(errbuf                 out nocopy varchar2,
											retcode                out nocopy number,
											p_instance_id          in  number,
											p_include_all          in  number,
											p_include_uom_list     in varchar2,
											p_exclude_uom_list     in varchar2);

function msd_dem_uom_conversion (from_unit         varchar2,
                                 to_unit           varchar2,
                                 item_id           number)
return number;

END MSD_DEM_COLLECT_UOMS;


 

/
