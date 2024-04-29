--------------------------------------------------------
--  DDL for Package WIP_ATO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_ATO_UTILS" AUTHID CURRENT_USER as
/* $Header: wipatous.pls 115.7 2002/11/28 13:49:05 rmahidha ship $ */

PROCEDURE check_wip_supply_type(p_so_header_id     IN NUMBER,
				p_so_line          IN VARCHAR2,
				p_so_delivery      IN VARCHAR2,
				p_org_id           IN NUMBER,
				p_wip_entity_type  IN OUT NOCOPY NUMBER,
				p_err_msg          IN OUT NOCOPY VARCHAR2);

FUNCTION check_wip_supply_type(p_so_header_id     NUMBER,
			       p_so_line          VARCHAR2,
			       p_so_delivery      VARCHAR2,
			       p_org_id           NUMBER,
			       p_supply_source_id NUMBER := -1) RETURN NUMBER;
pragma restrict_references(check_wip_supply_type, WNDS, WNPS);


PROCEDURE get_so_open_qty(p_so_header_id   IN NUMBER,
			  p_so_line        IN VARCHAR2,
			  p_so_delivery    IN VARCHAR2,
			  p_org_id         IN NUMBER,
			  p_qty            IN OUT NOCOPY NUMBER,
			  p_err_msg        IN OUT NOCOPY VARCHAR2);
END wip_ato_utils;

 

/
