--------------------------------------------------------
--  DDL for Package IEC_REPORTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_REPORTS_PVT" AUTHID CURRENT_USER AS
/* $Header: IECREPS.pls 115.11 2003/08/22 20:42:32 hhuang ship $ */


/* Procedure to reset the record counts for all campaign schedules */

PROCEDURE Reset_AllRecordCounts
   ( p_source_id   IN            NUMBER
   , x_return_code IN OUT NOCOPY VARCHAR2);

/* Procedure to reset the record counts for the specified campaign schedule */

PROCEDURE Reset_CampaignRecordCounts
   ( p_schedule_id IN            NUMBER
   , p_source_id   IN            NUMBER
   , x_return_code IN OUT NOCOPY VARCHAR2);

/* Procedure to reset the record counts for the specified list */

PROCEDURE Reset_ListRecordCounts
   ( p_schedule_id IN            NUMBER
   , p_list_id     IN            NUMBER
   , p_source_id   IN            NUMBER
   , x_return_code IN OUT NOCOPY VARCHAR2);

END IEC_REPORTS_PVT;

 

/
