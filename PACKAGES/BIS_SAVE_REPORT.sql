--------------------------------------------------------
--  DDL for Package BIS_SAVE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_SAVE_REPORT" AUTHID CURRENT_USER AS
/* $Header: BISSAVES.pls 120.0 2005/06/01 18:08:07 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.7=120.0):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      bis_save_report                                         --
--                                                                        --
--  DESCRIPTION:  use this package to save and retrieve html output       --
--                from fnd_lobs                                           --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  04/10/2001 aleung     Initial creation                                --
--  01/19/2004 nkishore   Save Report to PDF                              --
----------------------------------------------------------------------------

   function  createEntry(file_name    in varchar2 default null,
                         content_type in varchar2 default 'text/plain',
                         program_name in varchar2 default null,
                         program_tag  in varchar2 default null) return number;

   procedure initWrite(file_id in number, buffer in varchar2);
   procedure initWrite(file_id in number, amount in binary_integer, buffer in raw);

   procedure appendWrite(file_id in number, buffer in varchar2);
   procedure appendWrite(file_id in number, amount in binary_integer, buffer in raw);

   procedure appendLineBreak(file_id in number);
   procedure appendWriteLine(file_id in number, buffer in varchar2);
   procedure appendWriteLine(file_id in number, amount in binary_integer, buffer in raw);

   procedure retrieve(file_id in number);
   procedure retrieve_for_php(file_id in varchar2);
   function  returnURL(file_id in number) return varchar2;

   procedure setExpirationDate(p_file_id  in varchar2);
   --Save Report to PDF
   procedure retrieve_for_pdf(p_file_id  in varchar2);

end bis_save_report;

 

/
