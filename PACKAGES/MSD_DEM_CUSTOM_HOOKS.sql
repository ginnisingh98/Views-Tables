--------------------------------------------------------
--  DDL for Package MSD_DEM_CUSTOM_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_CUSTOM_HOOKS" AUTHID CURRENT_USER AS
/* $Header: msddemchks.pls 120.1.12000000.2 2007/09/19 06:45:23 sjagathe noship $ */

   /* Item Hook */
   PROCEDURE ITEM_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2);

   /* Location Hook */
   PROCEDURE LOCATION_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2);

   /* History Hook */
   PROCEDURE HISTORY_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2);

   /* Upload Hook */
   PROCEDURE UPLOAD_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2);

END MSD_DEM_CUSTOM_HOOKS;

 

/
