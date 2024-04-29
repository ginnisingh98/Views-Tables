--------------------------------------------------------
--  DDL for Package WIP_SF_CUSTOM_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SF_CUSTOM_ATTRIBUTES" AUTHID CURRENT_USER AS
/* $Header: wipsfats.pls 115.7 2002/12/12 15:58:47 rmahidha ship $ */

PROCEDURE get_schedule_attr (
	orgID IN NUMBER,
	lineID IN NUMBER,
	wipEntityID IN NUMBER,
	opSeqID IN NUMBER,
	p_num_attr OUT NOCOPY NUMBER,
	p_labels OUT NOCOPY system.wip_attr_labels,
	p_values OUT NOCOPY system.wip_attr_values,
	p_colors OUT NOCOPY system.wip_attr_colors);

PROCEDURE get_event_attr (
	orgID IN NUMBER,
	lineID IN NUMBER,
	wipEntityID IN NUMBER,
	lineopSeqID IN NUMBER,    -- equals schedule's opSeqID
	opSeqNum IN NUMBER,
	p_num_attr OUT NOCOPY NUMBER,
	p_labels OUT NOCOPY system.wip_attr_labels,
	p_values OUT NOCOPY system.wip_attr_values,
	p_colors OUT NOCOPY system.wip_attr_colors);

END wip_sf_custom_attributes;

 

/
