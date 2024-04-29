--------------------------------------------------------
--  DDL for Package OKI_ALERT_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_ALERT_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPAUTS.pls 115.3 2002/07/12 01:15:52 rpotnuru noship $  */
/*---------------------------------------------------------------------------+
|                                                                            |
|  PACKAGE: OKI_ALERT_UTIL_PUB                                               |
|  DESC   : Piblic interface for OKI ALERT UTILITIES Package
|  FILE   : OKIPAUTS.pls                                                     |
|                                                                            |
*-------------------------------------------------------------------------- */
--------------------------------------------------------------------------------
--
-- Modification History
-- 03-DEC-2001 brrao        Initial version
-- 30-APR-2002 mezra        Added dbdrv command and correct header syntax.
--
--------------------------------------------------------------------------------


   procedure myprint(p_str IN VARCHAR2);
   procedure reportHeaderCell(p_str IN VARCHAR2,
                              p_ref in VARCHAR2) ;
   procedure populateCell(p_str IN VARCHAR2,
                          p_align IN VARCHAR2,
                          p_link IN VARCHAR2,
                          p_class in VARCHAR2,
                          p_width in VARCHAR2);
   procedure spaceCell(p_space in VARCHAR2,
                       p_str IN VARCHAR2,
                       p_align IN VARCHAR2,
                       p_link IN VARCHAR2,
                       p_class in VARCHAR2,
                       p_width in VARCHAR2);
   procedure start_row;
   procedure end_row;
   procedure end_table(p_run_date IN DATE);
   procedure start_table( p_align IN varchar2 default 'L',
                          p_cellpadding IN NUMBER default 0,
                          p_bdr in NUMBER default 0);
   procedure create_crumb( p_title IN varchar2,
                           p_link IN VARCHAR2,
                           flag in VARCHAR2);
   procedure create_mainheader( p_title IN varchar2,p_run_date IN DATE);
   PROCEDURE create_page(p_title IN  VARCHAR2);
   FUNCTION set_output_stream(p_file_name IN VARCHAR2)
               RETURN BOOLEAN;
       -- 1. Success
       -- 0. Failure
   PROCEDURE end_output_stream;

END; -- Package Specification OKI_ALERT_UTIL_PUB

 

/
