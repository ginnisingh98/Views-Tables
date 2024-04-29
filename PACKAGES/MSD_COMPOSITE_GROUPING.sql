--------------------------------------------------------
--  DDL for Package MSD_COMPOSITE_GROUPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COMPOSITE_GROUPING" AUTHID CURRENT_USER AS
/* $Header: MSDCMGRS.pls 115.1 2004/02/17 07:28:59 jarora noship $ */


   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;


   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   G_MSC_DEBUG   VARCHAR2(1) := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

PROCEDURE MSD_GROUP_STREAMS (  ERRBUF   OUT NOCOPY VARCHAR2,
			       RETCODE  OUT NOCOPY NUMBER,
			       p_mode IN NUMBER DEFAULT SYS_NO,
			       p_threshold_overlap IN NUMBER DEFAULT NULL);
/*
PROCEDURE MSD_ASSIGN_GROUPS (stream_tbl IN stream_tbl_type);
*/

FUNCTION GET_DIM_CODE (p_level_id IN NUMBER)
RETURN VARCHAR2	;

FUNCTION GET_STREAM_COUNT (p_cs_definition_id IN NUMBER)
RETURN NUMBER ;

FUNCTION number_of_designators (p_cs_definition_id IN NUMBER)
RETURN NUMBER;

END MSD_COMPOSITE_GROUPING;

 

/
