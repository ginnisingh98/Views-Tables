--------------------------------------------------------
--  DDL for Package Body OKI_ALERT_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_ALERT_UTIL_PUB" AS
/* $Header: OKIPAUTB.pls 115.2 2002/04/30 16:36:50 pkm ship     $ */
--------------------------------------------------------------------------------
--
-- Modification History
-- 03-DEC-2001 brrao        Initial version
-- 30-APR-2002 mezra        Added dbdrv command and correct header syntax.
--
--------------------------------------------------------------------------------



   procedure myprint(p_str IN VARCHAR2)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.myprint(p_str);
   END; -- myprint

   procedure reportHeaderCell(p_str IN VARCHAR2,
                              p_ref in VARCHAR2)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.reportHeaderCell(p_str,p_ref);
   END; -- reportHeader

   procedure populateCell(p_str IN VARCHAR2,
                          p_align IN VARCHAR2,
                          p_link IN VARCHAR2,
                          p_class in VARCHAR2,
                          p_width in VARCHAR2)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.populateCell(p_str,p_align,p_link,p_class,p_width);
   END; -- populateCell

   PROCEDURE spaceCell(p_space in VARCHAR2,
                       p_str IN VARCHAR2,
                       p_align IN VARCHAR2,
                       p_link IN VARCHAR2,
                       p_class in VARCHAR2,
                       p_width in VARCHAR2)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.spaceCell(p_space,
                                   p_str,
                                   p_align,
                                   p_link,
                                   p_class,
                                   p_width);
   END; -- spaceCell

   procedure start_row
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.start_row;
   END; -- start_row

   procedure end_row
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.end_row;
   END; -- end_row

   procedure end_table(p_run_date IN DATE)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.end_table(p_run_date);
   END; -- end_table

   procedure start_table( p_align IN varchar2 default 'L',
                          p_cellpadding IN NUMBER default 0,
                          p_bdr in NUMBER default 0)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.start_table( p_align,
                                      p_cellpadding,
                                      p_bdr);

   END; -- start_table

   procedure create_crumb( p_title IN varchar2,
                           p_link IN VARCHAR2,
                           flag in VARCHAR2)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.create_crumb( p_title ,
                                       p_link ,
                                       flag );
   END; -- create_Crumb

   procedure create_mainheader( p_title IN varchar2, p_run_date IN DATE)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.create_mainheader( p_title,p_run_date );
   END; -- create_mainheader


   PROCEDURE create_page(p_title IN  VARCHAR2)
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.create_page(p_title );
   END;

   FUNCTION set_output_stream(p_file_name IN VARCHAR2) RETURN BOOLEAN
   IS
   BEGIN
      return OKI_ALERT_UTIL_PVT.set_output_stream(p_file_name);
   END;

   PROCEDURE end_output_stream
   IS
   BEGIN
      OKI_ALERT_UTIL_PVT.end_output_stream;
   END;

END; -- Package Body OKI_ALERT_UTIL_PUB

/
