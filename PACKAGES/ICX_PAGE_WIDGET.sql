--------------------------------------------------------
--  DDL for Package ICX_PAGE_WIDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PAGE_WIDGET" AUTHID CURRENT_USER as
/* $Header: ICXWIGS.pls 120.0 2005/10/07 12:21:51 gjimenez noship $ */


    ARRAYTOCSV_EXCEPTION    EXCEPTION;
    NBSPPAD_EXCEPTION       EXCEPTION;
    BUILDSELECTBOXES_EXCEPTION       EXCEPTION;
   procedure buildselectboxes(
      p_leftnames  in icx_api_region.array,  --- list of names of available providers:portlets
      p_leftids    in icx_api_region.array,  --- list of ids of available provider:portletids
      p_rightnames in icx_api_region.array,  --- list of names of selected providers:portlets
      p_rightids   in icx_api_region.array,  --- list of ids of selected providers:portletids:instanceids
      p_pageid     in number,
      p_regionid   in number
      );

end icx_page_widget;

 

/
