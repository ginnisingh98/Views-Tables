--------------------------------------------------------
--  DDL for Package ONT_IMPLICITCUSTACCEPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_IMPLICITCUSTACCEPT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVAIPS.pls 120.1.12010000.2 2009/06/24 11:13:19 aambasth ship $ */
--=============================================================================
-- CONSTANTS
--=============================================================================
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ONT_ImplicitCustAccept_PVT';

--========================================================================
-- PROCEDURE : implicit_acceptance
-- PARAMETERS: p_org_id                operating unit parameter
--
-- COMMENT   : Process order lines for implicit acceptance as well as
--             accepting all the lines in pre-billing and post-billing status
--             when the system parameter is turned off.
--========================================================================
PROCEDURE implicit_acceptance
( errbuf          OUT NOCOPY VARCHAR2
, retcode         OUT NOCOPY NUMBER
, p_org_id        IN  NUMBER
, p_acceptance_date IN VARCHAR2 --bug 8293484
);

PROCEDURE process_expired_lines;
PROCEDURE process_all_lines;
PROCEDURE call_process_order_api;

FUNCTION validate_service_lines
( p_service_ref_line_id	      IN NUMBER
, p_sold_to_org_id            IN NUMBER
) RETURN BOOLEAN;

FUNCTION validate_expiration
(  p_actual_shipment_date	IN DATE
 , p_revrec_expiration_days	IN NUMBER
) RETURN BOOLEAN;

END ONT_ImplicitCustAccept_PVT;

/
