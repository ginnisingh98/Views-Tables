--------------------------------------------------------
--  DDL for Package ARP_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_FILE" AUTHID CURRENT_USER AS
/* $Header: ARPFILES.pls 120.2 2005/10/30 03:56:04 appldev ship $*/

   MAX_DEBUG_LEVEL NUMBER:=99;
   MIN_DEBUG_LEVEL NUMBER:=0;
   INFO_LEVEL      NUMBER:=90;
   DEBUG_LEVEL_3   NUMBER:=3;
   DEBUG_LEVEL_2   NUMBER:=2;
   DEBUG_LEVEL_1   NUMBER:=1;

   PROCEDURE write_log ( p_text IN VARCHAR2,
                         p_level IN NUMBER DEFAULT MAX_DEBUG_LEVEL
                       );

   PROCEDURE print_fn_label (p_text IN VARCHAR2);

END arp_file;

 

/
