--------------------------------------------------------
--  DDL for Package OE_OIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OIP_UTIL" AUTHID CURRENT_USER As
/* $Header: OEXUOIPS.pls 120.0 2005/06/01 03:05:24 appldev noship $*/

G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'OE_OIP_UTIL';

debug                   number  := 0;

--
--  Procedure : DELETE_OIP_AK_PAGE
--


PROCEDURE DELETE_OIP_AK_PAGE
(   p_region_page                   IN VARCHAR2
,   p_region_style                   IN VARCHAR2
);

PROCEDURE set_Debug
(   debug_flag in number
);

END OE_OIP_UTIL;


 

/
