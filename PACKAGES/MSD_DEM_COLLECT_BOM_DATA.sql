--------------------------------------------------------
--  DDL for Package MSD_DEM_COLLECT_BOM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COLLECT_BOM_DATA" AUTHID CURRENT_USER AS
/* $Header: msddemcbds.pls 120.1.12010000.3 2009/06/26 12:24:56 sjagathe noship $ */

   /*** GLOBAL VARIABLES ***/
   G_YES 	NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_YES;
   G_NO		NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_NO;


   /*** CUSTOM DATA TYPES ***/
   TYPE NUMBERLIST               IS TABLE OF NUMBER;
   TYPE DATELIST                 IS TABLE OF DATE;
   TYPE VARCHAR2LIST             IS TABLE OF VARCHAR2(255);


   TYPE PARENT_TYPE IS RECORD (
   		item_id                    NUMBER,
     	planning_factor            NUMBER,
     	quantity_per               NUMBER,
     	disable_date			   DATE);

   TYPE PARENTS IS TABLE OF PARENT_TYPE INDEX BY BINARY_INTEGER;


   /*** PROCEDURES ***
    *
    * COLLECT_BOM_DATA
    *
    *** PROCEDURES  ***/


   /*
    *
    */
   PROCEDURE COLLECT_BOM_DATA (
                        errbuf			OUT NOCOPY 	VARCHAR2,
      			retcode			OUT NOCOPY 	VARCHAR2,
      			p_sr_instance_id	IN		NUMBER );


END MSD_DEM_COLLECT_BOM_DATA;

/
