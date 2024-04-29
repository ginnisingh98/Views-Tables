--------------------------------------------------------
--  DDL for Package FND_DISCONNECTED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DISCONNECTED" AUTHID DEFINER as
/* $Header: AFSCDCNS.pls 115.1.1150.1 1999/12/22 19:44:38 pkm ship $ */

   /* This is the public API that other groups use to find out if we are */
   /* running in disconnected mode */
   function GET_DISCONNECTED return boolean;

   /* This function is only for ATG internal use; it is not for public use. */
   /* It is called when the signon form is started up with the */
   /* DISCONNECTED_MODE parameter, and returns whether this database is */
   /* in disconnected mode or not. */
   function DISCONNECTED_PARAM return boolean;

end FND_DISCONNECTED;

 

/

  GRANT EXECUTE ON "APPS"."FND_DISCONNECTED" TO "APPLSYSPUB";
