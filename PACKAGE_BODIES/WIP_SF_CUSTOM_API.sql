--------------------------------------------------------
--  DDL for Package Body WIP_SF_CUSTOM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SF_CUSTOM_API" AS
/* $Header: wipsfcab.pls 115.10 2002/12/12 15:59:21 rmahidha ship $ */

/* If the event and schedule nodes will be showing the same information
   (which means that the event nodes will only be showing attributes
   concerning the schedule), then retrieve the attributes in
   schedule_custom_api and call this procedure from event_custom_api. */

PROCEDURE schedule_custom_api (
	scheduleNumber IN VARCHAR2,
	orgCode IN VARCHAR2,
	lineCode IN VARCHAR2,
	opSeqID IN NUMBER,
	salesOrderNumber IN VARCHAR2,
	assemblyName IN VARCHAR2,
	scheduleGroup IN VARCHAR2,
	buildSequence IN NUMBER,
	completionDate IN DATE,
	projectName IN VARCHAR2,
	taskName IN VARCHAR2,
	x_num_attr OUT NOCOPY NUMBER,
	x_labels OUT NOCOPY system.wip_attr_labels,
	x_values OUT NOCOPY system.wip_attr_values,
	x_colors OUT NOCOPY system.wip_attr_colors) IS
BEGIN

x_num_attr := 0;
x_labels := system.wip_attr_labels();
x_values := system.wip_attr_values();
x_colors := system.wip_attr_colors();
END schedule_custom_api;

PROCEDURE event_custom_api (
	scheduleNumber IN VARCHAR2,
	orgCode IN VARCHAR2,
	lineCode IN VARCHAR2,
	lineopSeqID IN NUMBER,
	opSeqNum IN NUMBER,
	opCode IN VARCHAR2,
	deptCode IN VARCHAR2,
	x_num_attr OUT NOCOPY NUMBER,
	x_labels OUT NOCOPY system.wip_attr_labels,
	x_values OUT NOCOPY system.wip_attr_values,
	x_colors OUT NOCOPY system.wip_attr_colors) IS

BEGIN

x_num_attr := 0;
x_labels := system.wip_attr_labels();
x_values := system.wip_attr_values();
x_colors := system.wip_attr_colors();
END event_custom_api;

END wip_sf_custom_api;

/
