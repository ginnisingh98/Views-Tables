--------------------------------------------------------
--  DDL for Package PO_RESERVATION_MAINTAIN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RESERVATION_MAINTAIN_SV" AUTHID CURRENT_USER AS
/* $Header: POXMRESS.pls 120.4 2006/06/23 10:44:09 scolvenk noship $ */
--
-- Purpose: To maintain PO Reservation
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- rsnair      08/31/01 Created Package
-- scolvenk    07/08/2005 Plan cross Dock:4482835
--
--
PROCEDURE MAINTAIN_RESERVATION
(
 p_header_id                IN NUMBER    DEFAULT NULL
,p_line_id                  IN NUMBER    DEFAULT NULL
,p_line_location_id         IN NUMBER    DEFAULT NULL
,p_distribution_id          IN NUMBER    DEFAULT NULL
,p_action                   IN VARCHAR2
,p_recreate_demand_flag     IN VARCHAR2  DEFAULT NULL
,p_called_from_reqimport    IN VARCHAR2  DEFAULT NULL
,p_ordered_quantity         IN NUMBER    DEFAULT NULL --<R12 PLAN CROSS DOCK>
,p_transaction_id           IN NUMBER    DEFAULT NULL --<R12 PLAN CROSS DOCK>
,p_ordered_uom              IN VARCHAR2  DEFAULT NULL --5253916
,x_return_status            OUT NOCOPY VARCHAR2);
END PO_RESERVATION_MAINTAIN_SV;

 

/
