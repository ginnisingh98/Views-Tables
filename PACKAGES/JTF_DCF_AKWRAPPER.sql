--------------------------------------------------------
--  DDL for Package JTF_DCF_AKWRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DCF_AKWRAPPER" AUTHID CURRENT_USER AS
/* $Header: jtfbakws.pls 115.3 2002/05/01 18:03:42 apandian ship $ */

  ------------------------------------------------------------------------
  --Created by  : Hyun-Sik
  --Date created: 20-NOV-2001
  --
  --Purpose:
  --  This is a wrapper for ak apis
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History: (who, when, what: NO CREATION RECORDS HERE!)
  --Who    When    What
  ------------------------------------------------------------------------

   PROCEDURE DCF_CREATE_REGION_ITEM (
      p_region_application_id IN ak_region_items.region_application_id%TYPE,
      p_region_code           IN ak_region_items.region_code%TYPE,
      p_attribute_code        IN ak_region_items.attribute_code%TYPE,
      p_display_sequence      IN ak_region_items.display_sequence%TYPE,
      p_node_display_flag     IN
         ak_region_items.node_display_flag%TYPE DEFAULT 'Y',
      p_flex_segment_list     IN ak_region_items.flex_segment_list%TYPE
   );
--
--
END jtf_dcf_akwrapper;

 

/
