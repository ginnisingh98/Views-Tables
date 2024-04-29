--------------------------------------------------------
--  DDL for Package HR_CHKFMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CHKFMT" AUTHID CURRENT_USER as
/* $Header: pychkfmt.pkh 115.2 2003/01/27 17:40:16 dsaxby ship $ */
   --------------------------- checkformat -----------------------------------
   /*
      NAME
         checkformat - checks format of various inputs.
      DESCRIPTION
         Entry point for the checkformat routine.
         Is used to check the validity of the following formats:
         CHAR           : arbitrary string of characters.
         UPPER          : converts string to upper case.
         LOWER          : converts string to lower case.
         INITCAP        : init caps string.
         INTEGER        : checks that input is integer.
         NUMBER         : checks input is valid decimal number.
         TIMES          : checks input is valid time.
         DATE           : checks input is valid date (DD-MON-YYYY).
         HOURS          : checks input is valid number of hours.
         DB_ITEM_NAME   : checks input is valid database item name.
         PAY_NAME       : checks input is valid payroll name.
         NACHA          : checks input contains valid nacha digits.
         KANA           : checks input is kana character.
      NOTES
         This procedure is called directly from FF RSP user exit.
         See checkformat.txt for further information on calling
         and using checkformat.
   */
   procedure checkformat
   (
      value   in out nocopy varchar2,
      format  in            varchar2,
      output  in out nocopy varchar2,
      minimum in            varchar2,
      maximum in            varchar2,
      nullok  in            varchar2,
      rgeflg  in out nocopy varchar2,
      curcode in            varchar2
   );
--
   --------------------------- changeformat -----------------------------------
   /*
      NAME
         changeformat - converts from internal to external formats.
      DESCRIPTION
         Is called when you need to convert from a format that is
         held in one format internally but which needs to be
         displayed in another format.
      NOTES
         Currently, this procedure only changes the H_HHMM format
         from internal decimal to external HH:MM type.
   */
   function changeformat
   (
      input   in     varchar2, -- the input format.
      format  in     varchar2, -- indicates the format to convert to.
      curcode in     varchar2  -- currency code for money formatting.
   ) return varchar2;
   pragma restrict_references (changeformat, WNDS, WNPS);
   procedure changeformat
   (
      input   in            varchar2, -- the input format.
      output     out nocopy varchar2, -- the output formatted.
      format  in            varchar2, -- indicates the format to convert to.
      curcode in            varchar2  -- currency code for money formatting.
   );
end hr_chkfmt;

 

/
