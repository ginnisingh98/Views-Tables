--------------------------------------------------------
--  DDL for Package BEN_EXT_XML_WRITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_XML_WRITE" AUTHID CURRENT_USER as
/* $Header: benxxmlw.pkh 120.3.12000000.1 2007/01/19 19:34:59 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract XML Write Process.
Purpose:
    This process reads records from the ben_ext_rslt_dtl table and writes them
    to a xml output file.
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        18 Apr 2003     tjesumic    115.0      Created.
        18 Apr 2003     tjesumic    115.0      NO COPY added.
        13 May 2003     tjesumic    115.2      XML user defined tag enhanceenmt
        25 Aug 2004     tjesumic    115.3      xdo integeration
        08-Jun-2005     tjesumic    115.4      pennserver extract  enhancment
        05-Dec-2005     tjesumic    115.5      display on cm manager
        09-Dec-2005      tjesumic   115.6      new parameter p_source added
*/
-----------------------------------------------------------------------------------
--
type g_table is table of ben_ext_dfn.xml_tag_name%type
  index by binary_integer;


Procedure MAIN
          (p_output_name      in varchar2,
           p_drctry_name      in varchar2,
           p_ext_rslt_id      in number,
           p_output_type      in varchar2,
           p_xdo_template_id  in number  ,
           p_cm_display_flag  in varchar2  default null  ,
           p_rec_count        in out NOCOPY  number ,
           p_source           in varchar2 default 'BENXWRIT' ) ;



Procedure  Load_tags
          (p_tag_table in out nocopy BEN_EXT_XML_WRITE.g_table ,
           p_tag       in  varchar2
           ) ;



END; -- Package spec

 

/
