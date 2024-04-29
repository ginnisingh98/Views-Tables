--------------------------------------------------------
--  DDL for Package WIP_LEADTIME_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_LEADTIME_TEMP_PKG" AUTHID CURRENT_USER AS
/* $Header: wipltcas.pls 115.0 2003/09/18 17:52:31 kbavadek noship $ */


function wip_populate_leadtime_temp
( p_routing_sequence_id IN number ,
  p_debug_level IN number
) return number ;

function wip_delete_leadtime_temp (p_debug_level IN NUMBER) return number ;

END WIP_LEADTIME_TEMP_PKG ;

 

/
