--------------------------------------------------------
--  DDL for Package OTA_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_VIEWS_PKG" AUTHID CURRENT_USER as
/* $Header: otaonvew.pkh 120.0 2005/05/29 06:57:56 appldev noship $ */

/* ==========================================================================
   FUNCTION NAME : ota_get_places_available
   DESCRIPTION   : Function to get the number of places available for an event
   ========================================================================*/
--
function OTA_GET_PLACES_AVAILABLE(p_event_id    number)
     return number ;

pragma restrict_references(OTA_GET_PLACES_AVAILABLE, WNDS, WNPS);

end OTA_VIEWS_PKG ;

 

/
