--------------------------------------------------------
--  DDL for Package Body MSD_DEM_CUSTOM_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_CUSTOM_HOOKS" AS
/* $Header: msddemchkb.pls 120.0.12000000.2 2007/09/19 06:47:13 sjagathe noship $ */

   /* Item Hook */
   PROCEDURE ITEM_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         retcode := -1;
         errbuf  := 'Error in msd_dem_custom_hooks.item_hook';
         RETURN;
   END ITEM_HOOK;


   /* Location Hook */
   PROCEDURE LOCATION_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         retcode := -1;
         errbuf  := 'Error in msd_dem_custom_hooks.location_hook';
         RETURN;
   END LOCATION_HOOK;

   /* History Hook */
   PROCEDURE HISTORY_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         retcode := -1;
         errbuf  := 'Error in msd_dem_custom_hooks.history_hook';
         RETURN;
   END HISTORY_HOOK;

   /* Upload Hook */
   PROCEDURE UPLOAD_HOOK (
      			errbuf		OUT NOCOPY VARCHAR2,
      			retcode		OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         retcode := -1;
         errbuf  := 'Error in msd_dem_custom_hooks.upload_hook';
         RETURN;
   END UPLOAD_HOOK;

END MSD_DEM_CUSTOM_HOOKS;

/
