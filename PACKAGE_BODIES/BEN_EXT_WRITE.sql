--------------------------------------------------------
--  DDL for Package Body BEN_EXT_WRITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_WRITE" as
/* $Header: benxwrit.pkb 120.16 2006/04/30 21:26:51 hgattu noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Write Process.
Purpose:
    This process reads records from the ben_ext_rslt_dtl table and writes them
    to a flat output file.
History:
     Date             Who        Version    What?
     ----             ---        -------    -----
     24 Oct 98        Ty Hayden  115.0      Created.
     11 Dec 98        Ty Hayden  115.1      Added directory logic and justification.
     04 Feb 99        Ty Hayden  115.2      Added Hide logic.
     09 Mar 99        G Perry    115.3      IS to AS.
     29 Apr 99        Ty Hayden  115.5      Super Sort.
     08 Jul 99        Ty Hayden  115.6      UTL Exception Handling.
     12 Jul 99        Ty Hayden  115.7      Initialize Globals.
                                            Fix overflow error.
     05 Aug 99        ASEN 	 115.8      Change the log report message, added directoryname, file name.
     06 Aug 99        ASEN 	 115.9      Added messages : Entering, Exiting.
     27 Sep 99        Ty Hayden  115.10     Removed directory defaulting.
     14 Jan 99        Ty Hayden  115.11     Changed record length from 200 to 2000
     26 Oct 00        rchase     115.12     wwbug 1412809 fix
                                            Changed utl_file.put statement to varchar
                                            assignment and moved to final put_line.
     30 JAN 01        tilak      115.13     wwbug 1579767 error messages is sent instead of name
     21 jun 01        tilak      115.14     gv$system_parameter used instead of v$system_parmeter
     06 JAN 02        nhunur     115.15     Added code to pickup max line size for UTL FILE from
     					    a new profile .
     16 JAN 02        hnarayan   115.16     bug 2066883 fix - Changed variable sizes to allow for
                                            record length upto 32000.
     11 mar 02        tjesumic   115.17     utf changes
     11 oct 02        tjesumic   115.18     seq_num order in the order  in cursor c_xrd
     24-Dec-02        bmanyam    115.19     NOCOPY Changes
     21-Apr-02        tjesumic   115.20     new column output_type added in extract definition
                                            if the output type is 'X'  xml procedure called
                                            to create the xml file
     10-Sep-03        tjesumic   115.21     when the last coulmns are null the delimiter appear in
                                            record as per ansi std the last deliter should not apper
                                            without data in the column the reciord end with data then
                                            the endof record delimiter , there should not be
                                            column delimiter between end of record delimiter and data
                                            so -1 lenth of string is trimed for the dlimiter 3115428
     03-Mar-04        tjesumic   115.22     delimiter value defined with 1 char and column with 90 char
                                            this cause error when the delimiter defined with more then
                                            1 char
     20-Jul-04        abparekh   115.23     Bug 3776045 : Use fnd_profile.get to fetch profile value
                                            from cache.
     25 Aug 2004      tjesumic   115.24     xdo integeration
     18 Oct 2004      nhunur     115.25     Bug : 3954449 Added union part to also look at gv$system_parameter.
     19 Oct 2004      tjesumic   115.26     RECLINKS added to overcome the 75 column limitation
     05 Nov 2004      tjesumic   115.28     115.27 reversed , RECLINKS  fixed
     09 Nov 2004      tjesumic   115.29      nvl added to last_elmt_short_name
     15 Dec 2004      tjesumic   115.30      ext_rcd_in_file id validation added in cursor
     28-jan-2004      nhunur     115.31     4143619 - removed usage of cursor c_utl.
     01-Feb-2005      tjesumic   115.32      300 elements allowed in  a record
     17-Feb-2005      tjesumic   115.33      maximum line size error captured in form before
                                              the variable length error
     17-mar-2005      nhunur     115.34      4242821 - added condition to prevent maxlinesize error.
     22-mar-2005      tjesumic   115.34      group_val_01,02 added in order  by
     06-May-2005      tjesumic   115.35      bug 4242821 reverterd  for fix 4413826. max line sise validated against
                                            variable instead of  32700
    08-Jun-2005      tjesumic    115.36/37  pennserver enhancment
    06-Oct-2005      tjesumic    115.38     c_utl cursor is removed
    20-Oct-2005      tjesumic    115.39     truncation warning dispalyed with element name
    20-Oct-2005      tjesumic    115.40     the data is not processed when element defined as hiden
    20-Oct-2005      tjesumic    115.41     short name was not assign to arry sqn no 6 , fixed
    30-Nov-2005      tjesumic    115.42     fnd_concurrent_request table updted with output file
    06-Dec-2005      tjesumic    115.43     cm_display_flag added
    16-Dec-2005      tjesumic    115.44     BEN_94036_EXT_XDO_PDF_NUL validated only for benxwrit
    16-Dec-2005      tjesumic    115.45     when the disply is on and benxwrit executed , the process
                                            rerout the proces to benxxmlwrit
    22-Dec-2005      tjesumic    115.46     XSL changed to EXCEL
    11-Jan-2006      tjesumic    115.47     BEN_94036_EXT_XDO_PDF_NUL validated only for benxwrit
    06-Feb-2006      tjesumic    115.48     new result status 'W' added
    16-Feb-2006      tjesumic    115.49     defautl 'N' assign to l_cm_disply_flag
    28-APR-2006      hgattu      115.50     new parameter p_out_dummy is added(5131931)


*/
-----------------------------------------------------------------------------------
--
g_package              varchar2(30) := ' ben_ext_write.';
--
Procedure initialize_globals is
--
  l_proc     varchar2(72) := g_package||'initialize_globals';
--
begin
--
hr_utility.set_location('Entering'||l_proc, 5);
--
g_last_rcd_processed := null;
g_business_group_id := null;
g_err_name := null;
g_person_id := null;
--
g_val.delete;
g_strt_pos.delete;
g_array.delete;
g_dlmtr_val.delete;
g_just_cd.delete;
g_short_name.delete;
g_hide_flag.delete;
/*
--
for i in 1..g_strt_pos.count loop
  if g_strt_pos(i) then
    g_strt_pos(i) := null;
  end if;
end loop;
--
for i in 1..g_array.count loop
  if g_array(i).highest_seq_num then
    g_array(i).highest_seq_num := null;
  end if;
end loop; */
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
end initialize_globals;
-----------------------------------------------------------------------------
--
procedure load_strt_pos
              (p_ext_rcd_id number,
               p_seq_num number) is
--
cursor c_xer is
  select xer.seq_num,
         xer.strt_pos,
         xer.dlmtr_val,
         xer.hide_flag,
         xde.just_cd ,
         xef.short_name
   from  ben_ext_data_elmt_in_rcd xer,
         ben_ext_data_elmt xde,
         ben_ext_fld       xef
         where xer.ext_rcd_id = p_ext_rcd_id
   and   xer.ext_data_elmt_id = xde.ext_data_elmt_id
   and   xde.ext_fld_id       = xef.ext_fld_id (+)
         order by xer.seq_num;
--
  l_proc     varchar2(72) := g_package||'load_strt_pos';
--
begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
   for l_xer in c_xer loop
      if l_xer.seq_num = 1 then
        g_array(p_seq_num).strt_pos_01  := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_01 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_01   := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_01 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_01:= l_xer.short_name;

      elsif l_xer.seq_num = 2 then
        g_array(p_seq_num).strt_pos_02 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_02 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_02 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_02 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_02   := l_xer.short_name;
      elsif l_xer.seq_num = 3 then
        g_array(p_seq_num).strt_pos_03 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_03 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_03 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_03 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_03   := l_xer.short_name;
      elsif l_xer.seq_num = 4 then
        g_array(p_seq_num).strt_pos_04 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_04 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_04 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_04 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_04   := l_xer.short_name;
      elsif l_xer.seq_num = 5 then
        g_array(p_seq_num).strt_pos_05 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_05 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_05 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_05 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_05   := l_xer.short_name;
      elsif l_xer.seq_num = 6 then
        g_array(p_seq_num).strt_pos_06 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_06 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_06 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_06 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_06   := l_xer.short_name;
      elsif l_xer.seq_num = 7 then
        g_array(p_seq_num).strt_pos_07 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_07 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_07 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_07 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_07   := l_xer.short_name;
      elsif l_xer.seq_num = 8 then
        g_array(p_seq_num).strt_pos_08 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_08 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_08 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_08 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_08   := l_xer.short_name;
      elsif l_xer.seq_num = 9 then
        g_array(p_seq_num).strt_pos_09 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_09 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_09 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_09 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_09   := l_xer.short_name;
      elsif l_xer.seq_num = 10 then
        g_array(p_seq_num).strt_pos_10 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_10 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_10 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_10 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_10   := l_xer.short_name;
      elsif l_xer.seq_num = 11 then
        g_array(p_seq_num).strt_pos_11 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_11 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_11 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_11 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_11   := l_xer.short_name;
      elsif l_xer.seq_num = 12 then
        g_array(p_seq_num).strt_pos_12 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_12 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_12 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_12 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_12   := l_xer.short_name;
      elsif l_xer.seq_num = 13 then
        g_array(p_seq_num).strt_pos_13 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_13 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_13 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_13 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_13   := l_xer.short_name;
      elsif l_xer.seq_num = 14 then
        g_array(p_seq_num).strt_pos_14 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_14 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_14 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_14 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_14   := l_xer.short_name;
      elsif l_xer.seq_num = 15 then
        g_array(p_seq_num).strt_pos_15 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_15 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_15 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_15 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_15   := l_xer.short_name;
      elsif l_xer.seq_num = 16 then
        g_array(p_seq_num).strt_pos_16 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_16 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_16 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_16 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_16   := l_xer.short_name;
      elsif l_xer.seq_num = 17 then
        g_array(p_seq_num).strt_pos_17 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_17 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_17 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_17 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_17   := l_xer.short_name;
      elsif l_xer.seq_num = 18 then
        g_array(p_seq_num).strt_pos_18  := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_18 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_18   := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_18 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_18:= l_xer.short_name;
      elsif l_xer.seq_num = 19 then
        g_array(p_seq_num).strt_pos_19 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_19 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_19 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_19 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_19   := l_xer.short_name;
      elsif l_xer.seq_num = 20 then
        g_array(p_seq_num).strt_pos_20 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_20 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_20 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_20 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_20   := l_xer.short_name;
      elsif l_xer.seq_num = 21 then
        g_array(p_seq_num).strt_pos_21 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_21 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_21 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_21 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_21   := l_xer.short_name;
      elsif l_xer.seq_num = 22 then
        g_array(p_seq_num).strt_pos_22 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_22 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_22 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_22 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_22   := l_xer.short_name;
      elsif l_xer.seq_num = 23 then
        g_array(p_seq_num).strt_pos_23 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_23 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_23 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_23 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_23   := l_xer.short_name;
      elsif l_xer.seq_num = 24 then
        g_array(p_seq_num).strt_pos_24 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_24 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_24 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_24 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_24   := l_xer.short_name;
      elsif l_xer.seq_num = 25 then
        g_array(p_seq_num).strt_pos_25 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_25 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_25 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_25 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_25   := l_xer.short_name;
      elsif l_xer.seq_num = 26 then
        g_array(p_seq_num).strt_pos_26 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_26 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_26 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_26 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_26   := l_xer.short_name;
      elsif l_xer.seq_num = 27 then
        g_array(p_seq_num).strt_pos_27 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_27 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_27 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_27 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_27   := l_xer.short_name;
      elsif l_xer.seq_num = 28 then
        g_array(p_seq_num).strt_pos_28 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_28 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_28 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_28 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_28   := l_xer.short_name;
      elsif l_xer.seq_num = 29 then
        g_array(p_seq_num).strt_pos_29 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_29 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_29 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_29 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_29   := l_xer.short_name;
      elsif l_xer.seq_num = 30 then
        g_array(p_seq_num).strt_pos_30 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_30 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_30 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_30 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_30   := l_xer.short_name;
      elsif l_xer.seq_num = 31 then
        g_array(p_seq_num).strt_pos_31 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_31 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_31 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_31 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_31   := l_xer.short_name;
      elsif l_xer.seq_num = 32 then
        g_array(p_seq_num).strt_pos_32 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_32 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_32 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_32 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_32   := l_xer.short_name;
      elsif l_xer.seq_num = 33 then
        g_array(p_seq_num).strt_pos_33 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_33 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_33 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_33 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_33   := l_xer.short_name;
      elsif l_xer.seq_num = 34 then
        g_array(p_seq_num).strt_pos_34 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_34 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_34 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_34 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_34   := l_xer.short_name;
      elsif l_xer.seq_num = 35 then
        g_array(p_seq_num).strt_pos_35 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_35 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_35 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_35 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_35   := l_xer.short_name;
      elsif l_xer.seq_num = 36 then
        g_array(p_seq_num).strt_pos_36 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_36 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_36 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_36 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_36   := l_xer.short_name;
      elsif l_xer.seq_num = 37 then
        g_array(p_seq_num).strt_pos_37 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_37 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_37 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_37 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_37   := l_xer.short_name;
      elsif l_xer.seq_num = 38 then
        g_array(p_seq_num).strt_pos_38 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_38 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_38 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_38 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_38   := l_xer.short_name;
      elsif l_xer.seq_num = 39 then
        g_array(p_seq_num).strt_pos_39 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_39 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_39 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_39 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_39   := l_xer.short_name;
      elsif l_xer.seq_num = 40 then
        g_array(p_seq_num).strt_pos_40 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_40 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_40 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_40 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_40   := l_xer.short_name;
      elsif l_xer.seq_num = 41 then
        g_array(p_seq_num).strt_pos_41 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_41 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_41 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_41 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_41   := l_xer.short_name;
      elsif l_xer.seq_num = 42 then
        g_array(p_seq_num).strt_pos_42 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_42 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_42 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_42 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_42   := l_xer.short_name;
      elsif l_xer.seq_num = 43 then
        g_array(p_seq_num).strt_pos_43 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_43 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_43 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_43 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_43   := l_xer.short_name;
      elsif l_xer.seq_num = 44 then
        g_array(p_seq_num).strt_pos_44 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_44 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_44 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_44 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_44   := l_xer.short_name;
      elsif l_xer.seq_num = 45 then
        g_array(p_seq_num).strt_pos_45 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_45 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_45 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_45 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_45   := l_xer.short_name;
      elsif l_xer.seq_num = 46 then
        g_array(p_seq_num).strt_pos_46 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_46 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_46 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_46 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_46   := l_xer.short_name;
      elsif l_xer.seq_num = 47 then
        g_array(p_seq_num).strt_pos_47 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_47 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_47 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_47 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_47   := l_xer.short_name;
      elsif l_xer.seq_num = 48 then
        g_array(p_seq_num).strt_pos_48 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_48 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_48 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_48 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_48   := l_xer.short_name;
      elsif l_xer.seq_num = 49 then
        g_array(p_seq_num).strt_pos_49 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_49 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_49 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_49 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_49   := l_xer.short_name;
      elsif l_xer.seq_num = 50 then
        g_array(p_seq_num).strt_pos_50 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_50 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_50 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_50 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_50   := l_xer.short_name;
      elsif l_xer.seq_num = 51 then
        g_array(p_seq_num).strt_pos_51 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_51 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_51 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_51 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_51   := l_xer.short_name;
      elsif l_xer.seq_num = 52 then
        g_array(p_seq_num).strt_pos_52 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_52 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_52 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_52 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_52   := l_xer.short_name;
      elsif l_xer.seq_num = 53 then
        g_array(p_seq_num).strt_pos_53 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_53 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_53 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_53 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_53   := l_xer.short_name;
      elsif l_xer.seq_num = 54 then
        g_array(p_seq_num).strt_pos_54 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_54 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_54 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_54 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_54   := l_xer.short_name;
      elsif l_xer.seq_num = 55 then
        g_array(p_seq_num).strt_pos_55 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_55 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_55 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_55 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_55   := l_xer.short_name;
      elsif l_xer.seq_num = 56 then
        g_array(p_seq_num).strt_pos_56 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_56 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_56 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_56 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_56   := l_xer.short_name;
      elsif l_xer.seq_num = 57 then
        g_array(p_seq_num).strt_pos_57 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_57 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_57 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_57 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_57   := l_xer.short_name;
      elsif l_xer.seq_num = 58 then
        g_array(p_seq_num).strt_pos_58 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_58 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_58 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_58 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_58   := l_xer.short_name;
      elsif l_xer.seq_num = 59 then
        g_array(p_seq_num).strt_pos_59 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_59 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_59 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_59 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_59   := l_xer.short_name;
      elsif l_xer.seq_num = 60 then
        g_array(p_seq_num).strt_pos_60 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_60 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_60 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_60 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_60   := l_xer.short_name;
      elsif l_xer.seq_num = 61 then
        g_array(p_seq_num).strt_pos_61 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_61 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_61 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_61 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_61   := l_xer.short_name;
      elsif l_xer.seq_num = 62 then
        g_array(p_seq_num).strt_pos_62 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_62 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_62 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_62 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_62   := l_xer.short_name;
      elsif l_xer.seq_num = 63 then
        g_array(p_seq_num).strt_pos_63 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_63 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_63 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_63 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_63   := l_xer.short_name;
      elsif l_xer.seq_num = 64 then
        g_array(p_seq_num).strt_pos_64 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_64 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_64 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_64 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_64   := l_xer.short_name;
      elsif l_xer.seq_num = 65 then
        g_array(p_seq_num).strt_pos_65 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_65 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_65 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_65 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_65   := l_xer.short_name;
      elsif l_xer.seq_num = 66 then
        g_array(p_seq_num).strt_pos_66 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_66 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_66 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_66 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_66   := l_xer.short_name;
      elsif l_xer.seq_num = 67 then
        g_array(p_seq_num).strt_pos_67 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_67 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_67 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_67 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_67   := l_xer.short_name;
      elsif l_xer.seq_num = 68 then
        g_array(p_seq_num).strt_pos_68 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_68 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_68 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_68 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_68   := l_xer.short_name;
      elsif l_xer.seq_num = 69 then
        g_array(p_seq_num).strt_pos_69 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_69 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_69 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_69 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_69   := l_xer.short_name;
      elsif l_xer.seq_num = 70 then
        g_array(p_seq_num).strt_pos_70 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_70 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_70 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_70 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_70   := l_xer.short_name;
      elsif l_xer.seq_num = 71 then
        g_array(p_seq_num).strt_pos_71 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_71 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_71 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_71 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_71   := l_xer.short_name;
      elsif l_xer.seq_num = 72 then
        g_array(p_seq_num).strt_pos_72 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_72 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_72 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_72 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_72   := l_xer.short_name;
      elsif l_xer.seq_num = 73 then
        g_array(p_seq_num).strt_pos_73 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_73 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_73 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_73 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_73   := l_xer.short_name;
      elsif l_xer.seq_num = 74 then
        g_array(p_seq_num).strt_pos_74 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_74 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_74 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_74 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_74   := l_xer.short_name;
      elsif l_xer.seq_num = 75 then
        g_array(p_seq_num).strt_pos_75 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_75 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_75 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_75 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_75   := l_xer.short_name;
            elsif l_xer.seq_num = 76 then
        g_array(p_seq_num).strt_pos_76 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_76 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_76 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_76 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_76   := l_xer.short_name;
      elsif l_xer.seq_num = 77 then
        g_array(p_seq_num).strt_pos_77 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_77 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_77 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_77 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_77   := l_xer.short_name;
      elsif l_xer.seq_num = 78 then
        g_array(p_seq_num).strt_pos_78 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_78 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_78 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_78 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_78   := l_xer.short_name;
      elsif l_xer.seq_num = 79 then
        g_array(p_seq_num).strt_pos_79 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_79 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_79 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_79 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_79   := l_xer.short_name;
      elsif l_xer.seq_num = 80 then
        g_array(p_seq_num).strt_pos_80 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_80 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_80 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_80 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_80   := l_xer.short_name;
      elsif l_xer.seq_num = 81 then
        g_array(p_seq_num).strt_pos_81 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_81 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_81 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_81 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_81   := l_xer.short_name;
      elsif l_xer.seq_num = 82 then
        g_array(p_seq_num).strt_pos_82 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_82 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_82 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_82 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_82   := l_xer.short_name;
      elsif l_xer.seq_num = 83 then
        g_array(p_seq_num).strt_pos_83 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_83 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_83 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_83 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_83   := l_xer.short_name;
      elsif l_xer.seq_num = 84 then
        g_array(p_seq_num).strt_pos_84 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_84 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_84 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_84 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_84   := l_xer.short_name;
      elsif l_xer.seq_num = 85 then
        g_array(p_seq_num).strt_pos_85 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_85 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_85 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_85 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_85   := l_xer.short_name;
      elsif l_xer.seq_num = 86 then
        g_array(p_seq_num).strt_pos_86 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_86 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_86 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_86 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_86   := l_xer.short_name;
      elsif l_xer.seq_num = 87 then
        g_array(p_seq_num).strt_pos_87 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_87 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_87 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_87 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_87   := l_xer.short_name;
      elsif l_xer.seq_num = 88 then
        g_array(p_seq_num).strt_pos_88 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_88 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_88 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_88 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_88   := l_xer.short_name;
      elsif l_xer.seq_num = 89 then
        g_array(p_seq_num).strt_pos_89 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_89 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_89 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_89 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_89   := l_xer.short_name;
      elsif l_xer.seq_num = 90 then
        g_array(p_seq_num).strt_pos_90 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_90 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_90 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_90 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_90   := l_xer.short_name;
      elsif l_xer.seq_num = 91 then
        g_array(p_seq_num).strt_pos_91 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_91 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_91 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_91 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_91   := l_xer.short_name;
      elsif l_xer.seq_num = 92 then
        g_array(p_seq_num).strt_pos_92 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_92 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_92 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_92 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_92   := l_xer.short_name;
      elsif l_xer.seq_num = 93 then
        g_array(p_seq_num).strt_pos_93 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_93 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_93 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_93 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_93   := l_xer.short_name;
      elsif l_xer.seq_num = 94 then
        g_array(p_seq_num).strt_pos_94 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_94 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_94 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_94 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_94   := l_xer.short_name;
      elsif l_xer.seq_num = 95 then
        g_array(p_seq_num).strt_pos_95 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_95 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_95 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_95 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_95   := l_xer.short_name;
            elsif l_xer.seq_num = 96 then
        g_array(p_seq_num).strt_pos_96 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_96 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_96 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_96 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_96   := l_xer.short_name;
      elsif l_xer.seq_num = 97 then
        g_array(p_seq_num).strt_pos_97 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_97 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_97 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_97 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_97   := l_xer.short_name;
      elsif l_xer.seq_num = 98 then
        g_array(p_seq_num).strt_pos_98 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_98 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_98 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_98 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_98   := l_xer.short_name;
      elsif l_xer.seq_num = 99 then
        g_array(p_seq_num).strt_pos_99 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_99 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_99 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_99 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_99   := l_xer.short_name;
      elsif l_xer.seq_num = 100 then
        g_array(p_seq_num).strt_pos_100 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_100 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_100 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_100 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_100   := l_xer.short_name;
     elsif l_xer.seq_num = 101 then
        g_array(p_seq_num).strt_pos_101  := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_101 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_101   := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_101 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_101:= l_xer.short_name;

      elsif l_xer.seq_num = 102 then
        g_array(p_seq_num).strt_pos_102 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_102 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_102 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_102 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_102   := l_xer.short_name;
      elsif l_xer.seq_num = 103 then
        g_array(p_seq_num).strt_pos_103 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_103 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_103 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_103 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_103   := l_xer.short_name;
      elsif l_xer.seq_num = 104 then
        g_array(p_seq_num).strt_pos_104 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_104 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_104 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_104 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_104   := l_xer.short_name;
      elsif l_xer.seq_num = 105 then
        g_array(p_seq_num).strt_pos_105 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_105 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_105 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_105 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_105   := l_xer.short_name;
      elsif l_xer.seq_num = 106 then
        g_array(p_seq_num).strt_pos_106 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_106 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_106 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_106 := l_xer.hide_flag;
      elsif l_xer.seq_num = 107 then
        g_array(p_seq_num).strt_pos_107 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_107 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_107 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_107 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_107   := l_xer.short_name;
      elsif l_xer.seq_num = 108 then
        g_array(p_seq_num).strt_pos_108 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_108 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_108 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_108 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_108   := l_xer.short_name;
      elsif l_xer.seq_num = 109 then
        g_array(p_seq_num).strt_pos_109 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_109 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_109 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_109 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_109   := l_xer.short_name;
      elsif l_xer.seq_num = 110 then
        g_array(p_seq_num).strt_pos_110 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_110 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_110 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_110 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_110   := l_xer.short_name;
      elsif l_xer.seq_num = 111 then
        g_array(p_seq_num).strt_pos_111 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_111 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_111 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_111 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_111   := l_xer.short_name;
      elsif l_xer.seq_num = 112 then
        g_array(p_seq_num).strt_pos_112 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_112 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_112 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_112 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_112   := l_xer.short_name;
      elsif l_xer.seq_num = 113 then
        g_array(p_seq_num).strt_pos_113 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_113 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_113 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_113 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_113   := l_xer.short_name;
      elsif l_xer.seq_num = 114 then
        g_array(p_seq_num).strt_pos_114 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_114 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_114 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_114 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_114   := l_xer.short_name;
      elsif l_xer.seq_num = 115 then
        g_array(p_seq_num).strt_pos_115 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_115 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_115 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_115 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_115   := l_xer.short_name;
      elsif l_xer.seq_num = 116 then
        g_array(p_seq_num).strt_pos_116 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_116 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_116 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_116 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_116   := l_xer.short_name;
      elsif l_xer.seq_num = 117 then
        g_array(p_seq_num).strt_pos_117 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_117 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_117 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_117 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_117   := l_xer.short_name;
      elsif l_xer.seq_num = 118 then
        g_array(p_seq_num).strt_pos_118  := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_118 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_118   := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_118 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_118:= l_xer.short_name;
      elsif l_xer.seq_num = 119 then
        g_array(p_seq_num).strt_pos_119 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_119 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_119 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_119 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_119   := l_xer.short_name;
      elsif l_xer.seq_num = 120 then
        g_array(p_seq_num).strt_pos_120 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_120 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_120 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_120 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_120   := l_xer.short_name;
      elsif l_xer.seq_num = 121 then
        g_array(p_seq_num).strt_pos_121 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_121 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_121 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_121 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_121   := l_xer.short_name;
      elsif l_xer.seq_num = 122 then
        g_array(p_seq_num).strt_pos_122 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_122 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_122 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_122 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_122   := l_xer.short_name;
      elsif l_xer.seq_num = 123 then
        g_array(p_seq_num).strt_pos_123 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_123 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_123 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_123 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_123   := l_xer.short_name;
      elsif l_xer.seq_num = 124 then
        g_array(p_seq_num).strt_pos_124 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_124 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_124 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_124 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_124   := l_xer.short_name;
      elsif l_xer.seq_num = 125 then
        g_array(p_seq_num).strt_pos_125 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_125 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_125 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_125 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_125   := l_xer.short_name;
      elsif l_xer.seq_num = 126 then
        g_array(p_seq_num).strt_pos_126 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_126 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_126 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_126 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_126   := l_xer.short_name;
      elsif l_xer.seq_num = 127 then
        g_array(p_seq_num).strt_pos_127 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_127 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_127 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_127 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_127   := l_xer.short_name;
      elsif l_xer.seq_num = 128 then
        g_array(p_seq_num).strt_pos_128 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_128 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_128 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_128 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_128   := l_xer.short_name;
      elsif l_xer.seq_num = 129 then
        g_array(p_seq_num).strt_pos_129 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_129 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_129 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_129 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_129   := l_xer.short_name;
      elsif l_xer.seq_num = 130 then
        g_array(p_seq_num).strt_pos_130 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_130 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_130 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_130 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_130   := l_xer.short_name;
      elsif l_xer.seq_num = 131 then
        g_array(p_seq_num).strt_pos_131 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_131 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_131 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_131 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_131   := l_xer.short_name;
      elsif l_xer.seq_num = 132 then
        g_array(p_seq_num).strt_pos_132 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_132 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_132 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_132 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_132   := l_xer.short_name;
      elsif l_xer.seq_num = 133 then
        g_array(p_seq_num).strt_pos_133 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_133 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_133 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_133 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_133   := l_xer.short_name;
      elsif l_xer.seq_num = 134 then
        g_array(p_seq_num).strt_pos_134 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_134 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_134 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_134 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_134   := l_xer.short_name;
      elsif l_xer.seq_num = 135 then
        g_array(p_seq_num).strt_pos_135 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_135 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_135 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_135 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_135   := l_xer.short_name;
      elsif l_xer.seq_num = 136 then
        g_array(p_seq_num).strt_pos_136 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_136 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_136 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_136 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_136   := l_xer.short_name;
      elsif l_xer.seq_num = 137 then
        g_array(p_seq_num).strt_pos_137 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_137 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_137 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_137 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_137   := l_xer.short_name;
      elsif l_xer.seq_num = 138 then
        g_array(p_seq_num).strt_pos_138 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_138 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_138 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_138 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_138   := l_xer.short_name;
      elsif l_xer.seq_num = 139 then
        g_array(p_seq_num).strt_pos_139 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_139 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_139 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_139 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_139   := l_xer.short_name;
      elsif l_xer.seq_num = 140 then
        g_array(p_seq_num).strt_pos_140 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_140 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_140 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_140 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_140   := l_xer.short_name;
      elsif l_xer.seq_num = 141 then
        g_array(p_seq_num).strt_pos_141 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_141 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_141 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_141 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_141   := l_xer.short_name;
      elsif l_xer.seq_num = 142 then
        g_array(p_seq_num).strt_pos_142 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_142 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_142 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_142 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_142   := l_xer.short_name;
      elsif l_xer.seq_num = 143 then
        g_array(p_seq_num).strt_pos_143 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_143 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_143 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_143 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_143   := l_xer.short_name;
      elsif l_xer.seq_num = 144 then
        g_array(p_seq_num).strt_pos_144 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_144 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_144 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_144 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_144   := l_xer.short_name;
      elsif l_xer.seq_num = 145 then
        g_array(p_seq_num).strt_pos_145 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_145 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_145 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_145 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_145   := l_xer.short_name;
      elsif l_xer.seq_num = 146 then
        g_array(p_seq_num).strt_pos_146 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_146 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_146 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_146 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_146   := l_xer.short_name;
      elsif l_xer.seq_num = 147 then
        g_array(p_seq_num).strt_pos_147 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_147 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_147 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_147 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_147   := l_xer.short_name;
      elsif l_xer.seq_num = 148 then
        g_array(p_seq_num).strt_pos_148 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_148 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_148 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_148 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_148   := l_xer.short_name;
      elsif l_xer.seq_num = 149 then
        g_array(p_seq_num).strt_pos_149 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_149 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_149 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_149 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_149   := l_xer.short_name;
      elsif l_xer.seq_num = 150 then
        g_array(p_seq_num).strt_pos_150 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_150 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_150 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_150 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_150   := l_xer.short_name;
      elsif l_xer.seq_num = 151 then
        g_array(p_seq_num).strt_pos_151 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_151 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_151 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_151 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_151   := l_xer.short_name;
      elsif l_xer.seq_num = 152 then
        g_array(p_seq_num).strt_pos_152 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_152 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_152 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_152 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_152   := l_xer.short_name;
      elsif l_xer.seq_num = 153 then
        g_array(p_seq_num).strt_pos_153 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_153 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_153 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_153 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_153   := l_xer.short_name;
      elsif l_xer.seq_num = 154 then
        g_array(p_seq_num).strt_pos_154 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_154 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_154 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_154 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_154   := l_xer.short_name;
      elsif l_xer.seq_num = 155 then
        g_array(p_seq_num).strt_pos_155 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_155 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_155 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_155 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_155   := l_xer.short_name;
      elsif l_xer.seq_num = 156 then
        g_array(p_seq_num).strt_pos_156 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_156 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_156 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_156 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_156   := l_xer.short_name;
      elsif l_xer.seq_num = 157 then
        g_array(p_seq_num).strt_pos_157 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_157 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_157 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_157 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_157   := l_xer.short_name;
      elsif l_xer.seq_num = 158 then
        g_array(p_seq_num).strt_pos_158 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_158 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_158 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_158 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_158   := l_xer.short_name;
      elsif l_xer.seq_num = 159 then
        g_array(p_seq_num).strt_pos_159 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_159 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_159 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_159 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_159   := l_xer.short_name;
      elsif l_xer.seq_num = 160 then
        g_array(p_seq_num).strt_pos_160 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_160 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_160 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_160 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_160   := l_xer.short_name;
      elsif l_xer.seq_num = 161 then
        g_array(p_seq_num).strt_pos_161 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_161 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_161 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_161 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_161   := l_xer.short_name;
      elsif l_xer.seq_num = 162 then
        g_array(p_seq_num).strt_pos_162 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_162 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_162 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_162 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_162   := l_xer.short_name;
      elsif l_xer.seq_num = 163 then
        g_array(p_seq_num).strt_pos_163 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_163 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_163 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_163 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_163   := l_xer.short_name;
      elsif l_xer.seq_num = 164 then
        g_array(p_seq_num).strt_pos_164 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_164 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_164 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_164 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_164   := l_xer.short_name;
      elsif l_xer.seq_num = 165 then
        g_array(p_seq_num).strt_pos_165 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_165 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_165 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_165 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_165   := l_xer.short_name;
      elsif l_xer.seq_num = 166 then
        g_array(p_seq_num).strt_pos_166 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_166 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_166 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_166 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_166   := l_xer.short_name;
      elsif l_xer.seq_num = 167 then
        g_array(p_seq_num).strt_pos_167 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_167 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_167 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_167 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_167   := l_xer.short_name;
      elsif l_xer.seq_num = 168 then
        g_array(p_seq_num).strt_pos_168 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_168 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_168 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_168 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_168   := l_xer.short_name;
      elsif l_xer.seq_num = 169 then
        g_array(p_seq_num).strt_pos_169 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_169 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_169 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_169 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_169   := l_xer.short_name;
      elsif l_xer.seq_num = 170 then
        g_array(p_seq_num).strt_pos_170 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_170 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_170 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_170 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_170   := l_xer.short_name;
      elsif l_xer.seq_num = 171 then
        g_array(p_seq_num).strt_pos_171 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_171 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_171 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_171 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_171   := l_xer.short_name;
      elsif l_xer.seq_num = 172 then
        g_array(p_seq_num).strt_pos_172 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_172 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_172 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_172 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_172   := l_xer.short_name;
      elsif l_xer.seq_num = 173 then
        g_array(p_seq_num).strt_pos_173 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_173 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_173 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_173 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_173   := l_xer.short_name;
      elsif l_xer.seq_num = 174 then
        g_array(p_seq_num).strt_pos_174 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_174 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_174 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_174 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_174   := l_xer.short_name;
      elsif l_xer.seq_num = 175 then
        g_array(p_seq_num).strt_pos_175 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_175 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_175 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_175 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_175   := l_xer.short_name;
            elsif l_xer.seq_num = 176 then
        g_array(p_seq_num).strt_pos_176 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_176 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_176 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_176 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_176   := l_xer.short_name;
      elsif l_xer.seq_num = 177 then
        g_array(p_seq_num).strt_pos_177 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_177 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_177 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_177 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_177   := l_xer.short_name;
      elsif l_xer.seq_num = 178 then
        g_array(p_seq_num).strt_pos_178 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_178 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_178 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_178 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_178   := l_xer.short_name;
      elsif l_xer.seq_num = 179 then
        g_array(p_seq_num).strt_pos_179 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_179 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_179 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_179 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_179   := l_xer.short_name;
      elsif l_xer.seq_num = 180 then
        g_array(p_seq_num).strt_pos_180 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_180 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_180 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_180 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_180   := l_xer.short_name;
      elsif l_xer.seq_num = 181 then
        g_array(p_seq_num).strt_pos_181 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_181 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_181 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_181 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_181   := l_xer.short_name;
      elsif l_xer.seq_num = 182 then
        g_array(p_seq_num).strt_pos_182 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_182 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_182 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_182 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_182   := l_xer.short_name;
      elsif l_xer.seq_num = 183 then
        g_array(p_seq_num).strt_pos_183 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_183 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_183 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_183 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_183   := l_xer.short_name;
      elsif l_xer.seq_num = 184 then
        g_array(p_seq_num).strt_pos_184 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_184 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_184 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_184 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_184   := l_xer.short_name;
      elsif l_xer.seq_num = 185 then
        g_array(p_seq_num).strt_pos_185 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_185 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_185 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_185 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_185   := l_xer.short_name;
      elsif l_xer.seq_num = 186 then
        g_array(p_seq_num).strt_pos_186 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_186 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_186 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_186 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_186   := l_xer.short_name;
      elsif l_xer.seq_num = 187 then
        g_array(p_seq_num).strt_pos_187 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_187 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_187 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_187 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_187   := l_xer.short_name;
      elsif l_xer.seq_num = 188 then
        g_array(p_seq_num).strt_pos_188 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_188 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_188 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_188 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_188   := l_xer.short_name;
      elsif l_xer.seq_num = 189 then
        g_array(p_seq_num).strt_pos_189 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_189 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_189 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_189 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_189   := l_xer.short_name;
      elsif l_xer.seq_num = 190 then
        g_array(p_seq_num).strt_pos_190 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_190 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_190 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_190 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_190   := l_xer.short_name;
      elsif l_xer.seq_num = 191 then
        g_array(p_seq_num).strt_pos_191 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_191 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_191 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_191 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_191   := l_xer.short_name;
      elsif l_xer.seq_num = 192 then
        g_array(p_seq_num).strt_pos_192 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_192 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_192 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_192 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_192   := l_xer.short_name;
      elsif l_xer.seq_num = 193 then
        g_array(p_seq_num).strt_pos_193 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_193 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_193 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_193 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_193   := l_xer.short_name;
      elsif l_xer.seq_num = 194 then
        g_array(p_seq_num).strt_pos_194 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_194 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_194 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_194 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_194   := l_xer.short_name;
      elsif l_xer.seq_num = 195 then
        g_array(p_seq_num).strt_pos_195 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_195 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_195 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_195 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_195   := l_xer.short_name;
            elsif l_xer.seq_num = 196 then
        g_array(p_seq_num).strt_pos_196 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_196 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_196 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_196 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_196   := l_xer.short_name;
      elsif l_xer.seq_num = 197 then
        g_array(p_seq_num).strt_pos_197 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_197 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_197 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_197 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_197   := l_xer.short_name;
      elsif l_xer.seq_num = 198 then
        g_array(p_seq_num).strt_pos_198 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_198 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_198 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_198 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_198   := l_xer.short_name;
      elsif l_xer.seq_num = 199 then
        g_array(p_seq_num).strt_pos_199 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_199 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_199 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_199 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_199   := l_xer.short_name;
      elsif l_xer.seq_num = 200 then
        g_array(p_seq_num).strt_pos_200 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_200 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_200 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_200 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_200   := l_xer.short_name;
     elsif l_xer.seq_num = 201 then
        g_array(p_seq_num).strt_pos_201  := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_201 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_201   := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_201 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_201:= l_xer.short_name;
     elsif l_xer.seq_num = 202 then
        g_array(p_seq_num).strt_pos_202 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_202 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_202 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_202 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_202   := l_xer.short_name;
     elsif l_xer.seq_num = 203 then
        g_array(p_seq_num).strt_pos_203 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_203 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_203 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_203 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_203   := l_xer.short_name;
     elsif l_xer.seq_num = 204 then
        g_array(p_seq_num).strt_pos_204 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_204 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_204 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_204 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_204   := l_xer.short_name;
      elsif l_xer.seq_num = 205 then
        g_array(p_seq_num).strt_pos_205 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_205 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_205 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_205 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_205   := l_xer.short_name;
      elsif l_xer.seq_num = 206 then
        g_array(p_seq_num).strt_pos_206 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_206 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_206 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_206 := l_xer.hide_flag;
      elsif l_xer.seq_num = 207 then
        g_array(p_seq_num).strt_pos_207 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_207 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_207 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_207 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_207   := l_xer.short_name;
      elsif l_xer.seq_num = 208 then
        g_array(p_seq_num).strt_pos_208 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_208 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_208 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_208 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_208   := l_xer.short_name;
      elsif l_xer.seq_num = 209 then
        g_array(p_seq_num).strt_pos_209 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_209 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_209 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_209 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_209   := l_xer.short_name;
      elsif l_xer.seq_num = 210 then
        g_array(p_seq_num).strt_pos_210 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_210 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_210 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_210 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_210   := l_xer.short_name;
      elsif l_xer.seq_num = 211 then
        g_array(p_seq_num).strt_pos_211 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_211 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_211 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_211 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_211   := l_xer.short_name;
      elsif l_xer.seq_num = 212 then
        g_array(p_seq_num).strt_pos_212 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_212 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_212 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_212 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_212   := l_xer.short_name;
      elsif l_xer.seq_num = 213 then
        g_array(p_seq_num).strt_pos_213 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_213 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_213 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_213 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_213   := l_xer.short_name;
      elsif l_xer.seq_num = 214 then
        g_array(p_seq_num).strt_pos_214 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_214 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_214 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_214 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_214   := l_xer.short_name;
      elsif l_xer.seq_num = 215 then
        g_array(p_seq_num).strt_pos_215 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_215 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_215 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_215 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_215   := l_xer.short_name;
      elsif l_xer.seq_num = 216 then
        g_array(p_seq_num).strt_pos_216 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_216 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_216 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_216 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_216   := l_xer.short_name;
      elsif l_xer.seq_num = 217 then
        g_array(p_seq_num).strt_pos_217 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_217 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_217 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_217 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_217   := l_xer.short_name;
      elsif l_xer.seq_num = 218 then
        g_array(p_seq_num).strt_pos_218  := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_218 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_218   := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_218 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_218:= l_xer.short_name;
      elsif l_xer.seq_num = 219 then
        g_array(p_seq_num).strt_pos_219 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_219 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_219 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_219 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_219   := l_xer.short_name;
      elsif l_xer.seq_num = 220 then
        g_array(p_seq_num).strt_pos_220 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_220 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_220 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_220 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_220   := l_xer.short_name;
      elsif l_xer.seq_num = 221 then
        g_array(p_seq_num).strt_pos_221 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_221 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_221 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_221 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_221   := l_xer.short_name;
      elsif l_xer.seq_num = 222 then
        g_array(p_seq_num).strt_pos_222 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_222 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_222 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_222 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_222   := l_xer.short_name;
      elsif l_xer.seq_num = 223 then
        g_array(p_seq_num).strt_pos_223 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_223 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_223 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_223 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_223   := l_xer.short_name;
      elsif l_xer.seq_num = 224 then
        g_array(p_seq_num).strt_pos_224 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_224 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_224 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_224 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_224   := l_xer.short_name;
      elsif l_xer.seq_num = 225 then
        g_array(p_seq_num).strt_pos_225 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_225 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_225 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_225 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_225   := l_xer.short_name;
      elsif l_xer.seq_num = 226 then
        g_array(p_seq_num).strt_pos_226 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_226 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_226 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_226 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_226   := l_xer.short_name;
      elsif l_xer.seq_num = 227 then
        g_array(p_seq_num).strt_pos_227 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_227 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_227 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_227 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_227   := l_xer.short_name;
      elsif l_xer.seq_num = 228 then
        g_array(p_seq_num).strt_pos_228 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_228 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_228 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_228 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_228   := l_xer.short_name;
      elsif l_xer.seq_num = 229 then
        g_array(p_seq_num).strt_pos_229 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_229 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_229 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_229 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_229   := l_xer.short_name;
      elsif l_xer.seq_num = 230 then
        g_array(p_seq_num).strt_pos_230 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_230 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_230 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_230 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_230   := l_xer.short_name;
      elsif l_xer.seq_num = 231 then
        g_array(p_seq_num).strt_pos_231 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_231 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_231 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_231 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_231   := l_xer.short_name;
      elsif l_xer.seq_num = 232 then
        g_array(p_seq_num).strt_pos_232 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_232 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_232 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_232 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_232   := l_xer.short_name;
      elsif l_xer.seq_num = 233 then
        g_array(p_seq_num).strt_pos_233 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_233 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_233 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_233 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_233   := l_xer.short_name;
      elsif l_xer.seq_num = 234 then
        g_array(p_seq_num).strt_pos_234 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_234 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_234 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_234 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_234   := l_xer.short_name;
      elsif l_xer.seq_num = 235 then
        g_array(p_seq_num).strt_pos_235 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_235 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_235 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_235 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_235   := l_xer.short_name;
      elsif l_xer.seq_num = 236 then
        g_array(p_seq_num).strt_pos_236 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_236 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_236 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_236 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_236   := l_xer.short_name;
      elsif l_xer.seq_num = 237 then
        g_array(p_seq_num).strt_pos_237 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_237 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_237 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_237 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_237   := l_xer.short_name;
      elsif l_xer.seq_num = 238 then
        g_array(p_seq_num).strt_pos_238 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_238 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_238 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_238 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_238   := l_xer.short_name;
      elsif l_xer.seq_num = 239 then
        g_array(p_seq_num).strt_pos_239 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_239 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_239 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_239 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_239   := l_xer.short_name;
      elsif l_xer.seq_num = 240 then
        g_array(p_seq_num).strt_pos_240 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_240 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_240 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_240 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_240   := l_xer.short_name;
      elsif l_xer.seq_num = 241 then
        g_array(p_seq_num).strt_pos_241 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_241 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_241 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_241 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_241   := l_xer.short_name;
      elsif l_xer.seq_num = 242 then
        g_array(p_seq_num).strt_pos_242 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_242 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_242 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_242 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_242   := l_xer.short_name;
      elsif l_xer.seq_num = 243 then
        g_array(p_seq_num).strt_pos_243 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_243 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_243 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_243 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_243   := l_xer.short_name;
      elsif l_xer.seq_num = 244 then
        g_array(p_seq_num).strt_pos_244 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_244 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_244 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_244 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_244   := l_xer.short_name;
      elsif l_xer.seq_num = 245 then
        g_array(p_seq_num).strt_pos_245 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_245 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_245 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_245 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_245   := l_xer.short_name;
      elsif l_xer.seq_num = 246 then
        g_array(p_seq_num).strt_pos_246 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_246 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_246 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_246 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_246   := l_xer.short_name;
      elsif l_xer.seq_num = 247 then
        g_array(p_seq_num).strt_pos_247 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_247 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_247 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_247 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_247   := l_xer.short_name;
      elsif l_xer.seq_num = 248 then
        g_array(p_seq_num).strt_pos_248 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_248 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_248 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_248 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_248   := l_xer.short_name;
      elsif l_xer.seq_num = 249 then
        g_array(p_seq_num).strt_pos_249 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_249 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_249 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_249 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_249   := l_xer.short_name;
      elsif l_xer.seq_num = 250 then
        g_array(p_seq_num).strt_pos_250 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_250 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_250 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_250 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_250   := l_xer.short_name;
      elsif l_xer.seq_num = 251 then
        g_array(p_seq_num).strt_pos_251 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_251 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_251 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_251 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_251   := l_xer.short_name;
      elsif l_xer.seq_num = 252 then
        g_array(p_seq_num).strt_pos_252 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_252 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_252 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_252 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_252   := l_xer.short_name;
      elsif l_xer.seq_num = 253 then
        g_array(p_seq_num).strt_pos_253 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_253 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_253 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_253 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_253   := l_xer.short_name;
      elsif l_xer.seq_num = 254 then
        g_array(p_seq_num).strt_pos_254 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_254 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_254 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_254 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_254   := l_xer.short_name;
      elsif l_xer.seq_num = 255 then
        g_array(p_seq_num).strt_pos_255 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_255 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_255 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_255 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_255   := l_xer.short_name;
      elsif l_xer.seq_num = 256 then
        g_array(p_seq_num).strt_pos_256 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_256 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_256 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_256 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_256   := l_xer.short_name;
      elsif l_xer.seq_num = 257 then
        g_array(p_seq_num).strt_pos_257 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_257 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_257 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_257 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_257   := l_xer.short_name;
      elsif l_xer.seq_num = 258 then
        g_array(p_seq_num).strt_pos_258 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_258 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_258 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_258 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_258   := l_xer.short_name;
      elsif l_xer.seq_num = 259 then
        g_array(p_seq_num).strt_pos_259 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_259 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_259 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_259 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_259   := l_xer.short_name;
      elsif l_xer.seq_num = 260 then
        g_array(p_seq_num).strt_pos_260 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_260 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_260 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_260 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_260   := l_xer.short_name;
      elsif l_xer.seq_num = 261 then
        g_array(p_seq_num).strt_pos_261 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_261 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_261 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_261 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_261   := l_xer.short_name;
      elsif l_xer.seq_num = 262 then
        g_array(p_seq_num).strt_pos_262 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_262 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_262 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_262 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_262   := l_xer.short_name;
      elsif l_xer.seq_num = 263 then
        g_array(p_seq_num).strt_pos_263 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_263 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_263 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_263 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_263   := l_xer.short_name;
      elsif l_xer.seq_num = 264 then
        g_array(p_seq_num).strt_pos_264 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_264 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_264 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_264 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_264   := l_xer.short_name;
      elsif l_xer.seq_num = 265 then
        g_array(p_seq_num).strt_pos_265 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_265 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_265 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_265 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_265   := l_xer.short_name;
      elsif l_xer.seq_num = 266 then
        g_array(p_seq_num).strt_pos_266 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_266 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_266 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_266 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_266   := l_xer.short_name;
      elsif l_xer.seq_num = 267 then
        g_array(p_seq_num).strt_pos_267 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_267 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_267 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_267 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_267   := l_xer.short_name;
      elsif l_xer.seq_num = 268 then
        g_array(p_seq_num).strt_pos_268 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_268 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_268 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_268 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_268   := l_xer.short_name;
      elsif l_xer.seq_num = 269 then
        g_array(p_seq_num).strt_pos_269 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_269 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_269 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_269 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_269   := l_xer.short_name;
      elsif l_xer.seq_num = 270 then
        g_array(p_seq_num).strt_pos_270 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_270 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_270 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_270 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_270   := l_xer.short_name;
      elsif l_xer.seq_num = 271 then
        g_array(p_seq_num).strt_pos_271 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_271 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_271 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_271 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_271   := l_xer.short_name;
      elsif l_xer.seq_num = 272 then
        g_array(p_seq_num).strt_pos_272 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_272 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_272 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_272 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_272   := l_xer.short_name;
      elsif l_xer.seq_num = 273 then
        g_array(p_seq_num).strt_pos_273 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_273 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_273 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_273 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_273   := l_xer.short_name;
      elsif l_xer.seq_num = 274 then
        g_array(p_seq_num).strt_pos_274 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_274 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_274 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_274 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_274   := l_xer.short_name;
      elsif l_xer.seq_num = 275 then
        g_array(p_seq_num).strt_pos_275 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_275 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_275 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_275 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_275   := l_xer.short_name;
            elsif l_xer.seq_num = 276 then
        g_array(p_seq_num).strt_pos_276 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_276 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_276 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_276 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_276   := l_xer.short_name;
      elsif l_xer.seq_num = 277 then
        g_array(p_seq_num).strt_pos_277 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_277 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_277 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_277 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_277   := l_xer.short_name;
      elsif l_xer.seq_num = 278 then
        g_array(p_seq_num).strt_pos_278 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_278 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_278 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_278 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_278   := l_xer.short_name;
      elsif l_xer.seq_num = 279 then
        g_array(p_seq_num).strt_pos_279 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_279 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_279 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_279 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_279   := l_xer.short_name;
      elsif l_xer.seq_num = 280 then
        g_array(p_seq_num).strt_pos_280 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_280 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_280 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_280 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_280   := l_xer.short_name;
      elsif l_xer.seq_num = 281 then
        g_array(p_seq_num).strt_pos_281 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_281 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_281 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_281 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_281   := l_xer.short_name;
      elsif l_xer.seq_num = 282 then
        g_array(p_seq_num).strt_pos_282 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_282 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_282 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_282 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_282   := l_xer.short_name;
      elsif l_xer.seq_num = 283 then
        g_array(p_seq_num).strt_pos_283 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_283 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_283 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_283 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_283   := l_xer.short_name;
      elsif l_xer.seq_num = 284 then
        g_array(p_seq_num).strt_pos_284 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_284 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_284 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_284 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_284   := l_xer.short_name;
      elsif l_xer.seq_num = 285 then
        g_array(p_seq_num).strt_pos_285 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_285 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_285 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_285 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_285   := l_xer.short_name;
      elsif l_xer.seq_num = 286 then
        g_array(p_seq_num).strt_pos_286 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_286 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_286 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_286 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_286   := l_xer.short_name;
      elsif l_xer.seq_num = 287 then
        g_array(p_seq_num).strt_pos_287 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_287 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_287 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_287 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_287   := l_xer.short_name;
      elsif l_xer.seq_num = 288 then
        g_array(p_seq_num).strt_pos_288 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_288 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_288 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_288 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_288   := l_xer.short_name;
      elsif l_xer.seq_num = 289 then
        g_array(p_seq_num).strt_pos_289 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_289 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_289 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_289 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_289   := l_xer.short_name;
      elsif l_xer.seq_num = 290 then
        g_array(p_seq_num).strt_pos_290 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_290 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_290 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_290 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_290   := l_xer.short_name;
      elsif l_xer.seq_num = 291 then
        g_array(p_seq_num).strt_pos_291 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_291 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_291 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_291 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_291   := l_xer.short_name;
      elsif l_xer.seq_num = 292 then
        g_array(p_seq_num).strt_pos_292 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_292 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_292 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_292 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_292   := l_xer.short_name;
      elsif l_xer.seq_num = 293 then
        g_array(p_seq_num).strt_pos_293 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_293 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_293 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_293 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_293   := l_xer.short_name;
      elsif l_xer.seq_num = 294 then
        g_array(p_seq_num).strt_pos_294 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_294 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_294 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_294 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_294   := l_xer.short_name;
      elsif l_xer.seq_num = 295 then
        g_array(p_seq_num).strt_pos_295 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_295 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_295 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_295 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_295   := l_xer.short_name;
            elsif l_xer.seq_num = 296 then
        g_array(p_seq_num).strt_pos_296 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_296 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_296 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_296 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_296   := l_xer.short_name;
      elsif l_xer.seq_num = 297 then
        g_array(p_seq_num).strt_pos_297 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_297 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_297 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_297 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_297   := l_xer.short_name;
      elsif l_xer.seq_num = 298 then
        g_array(p_seq_num).strt_pos_298 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_298 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_298 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_298 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_298   := l_xer.short_name;
      elsif l_xer.seq_num = 299 then
        g_array(p_seq_num).strt_pos_299 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_299 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_299 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_299 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_299   := l_xer.short_name;
      elsif l_xer.seq_num = 300 then
        g_array(p_seq_num).strt_pos_300 := l_xer.strt_pos;
        g_array(p_seq_num).dlmtr_val_300 := l_xer.dlmtr_val;
        g_array(p_seq_num).just_cd_300 := l_xer.just_cd;
        g_array(p_seq_num).hide_flag_300 := l_xer.hide_flag;
        g_array(p_seq_num).short_name_300   := l_xer.short_name;

     end if;
     --
     g_array(p_seq_num).highest_seq_num := l_xer.seq_num;
      --
   end loop;
--
  hr_utility.set_location('Exiting'||l_proc, 15);
--
end load_strt_pos;
-----------------------------------------------------------------------------
procedure load_arrays
    (p_ext_rcd_id in number,
     p_val_01 in varchar2,
     p_val_02 in varchar2,
     p_val_03 in varchar2,
     p_val_04 in varchar2,
     p_val_05 in varchar2,
     p_val_06 in varchar2,
     p_val_07 in varchar2,
     p_val_08 in varchar2,
     p_val_09 in varchar2,
     p_val_10 in varchar2,
     p_val_11 in varchar2,
     p_val_12 in varchar2,
     p_val_13 in varchar2,
     p_val_14 in varchar2,
     p_val_15 in varchar2,
     p_val_16 in varchar2,
     p_val_17 in varchar2,
     p_val_18 in varchar2,
     p_val_19 in varchar2,
     p_val_20 in varchar2,
     p_val_21 in varchar2,
     p_val_22 in varchar2,
     p_val_23 in varchar2,
     p_val_24 in varchar2,
     p_val_25 in varchar2,
     p_val_26 in varchar2,
     p_val_27 in varchar2,
     p_val_28 in varchar2,
     p_val_29 in varchar2,
     p_val_30 in varchar2,
     p_val_31 in varchar2,
     p_val_32 in varchar2,
     p_val_33 in varchar2,
     p_val_34 in varchar2,
     p_val_35 in varchar2,
     p_val_36 in varchar2,
     p_val_37 in varchar2,
     p_val_38 in varchar2,
     p_val_39 in varchar2,
     p_val_40 in varchar2,
     p_val_41 in varchar2,
     p_val_42 in varchar2,
     p_val_43 in varchar2,
     p_val_44 in varchar2,
     p_val_45 in varchar2,
     p_val_46 in varchar2,
     p_val_47 in varchar2,
     p_val_48 in varchar2,
     p_val_49 in varchar2,
     p_val_50 in varchar2,
     p_val_51 in varchar2,
     p_val_52 in varchar2,
     p_val_53 in varchar2,
     p_val_54 in varchar2,
     p_val_55 in varchar2,
     p_val_56 in varchar2,
     p_val_57 in varchar2,
     p_val_58 in varchar2,
     p_val_59 in varchar2,
     p_val_60 in varchar2,
     p_val_61 in varchar2,
     p_val_62 in varchar2,
     p_val_63 in varchar2,
     p_val_64 in varchar2,
     p_val_65 in varchar2,
     p_val_66 in varchar2,
     p_val_67 in varchar2,
     p_val_68 in varchar2,
     p_val_69 in varchar2,
     p_val_70 in varchar2,
     p_val_71 in varchar2,
     p_val_72 in varchar2,
     p_val_73 in varchar2,
     p_val_74 in varchar2,
     p_val_75 in varchar2,
     p_val_76 in varchar2,
     p_val_77 in varchar2,
     p_val_78 in varchar2,
     p_val_79 in varchar2,
     p_val_80 in varchar2,
     p_val_81 in varchar2,
     p_val_82 in varchar2,
     p_val_83 in varchar2,
     p_val_84 in varchar2,
     p_val_85 in varchar2,
     p_val_86 in varchar2,
     p_val_87 in varchar2,
     p_val_88 in varchar2,
     p_val_89 in varchar2,
     p_val_90 in varchar2,
     p_val_91 in varchar2,
     p_val_92 in varchar2,
     p_val_93 in varchar2,
     p_val_94 in varchar2,
     p_val_95 in varchar2,
     p_val_96 in varchar2,
     p_val_97 in varchar2,
     p_val_98 in varchar2,
     p_val_99 in varchar2,
     p_val_100 in varchar2,
     p_val_101 in varchar2,
     p_val_102 in varchar2,
     p_val_103 in varchar2,
     p_val_104 in varchar2,
     p_val_105 in varchar2,
     p_val_106 in varchar2,
     p_val_107 in varchar2,
     p_val_108 in varchar2,
     p_val_109 in varchar2,
     p_val_110 in varchar2,
     p_val_111 in varchar2,
     p_val_112 in varchar2,
     p_val_113 in varchar2,
     p_val_114 in varchar2,
     p_val_115 in varchar2,
     p_val_116 in varchar2,
     p_val_117 in varchar2,
     p_val_118 in varchar2,
     p_val_119 in varchar2,
     p_val_120 in varchar2,
     p_val_121 in varchar2,
     p_val_122 in varchar2,
     p_val_123 in varchar2,
     p_val_124 in varchar2,
     p_val_125 in varchar2,
     p_val_126 in varchar2,
     p_val_127 in varchar2,
     p_val_128 in varchar2,
     p_val_129 in varchar2,
     p_val_130 in varchar2,
     p_val_131 in varchar2,
     p_val_132 in varchar2,
     p_val_133 in varchar2,
     p_val_134 in varchar2,
     p_val_135 in varchar2,
     p_val_136 in varchar2,
     p_val_137 in varchar2,
     p_val_138 in varchar2,
     p_val_139 in varchar2,
     p_val_140 in varchar2,
     p_val_141 in varchar2,
     p_val_142 in varchar2,
     p_val_143 in varchar2,
     p_val_144 in varchar2,
     p_val_145 in varchar2,
     p_val_146 in varchar2,
     p_val_147 in varchar2,
     p_val_148 in varchar2,
     p_val_149 in varchar2,
     p_val_150 in varchar2,
     p_val_151 in varchar2,
     p_val_152 in varchar2,
     p_val_153 in varchar2,
     p_val_154 in varchar2,
     p_val_155 in varchar2,
     p_val_156 in varchar2,
     p_val_157 in varchar2,
     p_val_158 in varchar2,
     p_val_159 in varchar2,
     p_val_160 in varchar2,
     p_val_161 in varchar2,
     p_val_162 in varchar2,
     p_val_163 in varchar2,
     p_val_164 in varchar2,
     p_val_165 in varchar2,
     p_val_166 in varchar2,
     p_val_167 in varchar2,
     p_val_168 in varchar2,
     p_val_169 in varchar2,
     p_val_170 in varchar2,
     p_val_171 in varchar2,
     p_val_172 in varchar2,
     p_val_173 in varchar2,
     p_val_174 in varchar2,
     p_val_175 in varchar2,
     p_val_176 in varchar2,
     p_val_177 in varchar2,
     p_val_178 in varchar2,
     p_val_179 in varchar2,
     p_val_180 in varchar2,
     p_val_181 in varchar2,
     p_val_182 in varchar2,
     p_val_183 in varchar2,
     p_val_184 in varchar2,
     p_val_185 in varchar2,
     p_val_186 in varchar2,
     p_val_187 in varchar2,
     p_val_188 in varchar2,
     p_val_189 in varchar2,
     p_val_190 in varchar2,
     p_val_191 in varchar2,
     p_val_192 in varchar2,
     p_val_193 in varchar2,
     p_val_194 in varchar2,
     p_val_195 in varchar2,
     p_val_196 in varchar2,
     p_val_197 in varchar2,
     p_val_198 in varchar2,
     p_val_199 in varchar2,
     p_val_200 in varchar2,
     p_val_201 in varchar2,
     p_val_202 in varchar2,
     p_val_203 in varchar2,
     p_val_204 in varchar2,
     p_val_205 in varchar2,
     p_val_206 in varchar2,
     p_val_207 in varchar2,
     p_val_208 in varchar2,
     p_val_209 in varchar2,
     p_val_210 in varchar2,
     p_val_211 in varchar2,
     p_val_212 in varchar2,
     p_val_213 in varchar2,
     p_val_214 in varchar2,
     p_val_215 in varchar2,
     p_val_216 in varchar2,
     p_val_217 in varchar2,
     p_val_218 in varchar2,
     p_val_219 in varchar2,
     p_val_220 in varchar2,
     p_val_221 in varchar2,
     p_val_222 in varchar2,
     p_val_223 in varchar2,
     p_val_224 in varchar2,
     p_val_225 in varchar2,
     p_val_226 in varchar2,
     p_val_227 in varchar2,
     p_val_228 in varchar2,
     p_val_229 in varchar2,
     p_val_230 in varchar2,
     p_val_231 in varchar2,
     p_val_232 in varchar2,
     p_val_233 in varchar2,
     p_val_234 in varchar2,
     p_val_235 in varchar2,
     p_val_236 in varchar2,
     p_val_237 in varchar2,
     p_val_238 in varchar2,
     p_val_239 in varchar2,
     p_val_240 in varchar2,
     p_val_241 in varchar2,
     p_val_242 in varchar2,
     p_val_243 in varchar2,
     p_val_244 in varchar2,
     p_val_245 in varchar2,
     p_val_246 in varchar2,
     p_val_247 in varchar2,
     p_val_248 in varchar2,
     p_val_249 in varchar2,
     p_val_250 in varchar2,
     p_val_251 in varchar2,
     p_val_252 in varchar2,
     p_val_253 in varchar2,
     p_val_254 in varchar2,
     p_val_255 in varchar2,
     p_val_256 in varchar2,
     p_val_257 in varchar2,
     p_val_258 in varchar2,
     p_val_259 in varchar2,
     p_val_260 in varchar2,
     p_val_261 in varchar2,
     p_val_262 in varchar2,
     p_val_263 in varchar2,
     p_val_264 in varchar2,
     p_val_265 in varchar2,
     p_val_266 in varchar2,
     p_val_267 in varchar2,
     p_val_268 in varchar2,
     p_val_269 in varchar2,
     p_val_270 in varchar2,
     p_val_271 in varchar2,
     p_val_272 in varchar2,
     p_val_273 in varchar2,
     p_val_274 in varchar2,
     p_val_275 in varchar2,
     p_val_276 in varchar2,
     p_val_277 in varchar2,
     p_val_278 in varchar2,
     p_val_279 in varchar2,
     p_val_280 in varchar2,
     p_val_281 in varchar2,
     p_val_282 in varchar2,
     p_val_283 in varchar2,
     p_val_284 in varchar2,
     p_val_285 in varchar2,
     p_val_286 in varchar2,
     p_val_287 in varchar2,
     p_val_288 in varchar2,
     p_val_289 in varchar2,
     p_val_290 in varchar2,
     p_val_291 in varchar2,
     p_val_292 in varchar2,
     p_val_293 in varchar2,
     p_val_294 in varchar2,
     p_val_295 in varchar2,
     p_val_296 in varchar2,
     p_val_297 in varchar2,
     p_val_298 in varchar2,
     p_val_299 in varchar2,
     p_val_300 in varchar2,
     p_seq_num in number) is
--
  l_proc     varchar2(72) := g_package||'load_arrays';
--
begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
 g_val(01) := p_val_01;
 g_val(02) := p_val_02;
 g_val(03) := p_val_03;
 g_val(04) := p_val_04;
 g_val(05) := p_val_05;
 g_val(06) := p_val_06;
 g_val(07) := p_val_07;
 g_val(08) := p_val_08;
 g_val(09) := p_val_09;
 g_val(10) := p_val_10;
 g_val(11) := p_val_11;
 g_val(12) := p_val_12;
 g_val(13) := p_val_13;
 g_val(14) := p_val_14;
 g_val(15) := p_val_15;
 g_val(16) := p_val_16;
 g_val(17) := p_val_17;
 g_val(18) := p_val_18;
 g_val(19) := p_val_19;
 g_val(20) := p_val_20;
 g_val(21) := p_val_21;
 g_val(22) := p_val_22;
 g_val(23) := p_val_23;
 g_val(24) := p_val_24;
 g_val(25) := p_val_25;
 g_val(26) := p_val_26;
 g_val(27) := p_val_27;
 g_val(28) := p_val_28;
 g_val(29) := p_val_29;
 g_val(30) := p_val_30;
 g_val(31) := p_val_31;
 g_val(32) := p_val_32;
 g_val(33) := p_val_33;
 g_val(34) := p_val_34;
 g_val(35) := p_val_35;
 g_val(36) := p_val_36;
 g_val(37) := p_val_37;
 g_val(38) := p_val_38;
 g_val(39) := p_val_39;
 g_val(40) := p_val_40;
 g_val(41) := p_val_41;
 g_val(42) := p_val_42;
 g_val(43) := p_val_43;
 g_val(44) := p_val_44;
 g_val(45) := p_val_45;
 g_val(46) := p_val_46;
 g_val(47) := p_val_47;
 g_val(48) := p_val_48;
 g_val(49) := p_val_49;
 g_val(50) := p_val_50;
 g_val(51) := p_val_51;
 g_val(52) := p_val_52;
 g_val(53) := p_val_53;
 g_val(54) := p_val_54;
 g_val(55) := p_val_55;
 g_val(56) := p_val_56;
 g_val(57) := p_val_57;
 g_val(58) := p_val_58;
 g_val(59) := p_val_59;
 g_val(60) := p_val_60;
 g_val(61) := p_val_61;
 g_val(62) := p_val_62;
 g_val(63) := p_val_63;
 g_val(64) := p_val_64;
 g_val(65) := p_val_65;
 g_val(66) := p_val_66;
 g_val(67) := p_val_67;
 g_val(68) := p_val_68;
 g_val(69) := p_val_69;
 g_val(70) := p_val_70;
 g_val(71) := p_val_71;
 g_val(72) := p_val_72;
 g_val(73) := p_val_73;
 g_val(74) := p_val_74;
 g_val(75) := p_val_75;
 g_val(76) := p_val_76;
 g_val(77) := p_val_77;
 g_val(78) := p_val_78;
 g_val(79) := p_val_79;
 g_val(80) := p_val_80;
 g_val(81) := p_val_81;
 g_val(82) := p_val_82;
 g_val(83) := p_val_83;
 g_val(84) := p_val_84;
 g_val(85) := p_val_85;
 g_val(86) := p_val_86;
 g_val(87) := p_val_87;
 g_val(88) := p_val_88;
 g_val(89) := p_val_89;
 g_val(90) := p_val_90;
 g_val(91) := p_val_91;
 g_val(92) := p_val_92;
 g_val(93) := p_val_93;
 g_val(94) := p_val_94;
 g_val(95) := p_val_95;
 g_val(96) := p_val_96;
 g_val(97) := p_val_97;
 g_val(98) := p_val_98;
 g_val(99) := p_val_99;
 g_val(100) := p_val_100;
 g_val(101) := p_val_101;
 g_val(102) := p_val_102;
 g_val(103) := p_val_103;
 g_val(104) := p_val_104;
 g_val(105) := p_val_105;
 g_val(106) := p_val_106;
 g_val(107) := p_val_107;
 g_val(108) := p_val_108;
 g_val(109) := p_val_109;
 g_val(110) := p_val_110;
 g_val(111) := p_val_111;
 g_val(112) := p_val_112;
 g_val(113) := p_val_113;
 g_val(114) := p_val_114;
 g_val(115) := p_val_115;
 g_val(116) := p_val_116;
 g_val(117) := p_val_117;
 g_val(118) := p_val_118;
 g_val(119) := p_val_119;
 g_val(120) := p_val_120;
 g_val(121) := p_val_121;
 g_val(122) := p_val_122;
 g_val(123) := p_val_123;
 g_val(124) := p_val_124;
 g_val(125) := p_val_125;
 g_val(126) := p_val_126;
 g_val(127) := p_val_127;
 g_val(128) := p_val_128;
 g_val(129) := p_val_129;
 g_val(130) := p_val_130;
 g_val(131) := p_val_131;
 g_val(132) := p_val_132;
 g_val(133) := p_val_133;
 g_val(134) := p_val_134;
 g_val(135) := p_val_135;
 g_val(136) := p_val_136;
 g_val(137) := p_val_137;
 g_val(138) := p_val_138;
 g_val(139) := p_val_139;
 g_val(140) := p_val_140;
 g_val(141) := p_val_141;
 g_val(142) := p_val_142;
 g_val(143) := p_val_143;
 g_val(144) := p_val_144;
 g_val(145) := p_val_145;
 g_val(146) := p_val_146;
 g_val(147) := p_val_147;
 g_val(148) := p_val_148;
 g_val(149) := p_val_149;
 g_val(150) := p_val_150;
 g_val(151) := p_val_151;
 g_val(152) := p_val_152;
 g_val(153) := p_val_153;
 g_val(154) := p_val_154;
 g_val(155) := p_val_155;
 g_val(156) := p_val_156;
 g_val(157) := p_val_157;
 g_val(158) := p_val_158;
 g_val(159) := p_val_159;
 g_val(160) := p_val_160;
 g_val(161) := p_val_161;
 g_val(162) := p_val_162;
 g_val(163) := p_val_163;
 g_val(164) := p_val_164;
 g_val(165) := p_val_165;
 g_val(166) := p_val_166;
 g_val(167) := p_val_167;
 g_val(168) := p_val_168;
 g_val(169) := p_val_169;
 g_val(170) := p_val_170;
 g_val(171) := p_val_171;
 g_val(172) := p_val_172;
 g_val(173) := p_val_173;
 g_val(174) := p_val_174;
 g_val(175) := p_val_175;
 g_val(176) := p_val_176;
 g_val(177) := p_val_177;
 g_val(178) := p_val_178;
 g_val(179) := p_val_179;
 g_val(180) := p_val_180;
 g_val(181) := p_val_181;
 g_val(182) := p_val_182;
 g_val(183) := p_val_183;
 g_val(184) := p_val_184;
 g_val(185) := p_val_185;
 g_val(186) := p_val_186;
 g_val(187) := p_val_187;
 g_val(188) := p_val_188;
 g_val(189) := p_val_189;
 g_val(190) := p_val_190;
 g_val(191) := p_val_191;
 g_val(192) := p_val_192;
 g_val(193) := p_val_193;
 g_val(194) := p_val_194;
 g_val(195) := p_val_195;
 g_val(196) := p_val_196;
 g_val(197) := p_val_197;
 g_val(198) := p_val_198;
 g_val(199) := p_val_199;
 g_val(200) := p_val_200;
 g_val(201) := p_val_201;
 g_val(202) := p_val_202;
 g_val(203) := p_val_203;
 g_val(204) := p_val_204;
 g_val(205) := p_val_205;
 g_val(206) := p_val_206;
 g_val(207) := p_val_207;
 g_val(208) := p_val_208;
 g_val(209) := p_val_209;
 g_val(210) := p_val_210;
 g_val(211) := p_val_211;
 g_val(212) := p_val_212;
 g_val(213) := p_val_213;
 g_val(214) := p_val_214;
 g_val(215) := p_val_215;
 g_val(216) := p_val_216;
 g_val(217) := p_val_217;
 g_val(218) := p_val_218;
 g_val(219) := p_val_219;
 g_val(220) := p_val_220;
 g_val(221) := p_val_221;
 g_val(222) := p_val_222;
 g_val(223) := p_val_223;
 g_val(224) := p_val_224;
 g_val(225) := p_val_225;
 g_val(226) := p_val_226;
 g_val(227) := p_val_227;
 g_val(228) := p_val_228;
 g_val(229) := p_val_229;
 g_val(230) := p_val_230;
 g_val(231) := p_val_231;
 g_val(232) := p_val_232;
 g_val(233) := p_val_233;
 g_val(234) := p_val_234;
 g_val(235) := p_val_235;
 g_val(236) := p_val_236;
 g_val(237) := p_val_237;
 g_val(238) := p_val_238;
 g_val(239) := p_val_239;
 g_val(240) := p_val_240;
 g_val(241) := p_val_241;
 g_val(242) := p_val_242;
 g_val(243) := p_val_243;
 g_val(244) := p_val_244;
 g_val(245) := p_val_245;
 g_val(246) := p_val_246;
 g_val(247) := p_val_247;
 g_val(248) := p_val_248;
 g_val(249) := p_val_249;
 g_val(250) := p_val_250;
 g_val(251) := p_val_251;
 g_val(252) := p_val_252;
 g_val(253) := p_val_253;
 g_val(254) := p_val_254;
 g_val(255) := p_val_255;
 g_val(256) := p_val_256;
 g_val(257) := p_val_257;
 g_val(258) := p_val_258;
 g_val(259) := p_val_259;
 g_val(260) := p_val_260;
 g_val(261) := p_val_261;
 g_val(262) := p_val_262;
 g_val(263) := p_val_263;
 g_val(264) := p_val_264;
 g_val(265) := p_val_265;
 g_val(266) := p_val_266;
 g_val(267) := p_val_267;
 g_val(268) := p_val_268;
 g_val(269) := p_val_269;
 g_val(270) := p_val_270;
 g_val(271) := p_val_271;
 g_val(272) := p_val_272;
 g_val(273) := p_val_273;
 g_val(274) := p_val_274;
 g_val(275) := p_val_275;
 g_val(276) := p_val_276;
 g_val(277) := p_val_277;
 g_val(278) := p_val_278;
 g_val(279) := p_val_279;
 g_val(280) := p_val_280;
 g_val(281) := p_val_281;
 g_val(282) := p_val_282;
 g_val(283) := p_val_283;
 g_val(284) := p_val_284;
 g_val(285) := p_val_285;
 g_val(286) := p_val_286;
 g_val(287) := p_val_287;
 g_val(288) := p_val_288;
 g_val(289) := p_val_289;
 g_val(290) := p_val_290;
 g_val(291) := p_val_291;
 g_val(292) := p_val_292;
 g_val(293) := p_val_293;
 g_val(294) := p_val_294;
 g_val(295) := p_val_295;
 g_val(296) := p_val_296;
 g_val(297) := p_val_297;
 g_val(298) := p_val_298;
 g_val(299) := p_val_299;
 g_val(300) := p_val_300;
--
--test to make sure this is only called once per record
 if not g_array.exists(p_seq_num) then
    load_strt_pos(p_ext_rcd_id,p_seq_num);
 end if;
 --
 --only perform this if we are on a record different from the last record.
  if g_last_rcd_processed is null or g_last_rcd_processed <> p_ext_rcd_id then
    --
    g_strt_pos(01) := g_array(p_seq_num).strt_pos_01;
    g_strt_pos(02) := g_array(p_seq_num).strt_pos_02;
    g_strt_pos(03) := g_array(p_seq_num).strt_pos_03;
    g_strt_pos(04) := g_array(p_seq_num).strt_pos_04;
    g_strt_pos(05) := g_array(p_seq_num).strt_pos_05;
    g_strt_pos(06) := g_array(p_seq_num).strt_pos_06;
    g_strt_pos(07) := g_array(p_seq_num).strt_pos_07;
    g_strt_pos(08) := g_array(p_seq_num).strt_pos_08;
    g_strt_pos(09) := g_array(p_seq_num).strt_pos_09;
    g_strt_pos(10) := g_array(p_seq_num).strt_pos_10;
    g_strt_pos(11) := g_array(p_seq_num).strt_pos_11;
    g_strt_pos(12) := g_array(p_seq_num).strt_pos_12;
    g_strt_pos(13) := g_array(p_seq_num).strt_pos_13;
    g_strt_pos(14) := g_array(p_seq_num).strt_pos_14;
    g_strt_pos(15) := g_array(p_seq_num).strt_pos_15;
    g_strt_pos(16) := g_array(p_seq_num).strt_pos_16;
    g_strt_pos(17) := g_array(p_seq_num).strt_pos_17;
    g_strt_pos(18) := g_array(p_seq_num).strt_pos_18;
    g_strt_pos(19) := g_array(p_seq_num).strt_pos_19;
    g_strt_pos(20) := g_array(p_seq_num).strt_pos_20;
    g_strt_pos(21) := g_array(p_seq_num).strt_pos_21;
    g_strt_pos(22) := g_array(p_seq_num).strt_pos_22;
    g_strt_pos(23) := g_array(p_seq_num).strt_pos_23;
    g_strt_pos(24) := g_array(p_seq_num).strt_pos_24;
    g_strt_pos(25) := g_array(p_seq_num).strt_pos_25;
    g_strt_pos(26) := g_array(p_seq_num).strt_pos_26;
    g_strt_pos(27) := g_array(p_seq_num).strt_pos_27;
    g_strt_pos(28) := g_array(p_seq_num).strt_pos_28;
    g_strt_pos(29) := g_array(p_seq_num).strt_pos_29;
    g_strt_pos(30) := g_array(p_seq_num).strt_pos_30;
    g_strt_pos(31) := g_array(p_seq_num).strt_pos_31;
    g_strt_pos(32) := g_array(p_seq_num).strt_pos_32;
    g_strt_pos(33) := g_array(p_seq_num).strt_pos_33;
    g_strt_pos(34) := g_array(p_seq_num).strt_pos_34;
    g_strt_pos(35) := g_array(p_seq_num).strt_pos_35;
    g_strt_pos(36) := g_array(p_seq_num).strt_pos_36;
    g_strt_pos(37) := g_array(p_seq_num).strt_pos_37;
    g_strt_pos(38) := g_array(p_seq_num).strt_pos_38;
    g_strt_pos(39) := g_array(p_seq_num).strt_pos_39;
    g_strt_pos(40) := g_array(p_seq_num).strt_pos_40;
    g_strt_pos(41) := g_array(p_seq_num).strt_pos_41;
    g_strt_pos(42) := g_array(p_seq_num).strt_pos_42;
    g_strt_pos(43) := g_array(p_seq_num).strt_pos_43;
    g_strt_pos(44) := g_array(p_seq_num).strt_pos_44;
    g_strt_pos(45) := g_array(p_seq_num).strt_pos_45;
    g_strt_pos(46) := g_array(p_seq_num).strt_pos_46;
    g_strt_pos(47) := g_array(p_seq_num).strt_pos_47;
    g_strt_pos(48) := g_array(p_seq_num).strt_pos_48;
    g_strt_pos(49) := g_array(p_seq_num).strt_pos_49;
    g_strt_pos(50) := g_array(p_seq_num).strt_pos_50;
    g_strt_pos(51) := g_array(p_seq_num).strt_pos_51;
    g_strt_pos(52) := g_array(p_seq_num).strt_pos_52;
    g_strt_pos(53) := g_array(p_seq_num).strt_pos_53;
    g_strt_pos(54) := g_array(p_seq_num).strt_pos_54;
    g_strt_pos(55) := g_array(p_seq_num).strt_pos_55;
    g_strt_pos(56) := g_array(p_seq_num).strt_pos_56;
    g_strt_pos(57) := g_array(p_seq_num).strt_pos_57;
    g_strt_pos(58) := g_array(p_seq_num).strt_pos_58;
    g_strt_pos(59) := g_array(p_seq_num).strt_pos_59;
    g_strt_pos(60) := g_array(p_seq_num).strt_pos_60;
    g_strt_pos(61) := g_array(p_seq_num).strt_pos_61;
    g_strt_pos(62) := g_array(p_seq_num).strt_pos_62;
    g_strt_pos(63) := g_array(p_seq_num).strt_pos_63;
    g_strt_pos(64) := g_array(p_seq_num).strt_pos_64;
    g_strt_pos(65) := g_array(p_seq_num).strt_pos_65;
    g_strt_pos(66) := g_array(p_seq_num).strt_pos_66;
    g_strt_pos(67) := g_array(p_seq_num).strt_pos_67;
    g_strt_pos(68) := g_array(p_seq_num).strt_pos_68;
    g_strt_pos(69) := g_array(p_seq_num).strt_pos_69;
    g_strt_pos(70) := g_array(p_seq_num).strt_pos_70;
    g_strt_pos(71) := g_array(p_seq_num).strt_pos_71;
    g_strt_pos(72) := g_array(p_seq_num).strt_pos_72;
    g_strt_pos(73) := g_array(p_seq_num).strt_pos_73;
    g_strt_pos(74) := g_array(p_seq_num).strt_pos_74;
    g_strt_pos(75) := g_array(p_seq_num).strt_pos_75;
    g_strt_pos(76) := g_array(p_seq_num).strt_pos_76;
    g_strt_pos(77) := g_array(p_seq_num).strt_pos_77;
    g_strt_pos(78) := g_array(p_seq_num).strt_pos_78;
    g_strt_pos(79) := g_array(p_seq_num).strt_pos_79;
    g_strt_pos(80) := g_array(p_seq_num).strt_pos_80;
    g_strt_pos(81) := g_array(p_seq_num).strt_pos_81;
    g_strt_pos(82) := g_array(p_seq_num).strt_pos_82;
    g_strt_pos(83) := g_array(p_seq_num).strt_pos_83;
    g_strt_pos(84) := g_array(p_seq_num).strt_pos_84;
    g_strt_pos(85) := g_array(p_seq_num).strt_pos_85;
    g_strt_pos(86) := g_array(p_seq_num).strt_pos_86;
    g_strt_pos(87) := g_array(p_seq_num).strt_pos_87;
    g_strt_pos(88) := g_array(p_seq_num).strt_pos_88;
    g_strt_pos(89) := g_array(p_seq_num).strt_pos_89;
    g_strt_pos(90) := g_array(p_seq_num).strt_pos_90;
    g_strt_pos(91) := g_array(p_seq_num).strt_pos_91;
    g_strt_pos(92) := g_array(p_seq_num).strt_pos_92;
    g_strt_pos(93) := g_array(p_seq_num).strt_pos_93;
    g_strt_pos(94) := g_array(p_seq_num).strt_pos_94;
    g_strt_pos(95) := g_array(p_seq_num).strt_pos_95;
    g_strt_pos(96) := g_array(p_seq_num).strt_pos_96;
    g_strt_pos(97) := g_array(p_seq_num).strt_pos_97;
    g_strt_pos(98) := g_array(p_seq_num).strt_pos_98;
    g_strt_pos(99) := g_array(p_seq_num).strt_pos_99;
    g_strt_pos(100) := g_array(p_seq_num).strt_pos_100;
    g_strt_pos(101) := g_array(p_seq_num).strt_pos_101;
    g_strt_pos(102) := g_array(p_seq_num).strt_pos_102;
    g_strt_pos(103) := g_array(p_seq_num).strt_pos_103;
    g_strt_pos(104) := g_array(p_seq_num).strt_pos_104;
    g_strt_pos(105) := g_array(p_seq_num).strt_pos_105;
    g_strt_pos(106) := g_array(p_seq_num).strt_pos_106;
    g_strt_pos(107) := g_array(p_seq_num).strt_pos_107;
    g_strt_pos(108) := g_array(p_seq_num).strt_pos_108;
    g_strt_pos(109) := g_array(p_seq_num).strt_pos_109;
    g_strt_pos(110) := g_array(p_seq_num).strt_pos_110;
    g_strt_pos(111) := g_array(p_seq_num).strt_pos_111;
    g_strt_pos(112) := g_array(p_seq_num).strt_pos_112;
    g_strt_pos(113) := g_array(p_seq_num).strt_pos_113;
    g_strt_pos(114) := g_array(p_seq_num).strt_pos_114;
    g_strt_pos(115) := g_array(p_seq_num).strt_pos_115;
    g_strt_pos(116) := g_array(p_seq_num).strt_pos_116;
    g_strt_pos(117) := g_array(p_seq_num).strt_pos_117;
    g_strt_pos(118) := g_array(p_seq_num).strt_pos_118;
    g_strt_pos(119) := g_array(p_seq_num).strt_pos_119;
    g_strt_pos(120) := g_array(p_seq_num).strt_pos_120;
    g_strt_pos(121) := g_array(p_seq_num).strt_pos_121;
    g_strt_pos(122) := g_array(p_seq_num).strt_pos_122;
    g_strt_pos(123) := g_array(p_seq_num).strt_pos_123;
    g_strt_pos(124) := g_array(p_seq_num).strt_pos_124;
    g_strt_pos(125) := g_array(p_seq_num).strt_pos_125;
    g_strt_pos(126) := g_array(p_seq_num).strt_pos_126;
    g_strt_pos(127) := g_array(p_seq_num).strt_pos_127;
    g_strt_pos(128) := g_array(p_seq_num).strt_pos_128;
    g_strt_pos(129) := g_array(p_seq_num).strt_pos_129;
    g_strt_pos(130) := g_array(p_seq_num).strt_pos_130;
    g_strt_pos(131) := g_array(p_seq_num).strt_pos_131;
    g_strt_pos(132) := g_array(p_seq_num).strt_pos_132;
    g_strt_pos(133) := g_array(p_seq_num).strt_pos_133;
    g_strt_pos(134) := g_array(p_seq_num).strt_pos_134;
    g_strt_pos(135) := g_array(p_seq_num).strt_pos_135;
    g_strt_pos(136) := g_array(p_seq_num).strt_pos_136;
    g_strt_pos(137) := g_array(p_seq_num).strt_pos_137;
    g_strt_pos(138) := g_array(p_seq_num).strt_pos_138;
    g_strt_pos(139) := g_array(p_seq_num).strt_pos_139;
    g_strt_pos(140) := g_array(p_seq_num).strt_pos_140;
    g_strt_pos(141) := g_array(p_seq_num).strt_pos_141;
    g_strt_pos(142) := g_array(p_seq_num).strt_pos_142;
    g_strt_pos(143) := g_array(p_seq_num).strt_pos_143;
    g_strt_pos(144) := g_array(p_seq_num).strt_pos_144;
    g_strt_pos(145) := g_array(p_seq_num).strt_pos_145;
    g_strt_pos(146) := g_array(p_seq_num).strt_pos_146;
    g_strt_pos(147) := g_array(p_seq_num).strt_pos_147;
    g_strt_pos(148) := g_array(p_seq_num).strt_pos_148;
    g_strt_pos(149) := g_array(p_seq_num).strt_pos_149;
    g_strt_pos(150) := g_array(p_seq_num).strt_pos_150;
    g_strt_pos(151) := g_array(p_seq_num).strt_pos_151;
    g_strt_pos(152) := g_array(p_seq_num).strt_pos_152;
    g_strt_pos(153) := g_array(p_seq_num).strt_pos_153;
    g_strt_pos(154) := g_array(p_seq_num).strt_pos_154;
    g_strt_pos(155) := g_array(p_seq_num).strt_pos_155;
    g_strt_pos(156) := g_array(p_seq_num).strt_pos_156;
    g_strt_pos(157) := g_array(p_seq_num).strt_pos_157;
    g_strt_pos(158) := g_array(p_seq_num).strt_pos_158;
    g_strt_pos(159) := g_array(p_seq_num).strt_pos_159;
    g_strt_pos(160) := g_array(p_seq_num).strt_pos_160;
    g_strt_pos(161) := g_array(p_seq_num).strt_pos_161;
    g_strt_pos(162) := g_array(p_seq_num).strt_pos_162;
    g_strt_pos(163) := g_array(p_seq_num).strt_pos_163;
    g_strt_pos(164) := g_array(p_seq_num).strt_pos_164;
    g_strt_pos(165) := g_array(p_seq_num).strt_pos_165;
    g_strt_pos(166) := g_array(p_seq_num).strt_pos_166;
    g_strt_pos(167) := g_array(p_seq_num).strt_pos_167;
    g_strt_pos(168) := g_array(p_seq_num).strt_pos_168;
    g_strt_pos(169) := g_array(p_seq_num).strt_pos_169;
    g_strt_pos(170) := g_array(p_seq_num).strt_pos_170;
    g_strt_pos(171) := g_array(p_seq_num).strt_pos_171;
    g_strt_pos(172) := g_array(p_seq_num).strt_pos_172;
    g_strt_pos(173) := g_array(p_seq_num).strt_pos_173;
    g_strt_pos(174) := g_array(p_seq_num).strt_pos_174;
    g_strt_pos(175) := g_array(p_seq_num).strt_pos_175;
    g_strt_pos(176) := g_array(p_seq_num).strt_pos_176;
    g_strt_pos(177) := g_array(p_seq_num).strt_pos_177;
    g_strt_pos(178) := g_array(p_seq_num).strt_pos_178;
    g_strt_pos(179) := g_array(p_seq_num).strt_pos_179;
    g_strt_pos(180) := g_array(p_seq_num).strt_pos_180;
    g_strt_pos(181) := g_array(p_seq_num).strt_pos_181;
    g_strt_pos(182) := g_array(p_seq_num).strt_pos_182;
    g_strt_pos(183) := g_array(p_seq_num).strt_pos_183;
    g_strt_pos(184) := g_array(p_seq_num).strt_pos_184;
    g_strt_pos(185) := g_array(p_seq_num).strt_pos_185;
    g_strt_pos(186) := g_array(p_seq_num).strt_pos_186;
    g_strt_pos(187) := g_array(p_seq_num).strt_pos_187;
    g_strt_pos(188) := g_array(p_seq_num).strt_pos_188;
    g_strt_pos(189) := g_array(p_seq_num).strt_pos_189;
    g_strt_pos(190) := g_array(p_seq_num).strt_pos_190;
    g_strt_pos(191) := g_array(p_seq_num).strt_pos_191;
    g_strt_pos(192) := g_array(p_seq_num).strt_pos_192;
    g_strt_pos(193) := g_array(p_seq_num).strt_pos_193;
    g_strt_pos(194) := g_array(p_seq_num).strt_pos_194;
    g_strt_pos(195) := g_array(p_seq_num).strt_pos_195;
    g_strt_pos(196) := g_array(p_seq_num).strt_pos_196;
    g_strt_pos(197) := g_array(p_seq_num).strt_pos_197;
    g_strt_pos(198) := g_array(p_seq_num).strt_pos_198;
    g_strt_pos(199) := g_array(p_seq_num).strt_pos_199;
    g_strt_pos(200) := g_array(p_seq_num).strt_pos_200;
    g_strt_pos(201) := g_array(p_seq_num).strt_pos_201;
    g_strt_pos(202) := g_array(p_seq_num).strt_pos_202;
    g_strt_pos(203) := g_array(p_seq_num).strt_pos_203;
    g_strt_pos(204) := g_array(p_seq_num).strt_pos_204;
    g_strt_pos(205) := g_array(p_seq_num).strt_pos_205;
    g_strt_pos(206) := g_array(p_seq_num).strt_pos_206;
    g_strt_pos(207) := g_array(p_seq_num).strt_pos_207;
    g_strt_pos(208) := g_array(p_seq_num).strt_pos_208;
    g_strt_pos(209) := g_array(p_seq_num).strt_pos_209;
    g_strt_pos(210) := g_array(p_seq_num).strt_pos_210;
    g_strt_pos(211) := g_array(p_seq_num).strt_pos_211;
    g_strt_pos(212) := g_array(p_seq_num).strt_pos_212;
    g_strt_pos(213) := g_array(p_seq_num).strt_pos_213;
    g_strt_pos(214) := g_array(p_seq_num).strt_pos_214;
    g_strt_pos(215) := g_array(p_seq_num).strt_pos_215;
    g_strt_pos(216) := g_array(p_seq_num).strt_pos_216;
    g_strt_pos(217) := g_array(p_seq_num).strt_pos_217;
    g_strt_pos(218) := g_array(p_seq_num).strt_pos_218;
    g_strt_pos(219) := g_array(p_seq_num).strt_pos_219;
    g_strt_pos(220) := g_array(p_seq_num).strt_pos_220;
    g_strt_pos(221) := g_array(p_seq_num).strt_pos_221;
    g_strt_pos(222) := g_array(p_seq_num).strt_pos_222;
    g_strt_pos(223) := g_array(p_seq_num).strt_pos_223;
    g_strt_pos(224) := g_array(p_seq_num).strt_pos_224;
    g_strt_pos(225) := g_array(p_seq_num).strt_pos_225;
    g_strt_pos(226) := g_array(p_seq_num).strt_pos_226;
    g_strt_pos(227) := g_array(p_seq_num).strt_pos_227;
    g_strt_pos(228) := g_array(p_seq_num).strt_pos_228;
    g_strt_pos(229) := g_array(p_seq_num).strt_pos_229;
    g_strt_pos(230) := g_array(p_seq_num).strt_pos_230;
    g_strt_pos(231) := g_array(p_seq_num).strt_pos_231;
    g_strt_pos(232) := g_array(p_seq_num).strt_pos_232;
    g_strt_pos(233) := g_array(p_seq_num).strt_pos_233;
    g_strt_pos(234) := g_array(p_seq_num).strt_pos_234;
    g_strt_pos(235) := g_array(p_seq_num).strt_pos_235;
    g_strt_pos(236) := g_array(p_seq_num).strt_pos_236;
    g_strt_pos(237) := g_array(p_seq_num).strt_pos_237;
    g_strt_pos(238) := g_array(p_seq_num).strt_pos_238;
    g_strt_pos(239) := g_array(p_seq_num).strt_pos_239;
    g_strt_pos(240) := g_array(p_seq_num).strt_pos_240;
    g_strt_pos(241) := g_array(p_seq_num).strt_pos_241;
    g_strt_pos(242) := g_array(p_seq_num).strt_pos_242;
    g_strt_pos(243) := g_array(p_seq_num).strt_pos_243;
    g_strt_pos(244) := g_array(p_seq_num).strt_pos_244;
    g_strt_pos(245) := g_array(p_seq_num).strt_pos_245;
    g_strt_pos(246) := g_array(p_seq_num).strt_pos_246;
    g_strt_pos(247) := g_array(p_seq_num).strt_pos_247;
    g_strt_pos(248) := g_array(p_seq_num).strt_pos_248;
    g_strt_pos(249) := g_array(p_seq_num).strt_pos_249;
    g_strt_pos(250) := g_array(p_seq_num).strt_pos_250;
    g_strt_pos(251) := g_array(p_seq_num).strt_pos_251;
    g_strt_pos(252) := g_array(p_seq_num).strt_pos_252;
    g_strt_pos(253) := g_array(p_seq_num).strt_pos_253;
    g_strt_pos(254) := g_array(p_seq_num).strt_pos_254;
    g_strt_pos(255) := g_array(p_seq_num).strt_pos_255;
    g_strt_pos(256) := g_array(p_seq_num).strt_pos_256;
    g_strt_pos(257) := g_array(p_seq_num).strt_pos_257;
    g_strt_pos(258) := g_array(p_seq_num).strt_pos_258;
    g_strt_pos(259) := g_array(p_seq_num).strt_pos_259;
    g_strt_pos(260) := g_array(p_seq_num).strt_pos_260;
    g_strt_pos(261) := g_array(p_seq_num).strt_pos_261;
    g_strt_pos(262) := g_array(p_seq_num).strt_pos_262;
    g_strt_pos(263) := g_array(p_seq_num).strt_pos_263;
    g_strt_pos(264) := g_array(p_seq_num).strt_pos_264;
    g_strt_pos(265) := g_array(p_seq_num).strt_pos_265;
    g_strt_pos(266) := g_array(p_seq_num).strt_pos_266;
    g_strt_pos(267) := g_array(p_seq_num).strt_pos_267;
    g_strt_pos(268) := g_array(p_seq_num).strt_pos_268;
    g_strt_pos(269) := g_array(p_seq_num).strt_pos_269;
    g_strt_pos(270) := g_array(p_seq_num).strt_pos_270;
    g_strt_pos(271) := g_array(p_seq_num).strt_pos_271;
    g_strt_pos(272) := g_array(p_seq_num).strt_pos_272;
    g_strt_pos(273) := g_array(p_seq_num).strt_pos_273;
    g_strt_pos(274) := g_array(p_seq_num).strt_pos_274;
    g_strt_pos(275) := g_array(p_seq_num).strt_pos_275;
    g_strt_pos(276) := g_array(p_seq_num).strt_pos_276;
    g_strt_pos(277) := g_array(p_seq_num).strt_pos_277;
    g_strt_pos(278) := g_array(p_seq_num).strt_pos_278;
    g_strt_pos(279) := g_array(p_seq_num).strt_pos_279;
    g_strt_pos(280) := g_array(p_seq_num).strt_pos_280;
    g_strt_pos(281) := g_array(p_seq_num).strt_pos_281;
    g_strt_pos(282) := g_array(p_seq_num).strt_pos_282;
    g_strt_pos(283) := g_array(p_seq_num).strt_pos_283;
    g_strt_pos(284) := g_array(p_seq_num).strt_pos_284;
    g_strt_pos(285) := g_array(p_seq_num).strt_pos_285;
    g_strt_pos(286) := g_array(p_seq_num).strt_pos_286;
    g_strt_pos(287) := g_array(p_seq_num).strt_pos_287;
    g_strt_pos(288) := g_array(p_seq_num).strt_pos_288;
    g_strt_pos(289) := g_array(p_seq_num).strt_pos_289;
    g_strt_pos(290) := g_array(p_seq_num).strt_pos_290;
    g_strt_pos(291) := g_array(p_seq_num).strt_pos_291;
    g_strt_pos(292) := g_array(p_seq_num).strt_pos_292;
    g_strt_pos(293) := g_array(p_seq_num).strt_pos_293;
    g_strt_pos(294) := g_array(p_seq_num).strt_pos_294;
    g_strt_pos(295) := g_array(p_seq_num).strt_pos_295;
    g_strt_pos(296) := g_array(p_seq_num).strt_pos_296;
    g_strt_pos(297) := g_array(p_seq_num).strt_pos_297;
    g_strt_pos(298) := g_array(p_seq_num).strt_pos_298;
    g_strt_pos(299) := g_array(p_seq_num).strt_pos_299;
    g_strt_pos(300) := g_array(p_seq_num).strt_pos_300;
    --
    g_dlmtr_val(01) := g_array(p_seq_num).dlmtr_val_01;
    g_dlmtr_val(02) := g_array(p_seq_num).dlmtr_val_02;
    g_dlmtr_val(03) := g_array(p_seq_num).dlmtr_val_03;
    g_dlmtr_val(04) := g_array(p_seq_num).dlmtr_val_04;
    g_dlmtr_val(05) := g_array(p_seq_num).dlmtr_val_05;
    g_dlmtr_val(06) := g_array(p_seq_num).dlmtr_val_06;
    g_dlmtr_val(07) := g_array(p_seq_num).dlmtr_val_07;
    g_dlmtr_val(08) := g_array(p_seq_num).dlmtr_val_08;
    g_dlmtr_val(09) := g_array(p_seq_num).dlmtr_val_09;
    g_dlmtr_val(10) := g_array(p_seq_num).dlmtr_val_10;
    g_dlmtr_val(11) := g_array(p_seq_num).dlmtr_val_11;
    g_dlmtr_val(12) := g_array(p_seq_num).dlmtr_val_12;
    g_dlmtr_val(13) := g_array(p_seq_num).dlmtr_val_13;
    g_dlmtr_val(14) := g_array(p_seq_num).dlmtr_val_14;
    g_dlmtr_val(15) := g_array(p_seq_num).dlmtr_val_15;
    g_dlmtr_val(16) := g_array(p_seq_num).dlmtr_val_16;
    g_dlmtr_val(17) := g_array(p_seq_num).dlmtr_val_17;
    g_dlmtr_val(18) := g_array(p_seq_num).dlmtr_val_18;
    g_dlmtr_val(19) := g_array(p_seq_num).dlmtr_val_19;
    g_dlmtr_val(20) := g_array(p_seq_num).dlmtr_val_20;
    g_dlmtr_val(21) := g_array(p_seq_num).dlmtr_val_21;
    g_dlmtr_val(22) := g_array(p_seq_num).dlmtr_val_22;
    g_dlmtr_val(23) := g_array(p_seq_num).dlmtr_val_23;
    g_dlmtr_val(24) := g_array(p_seq_num).dlmtr_val_24;
    g_dlmtr_val(25) := g_array(p_seq_num).dlmtr_val_25;
    g_dlmtr_val(26) := g_array(p_seq_num).dlmtr_val_26;
    g_dlmtr_val(27) := g_array(p_seq_num).dlmtr_val_27;
    g_dlmtr_val(28) := g_array(p_seq_num).dlmtr_val_28;
    g_dlmtr_val(29) := g_array(p_seq_num).dlmtr_val_29;
    g_dlmtr_val(30) := g_array(p_seq_num).dlmtr_val_30;
    g_dlmtr_val(31) := g_array(p_seq_num).dlmtr_val_31;
    g_dlmtr_val(32) := g_array(p_seq_num).dlmtr_val_32;
    g_dlmtr_val(33) := g_array(p_seq_num).dlmtr_val_33;
    g_dlmtr_val(34) := g_array(p_seq_num).dlmtr_val_34;
    g_dlmtr_val(35) := g_array(p_seq_num).dlmtr_val_35;
    g_dlmtr_val(36) := g_array(p_seq_num).dlmtr_val_36;
    g_dlmtr_val(37) := g_array(p_seq_num).dlmtr_val_37;
    g_dlmtr_val(38) := g_array(p_seq_num).dlmtr_val_38;
    g_dlmtr_val(39) := g_array(p_seq_num).dlmtr_val_39;
    g_dlmtr_val(40) := g_array(p_seq_num).dlmtr_val_40;
    g_dlmtr_val(41) := g_array(p_seq_num).dlmtr_val_41;
    g_dlmtr_val(42) := g_array(p_seq_num).dlmtr_val_42;
    g_dlmtr_val(43) := g_array(p_seq_num).dlmtr_val_43;
    g_dlmtr_val(44) := g_array(p_seq_num).dlmtr_val_44;
    g_dlmtr_val(45) := g_array(p_seq_num).dlmtr_val_45;
    g_dlmtr_val(46) := g_array(p_seq_num).dlmtr_val_46;
    g_dlmtr_val(47) := g_array(p_seq_num).dlmtr_val_47;
    g_dlmtr_val(48) := g_array(p_seq_num).dlmtr_val_48;
    g_dlmtr_val(49) := g_array(p_seq_num).dlmtr_val_49;
    g_dlmtr_val(50) := g_array(p_seq_num).dlmtr_val_50;
    g_dlmtr_val(51) := g_array(p_seq_num).dlmtr_val_51;
    g_dlmtr_val(52) := g_array(p_seq_num).dlmtr_val_52;
    g_dlmtr_val(53) := g_array(p_seq_num).dlmtr_val_53;
    g_dlmtr_val(54) := g_array(p_seq_num).dlmtr_val_54;
    g_dlmtr_val(55) := g_array(p_seq_num).dlmtr_val_55;
    g_dlmtr_val(56) := g_array(p_seq_num).dlmtr_val_56;
    g_dlmtr_val(57) := g_array(p_seq_num).dlmtr_val_57;
    g_dlmtr_val(58) := g_array(p_seq_num).dlmtr_val_58;
    g_dlmtr_val(59) := g_array(p_seq_num).dlmtr_val_59;
    g_dlmtr_val(60) := g_array(p_seq_num).dlmtr_val_60;
    g_dlmtr_val(61) := g_array(p_seq_num).dlmtr_val_61;
    g_dlmtr_val(62) := g_array(p_seq_num).dlmtr_val_62;
    g_dlmtr_val(63) := g_array(p_seq_num).dlmtr_val_63;
    g_dlmtr_val(64) := g_array(p_seq_num).dlmtr_val_64;
    g_dlmtr_val(65) := g_array(p_seq_num).dlmtr_val_65;
    g_dlmtr_val(66) := g_array(p_seq_num).dlmtr_val_66;
    g_dlmtr_val(67) := g_array(p_seq_num).dlmtr_val_67;
    g_dlmtr_val(68) := g_array(p_seq_num).dlmtr_val_68;
    g_dlmtr_val(69) := g_array(p_seq_num).dlmtr_val_69;
    g_dlmtr_val(70) := g_array(p_seq_num).dlmtr_val_70;
    g_dlmtr_val(71) := g_array(p_seq_num).dlmtr_val_71;
    g_dlmtr_val(72) := g_array(p_seq_num).dlmtr_val_72;
    g_dlmtr_val(73) := g_array(p_seq_num).dlmtr_val_73;
    g_dlmtr_val(74) := g_array(p_seq_num).dlmtr_val_74;
    g_dlmtr_val(75) := g_array(p_seq_num).dlmtr_val_75;
    g_dlmtr_val(76) := g_array(p_seq_num).dlmtr_val_76;
    g_dlmtr_val(77) := g_array(p_seq_num).dlmtr_val_77;
    g_dlmtr_val(78) := g_array(p_seq_num).dlmtr_val_78;
    g_dlmtr_val(79) := g_array(p_seq_num).dlmtr_val_79;
    g_dlmtr_val(80) := g_array(p_seq_num).dlmtr_val_80;
    g_dlmtr_val(81) := g_array(p_seq_num).dlmtr_val_81;
    g_dlmtr_val(82) := g_array(p_seq_num).dlmtr_val_82;
    g_dlmtr_val(83) := g_array(p_seq_num).dlmtr_val_83;
    g_dlmtr_val(84) := g_array(p_seq_num).dlmtr_val_84;
    g_dlmtr_val(85) := g_array(p_seq_num).dlmtr_val_85;
    g_dlmtr_val(86) := g_array(p_seq_num).dlmtr_val_86;
    g_dlmtr_val(87) := g_array(p_seq_num).dlmtr_val_87;
    g_dlmtr_val(88) := g_array(p_seq_num).dlmtr_val_88;
    g_dlmtr_val(89) := g_array(p_seq_num).dlmtr_val_89;
    g_dlmtr_val(90) := g_array(p_seq_num).dlmtr_val_90;
    g_dlmtr_val(91) := g_array(p_seq_num).dlmtr_val_91;
    g_dlmtr_val(92) := g_array(p_seq_num).dlmtr_val_92;
    g_dlmtr_val(93) := g_array(p_seq_num).dlmtr_val_93;
    g_dlmtr_val(94) := g_array(p_seq_num).dlmtr_val_94;
    g_dlmtr_val(95) := g_array(p_seq_num).dlmtr_val_95;
    g_dlmtr_val(96) := g_array(p_seq_num).dlmtr_val_96;
    g_dlmtr_val(97) := g_array(p_seq_num).dlmtr_val_97;
    g_dlmtr_val(98) := g_array(p_seq_num).dlmtr_val_98;
    g_dlmtr_val(99) := g_array(p_seq_num).dlmtr_val_99;
    g_dlmtr_val(100) := g_array(p_seq_num).dlmtr_val_100;
    g_dlmtr_val(101) := g_array(p_seq_num).dlmtr_val_101;
    g_dlmtr_val(102) := g_array(p_seq_num).dlmtr_val_102;
    g_dlmtr_val(103) := g_array(p_seq_num).dlmtr_val_103;
    g_dlmtr_val(104) := g_array(p_seq_num).dlmtr_val_104;
    g_dlmtr_val(105) := g_array(p_seq_num).dlmtr_val_105;
    g_dlmtr_val(106) := g_array(p_seq_num).dlmtr_val_106;
    g_dlmtr_val(107) := g_array(p_seq_num).dlmtr_val_107;
    g_dlmtr_val(108) := g_array(p_seq_num).dlmtr_val_108;
    g_dlmtr_val(109) := g_array(p_seq_num).dlmtr_val_109;
    g_dlmtr_val(110) := g_array(p_seq_num).dlmtr_val_110;
    g_dlmtr_val(111) := g_array(p_seq_num).dlmtr_val_111;
    g_dlmtr_val(112) := g_array(p_seq_num).dlmtr_val_112;
    g_dlmtr_val(113) := g_array(p_seq_num).dlmtr_val_113;
    g_dlmtr_val(114) := g_array(p_seq_num).dlmtr_val_114;
    g_dlmtr_val(115) := g_array(p_seq_num).dlmtr_val_115;
    g_dlmtr_val(116) := g_array(p_seq_num).dlmtr_val_116;
    g_dlmtr_val(117) := g_array(p_seq_num).dlmtr_val_117;
    g_dlmtr_val(118) := g_array(p_seq_num).dlmtr_val_118;
    g_dlmtr_val(119) := g_array(p_seq_num).dlmtr_val_119;
    g_dlmtr_val(120) := g_array(p_seq_num).dlmtr_val_120;
    g_dlmtr_val(121) := g_array(p_seq_num).dlmtr_val_121;
    g_dlmtr_val(122) := g_array(p_seq_num).dlmtr_val_122;
    g_dlmtr_val(123) := g_array(p_seq_num).dlmtr_val_123;
    g_dlmtr_val(124) := g_array(p_seq_num).dlmtr_val_124;
    g_dlmtr_val(125) := g_array(p_seq_num).dlmtr_val_125;
    g_dlmtr_val(126) := g_array(p_seq_num).dlmtr_val_126;
    g_dlmtr_val(127) := g_array(p_seq_num).dlmtr_val_127;
    g_dlmtr_val(128) := g_array(p_seq_num).dlmtr_val_128;
    g_dlmtr_val(129) := g_array(p_seq_num).dlmtr_val_129;
    g_dlmtr_val(130) := g_array(p_seq_num).dlmtr_val_130;
    g_dlmtr_val(131) := g_array(p_seq_num).dlmtr_val_131;
    g_dlmtr_val(132) := g_array(p_seq_num).dlmtr_val_132;
    g_dlmtr_val(133) := g_array(p_seq_num).dlmtr_val_133;
    g_dlmtr_val(134) := g_array(p_seq_num).dlmtr_val_134;
    g_dlmtr_val(135) := g_array(p_seq_num).dlmtr_val_135;
    g_dlmtr_val(136) := g_array(p_seq_num).dlmtr_val_136;
    g_dlmtr_val(137) := g_array(p_seq_num).dlmtr_val_137;
    g_dlmtr_val(138) := g_array(p_seq_num).dlmtr_val_138;
    g_dlmtr_val(139) := g_array(p_seq_num).dlmtr_val_139;
    g_dlmtr_val(140) := g_array(p_seq_num).dlmtr_val_140;
    g_dlmtr_val(141) := g_array(p_seq_num).dlmtr_val_141;
    g_dlmtr_val(142) := g_array(p_seq_num).dlmtr_val_142;
    g_dlmtr_val(143) := g_array(p_seq_num).dlmtr_val_143;
    g_dlmtr_val(144) := g_array(p_seq_num).dlmtr_val_144;
    g_dlmtr_val(145) := g_array(p_seq_num).dlmtr_val_145;
    g_dlmtr_val(146) := g_array(p_seq_num).dlmtr_val_146;
    g_dlmtr_val(147) := g_array(p_seq_num).dlmtr_val_147;
    g_dlmtr_val(148) := g_array(p_seq_num).dlmtr_val_148;
    g_dlmtr_val(149) := g_array(p_seq_num).dlmtr_val_149;
    g_dlmtr_val(150) := g_array(p_seq_num).dlmtr_val_150;
    g_dlmtr_val(151) := g_array(p_seq_num).dlmtr_val_151;
    g_dlmtr_val(152) := g_array(p_seq_num).dlmtr_val_152;
    g_dlmtr_val(153) := g_array(p_seq_num).dlmtr_val_153;
    g_dlmtr_val(154) := g_array(p_seq_num).dlmtr_val_154;
    g_dlmtr_val(155) := g_array(p_seq_num).dlmtr_val_155;
    g_dlmtr_val(156) := g_array(p_seq_num).dlmtr_val_156;
    g_dlmtr_val(157) := g_array(p_seq_num).dlmtr_val_157;
    g_dlmtr_val(158) := g_array(p_seq_num).dlmtr_val_158;
    g_dlmtr_val(159) := g_array(p_seq_num).dlmtr_val_159;
    g_dlmtr_val(160) := g_array(p_seq_num).dlmtr_val_160;
    g_dlmtr_val(161) := g_array(p_seq_num).dlmtr_val_161;
    g_dlmtr_val(162) := g_array(p_seq_num).dlmtr_val_162;
    g_dlmtr_val(163) := g_array(p_seq_num).dlmtr_val_163;
    g_dlmtr_val(164) := g_array(p_seq_num).dlmtr_val_164;
    g_dlmtr_val(165) := g_array(p_seq_num).dlmtr_val_165;
    g_dlmtr_val(166) := g_array(p_seq_num).dlmtr_val_166;
    g_dlmtr_val(167) := g_array(p_seq_num).dlmtr_val_167;
    g_dlmtr_val(168) := g_array(p_seq_num).dlmtr_val_168;
    g_dlmtr_val(169) := g_array(p_seq_num).dlmtr_val_169;
    g_dlmtr_val(170) := g_array(p_seq_num).dlmtr_val_170;
    g_dlmtr_val(171) := g_array(p_seq_num).dlmtr_val_171;
    g_dlmtr_val(172) := g_array(p_seq_num).dlmtr_val_172;
    g_dlmtr_val(173) := g_array(p_seq_num).dlmtr_val_173;
    g_dlmtr_val(174) := g_array(p_seq_num).dlmtr_val_174;
    g_dlmtr_val(175) := g_array(p_seq_num).dlmtr_val_175;
    g_dlmtr_val(176) := g_array(p_seq_num).dlmtr_val_176;
    g_dlmtr_val(177) := g_array(p_seq_num).dlmtr_val_177;
    g_dlmtr_val(178) := g_array(p_seq_num).dlmtr_val_178;
    g_dlmtr_val(179) := g_array(p_seq_num).dlmtr_val_179;
    g_dlmtr_val(180) := g_array(p_seq_num).dlmtr_val_180;
    g_dlmtr_val(181) := g_array(p_seq_num).dlmtr_val_181;
    g_dlmtr_val(182) := g_array(p_seq_num).dlmtr_val_182;
    g_dlmtr_val(183) := g_array(p_seq_num).dlmtr_val_183;
    g_dlmtr_val(184) := g_array(p_seq_num).dlmtr_val_184;
    g_dlmtr_val(185) := g_array(p_seq_num).dlmtr_val_185;
    g_dlmtr_val(186) := g_array(p_seq_num).dlmtr_val_186;
    g_dlmtr_val(187) := g_array(p_seq_num).dlmtr_val_187;
    g_dlmtr_val(188) := g_array(p_seq_num).dlmtr_val_188;
    g_dlmtr_val(189) := g_array(p_seq_num).dlmtr_val_189;
    g_dlmtr_val(190) := g_array(p_seq_num).dlmtr_val_190;
    g_dlmtr_val(191) := g_array(p_seq_num).dlmtr_val_191;
    g_dlmtr_val(192) := g_array(p_seq_num).dlmtr_val_192;
    g_dlmtr_val(193) := g_array(p_seq_num).dlmtr_val_193;
    g_dlmtr_val(194) := g_array(p_seq_num).dlmtr_val_194;
    g_dlmtr_val(195) := g_array(p_seq_num).dlmtr_val_195;
    g_dlmtr_val(196) := g_array(p_seq_num).dlmtr_val_196;
    g_dlmtr_val(197) := g_array(p_seq_num).dlmtr_val_197;
    g_dlmtr_val(198) := g_array(p_seq_num).dlmtr_val_198;
    g_dlmtr_val(199) := g_array(p_seq_num).dlmtr_val_199;
    g_dlmtr_val(200) := g_array(p_seq_num).dlmtr_val_200;
    g_dlmtr_val(201) := g_array(p_seq_num).dlmtr_val_201;
    g_dlmtr_val(202) := g_array(p_seq_num).dlmtr_val_202;
    g_dlmtr_val(203) := g_array(p_seq_num).dlmtr_val_203;
    g_dlmtr_val(204) := g_array(p_seq_num).dlmtr_val_204;
    g_dlmtr_val(205) := g_array(p_seq_num).dlmtr_val_205;
    g_dlmtr_val(206) := g_array(p_seq_num).dlmtr_val_206;
    g_dlmtr_val(207) := g_array(p_seq_num).dlmtr_val_207;
    g_dlmtr_val(208) := g_array(p_seq_num).dlmtr_val_208;
    g_dlmtr_val(209) := g_array(p_seq_num).dlmtr_val_209;
    g_dlmtr_val(210) := g_array(p_seq_num).dlmtr_val_210;
    g_dlmtr_val(211) := g_array(p_seq_num).dlmtr_val_211;
    g_dlmtr_val(212) := g_array(p_seq_num).dlmtr_val_212;
    g_dlmtr_val(213) := g_array(p_seq_num).dlmtr_val_213;
    g_dlmtr_val(214) := g_array(p_seq_num).dlmtr_val_214;
    g_dlmtr_val(215) := g_array(p_seq_num).dlmtr_val_215;
    g_dlmtr_val(216) := g_array(p_seq_num).dlmtr_val_216;
    g_dlmtr_val(217) := g_array(p_seq_num).dlmtr_val_217;
    g_dlmtr_val(218) := g_array(p_seq_num).dlmtr_val_218;
    g_dlmtr_val(219) := g_array(p_seq_num).dlmtr_val_219;
    g_dlmtr_val(220) := g_array(p_seq_num).dlmtr_val_220;
    g_dlmtr_val(221) := g_array(p_seq_num).dlmtr_val_221;
    g_dlmtr_val(222) := g_array(p_seq_num).dlmtr_val_222;
    g_dlmtr_val(223) := g_array(p_seq_num).dlmtr_val_223;
    g_dlmtr_val(224) := g_array(p_seq_num).dlmtr_val_224;
    g_dlmtr_val(225) := g_array(p_seq_num).dlmtr_val_225;
    g_dlmtr_val(226) := g_array(p_seq_num).dlmtr_val_226;
    g_dlmtr_val(227) := g_array(p_seq_num).dlmtr_val_227;
    g_dlmtr_val(228) := g_array(p_seq_num).dlmtr_val_228;
    g_dlmtr_val(229) := g_array(p_seq_num).dlmtr_val_229;
    g_dlmtr_val(230) := g_array(p_seq_num).dlmtr_val_230;
    g_dlmtr_val(231) := g_array(p_seq_num).dlmtr_val_231;
    g_dlmtr_val(232) := g_array(p_seq_num).dlmtr_val_232;
    g_dlmtr_val(233) := g_array(p_seq_num).dlmtr_val_233;
    g_dlmtr_val(234) := g_array(p_seq_num).dlmtr_val_234;
    g_dlmtr_val(235) := g_array(p_seq_num).dlmtr_val_235;
    g_dlmtr_val(236) := g_array(p_seq_num).dlmtr_val_236;
    g_dlmtr_val(237) := g_array(p_seq_num).dlmtr_val_237;
    g_dlmtr_val(238) := g_array(p_seq_num).dlmtr_val_238;
    g_dlmtr_val(239) := g_array(p_seq_num).dlmtr_val_239;
    g_dlmtr_val(240) := g_array(p_seq_num).dlmtr_val_240;
    g_dlmtr_val(241) := g_array(p_seq_num).dlmtr_val_241;
    g_dlmtr_val(242) := g_array(p_seq_num).dlmtr_val_242;
    g_dlmtr_val(243) := g_array(p_seq_num).dlmtr_val_243;
    g_dlmtr_val(244) := g_array(p_seq_num).dlmtr_val_244;
    g_dlmtr_val(245) := g_array(p_seq_num).dlmtr_val_245;
    g_dlmtr_val(246) := g_array(p_seq_num).dlmtr_val_246;
    g_dlmtr_val(247) := g_array(p_seq_num).dlmtr_val_247;
    g_dlmtr_val(248) := g_array(p_seq_num).dlmtr_val_248;
    g_dlmtr_val(249) := g_array(p_seq_num).dlmtr_val_249;
    g_dlmtr_val(250) := g_array(p_seq_num).dlmtr_val_250;
    g_dlmtr_val(251) := g_array(p_seq_num).dlmtr_val_251;
    g_dlmtr_val(252) := g_array(p_seq_num).dlmtr_val_252;
    g_dlmtr_val(253) := g_array(p_seq_num).dlmtr_val_253;
    g_dlmtr_val(254) := g_array(p_seq_num).dlmtr_val_254;
    g_dlmtr_val(255) := g_array(p_seq_num).dlmtr_val_255;
    g_dlmtr_val(256) := g_array(p_seq_num).dlmtr_val_256;
    g_dlmtr_val(257) := g_array(p_seq_num).dlmtr_val_257;
    g_dlmtr_val(258) := g_array(p_seq_num).dlmtr_val_258;
    g_dlmtr_val(259) := g_array(p_seq_num).dlmtr_val_259;
    g_dlmtr_val(260) := g_array(p_seq_num).dlmtr_val_260;
    g_dlmtr_val(261) := g_array(p_seq_num).dlmtr_val_261;
    g_dlmtr_val(262) := g_array(p_seq_num).dlmtr_val_262;
    g_dlmtr_val(263) := g_array(p_seq_num).dlmtr_val_263;
    g_dlmtr_val(264) := g_array(p_seq_num).dlmtr_val_264;
    g_dlmtr_val(265) := g_array(p_seq_num).dlmtr_val_265;
    g_dlmtr_val(266) := g_array(p_seq_num).dlmtr_val_266;
    g_dlmtr_val(267) := g_array(p_seq_num).dlmtr_val_267;
    g_dlmtr_val(268) := g_array(p_seq_num).dlmtr_val_268;
    g_dlmtr_val(269) := g_array(p_seq_num).dlmtr_val_269;
    g_dlmtr_val(270) := g_array(p_seq_num).dlmtr_val_270;
    g_dlmtr_val(271) := g_array(p_seq_num).dlmtr_val_271;
    g_dlmtr_val(272) := g_array(p_seq_num).dlmtr_val_272;
    g_dlmtr_val(273) := g_array(p_seq_num).dlmtr_val_273;
    g_dlmtr_val(274) := g_array(p_seq_num).dlmtr_val_274;
    g_dlmtr_val(275) := g_array(p_seq_num).dlmtr_val_275;
    g_dlmtr_val(276) := g_array(p_seq_num).dlmtr_val_276;
    g_dlmtr_val(277) := g_array(p_seq_num).dlmtr_val_277;
    g_dlmtr_val(278) := g_array(p_seq_num).dlmtr_val_278;
    g_dlmtr_val(279) := g_array(p_seq_num).dlmtr_val_279;
    g_dlmtr_val(280) := g_array(p_seq_num).dlmtr_val_280;
    g_dlmtr_val(281) := g_array(p_seq_num).dlmtr_val_281;
    g_dlmtr_val(282) := g_array(p_seq_num).dlmtr_val_282;
    g_dlmtr_val(283) := g_array(p_seq_num).dlmtr_val_283;
    g_dlmtr_val(284) := g_array(p_seq_num).dlmtr_val_284;
    g_dlmtr_val(285) := g_array(p_seq_num).dlmtr_val_285;
    g_dlmtr_val(286) := g_array(p_seq_num).dlmtr_val_286;
    g_dlmtr_val(287) := g_array(p_seq_num).dlmtr_val_287;
    g_dlmtr_val(288) := g_array(p_seq_num).dlmtr_val_288;
    g_dlmtr_val(289) := g_array(p_seq_num).dlmtr_val_289;
    g_dlmtr_val(290) := g_array(p_seq_num).dlmtr_val_290;
    g_dlmtr_val(291) := g_array(p_seq_num).dlmtr_val_291;
    g_dlmtr_val(292) := g_array(p_seq_num).dlmtr_val_292;
    g_dlmtr_val(293) := g_array(p_seq_num).dlmtr_val_293;
    g_dlmtr_val(294) := g_array(p_seq_num).dlmtr_val_294;
    g_dlmtr_val(295) := g_array(p_seq_num).dlmtr_val_295;
    g_dlmtr_val(296) := g_array(p_seq_num).dlmtr_val_296;
    g_dlmtr_val(297) := g_array(p_seq_num).dlmtr_val_297;
    g_dlmtr_val(298) := g_array(p_seq_num).dlmtr_val_298;
    g_dlmtr_val(299) := g_array(p_seq_num).dlmtr_val_299;
    g_dlmtr_val(300) := g_array(p_seq_num).dlmtr_val_300;
    --
    g_just_cd(01) := g_array(p_seq_num).just_cd_01;
    g_just_cd(02) := g_array(p_seq_num).just_cd_02;
    g_just_cd(03) := g_array(p_seq_num).just_cd_03;
    g_just_cd(04) := g_array(p_seq_num).just_cd_04;
    g_just_cd(05) := g_array(p_seq_num).just_cd_05;
    g_just_cd(06) := g_array(p_seq_num).just_cd_06;
    g_just_cd(07) := g_array(p_seq_num).just_cd_07;
    g_just_cd(08) := g_array(p_seq_num).just_cd_08;
    g_just_cd(09) := g_array(p_seq_num).just_cd_09;
    g_just_cd(10) := g_array(p_seq_num).just_cd_10;
    g_just_cd(11) := g_array(p_seq_num).just_cd_11;
    g_just_cd(12) := g_array(p_seq_num).just_cd_12;
    g_just_cd(13) := g_array(p_seq_num).just_cd_13;
    g_just_cd(14) := g_array(p_seq_num).just_cd_14;
    g_just_cd(15) := g_array(p_seq_num).just_cd_15;
    g_just_cd(16) := g_array(p_seq_num).just_cd_16;
    g_just_cd(17) := g_array(p_seq_num).just_cd_17;
    g_just_cd(18) := g_array(p_seq_num).just_cd_18;
    g_just_cd(19) := g_array(p_seq_num).just_cd_19;
    g_just_cd(20) := g_array(p_seq_num).just_cd_20;
    g_just_cd(21) := g_array(p_seq_num).just_cd_21;
    g_just_cd(22) := g_array(p_seq_num).just_cd_22;
    g_just_cd(23) := g_array(p_seq_num).just_cd_23;
    g_just_cd(24) := g_array(p_seq_num).just_cd_24;
    g_just_cd(25) := g_array(p_seq_num).just_cd_25;
    g_just_cd(26) := g_array(p_seq_num).just_cd_26;
    g_just_cd(27) := g_array(p_seq_num).just_cd_27;
    g_just_cd(28) := g_array(p_seq_num).just_cd_28;
    g_just_cd(29) := g_array(p_seq_num).just_cd_29;
    g_just_cd(30) := g_array(p_seq_num).just_cd_30;
    g_just_cd(31) := g_array(p_seq_num).just_cd_31;
    g_just_cd(32) := g_array(p_seq_num).just_cd_32;
    g_just_cd(33) := g_array(p_seq_num).just_cd_33;
    g_just_cd(34) := g_array(p_seq_num).just_cd_34;
    g_just_cd(35) := g_array(p_seq_num).just_cd_35;
    g_just_cd(36) := g_array(p_seq_num).just_cd_36;
    g_just_cd(37) := g_array(p_seq_num).just_cd_37;
    g_just_cd(38) := g_array(p_seq_num).just_cd_38;
    g_just_cd(39) := g_array(p_seq_num).just_cd_39;
    g_just_cd(40) := g_array(p_seq_num).just_cd_40;
    g_just_cd(41) := g_array(p_seq_num).just_cd_41;
    g_just_cd(42) := g_array(p_seq_num).just_cd_42;
    g_just_cd(43) := g_array(p_seq_num).just_cd_43;
    g_just_cd(44) := g_array(p_seq_num).just_cd_44;
    g_just_cd(45) := g_array(p_seq_num).just_cd_45;
    g_just_cd(46) := g_array(p_seq_num).just_cd_46;
    g_just_cd(47) := g_array(p_seq_num).just_cd_47;
    g_just_cd(48) := g_array(p_seq_num).just_cd_48;
    g_just_cd(49) := g_array(p_seq_num).just_cd_49;
    g_just_cd(50) := g_array(p_seq_num).just_cd_50;
    g_just_cd(51) := g_array(p_seq_num).just_cd_51;
    g_just_cd(52) := g_array(p_seq_num).just_cd_52;
    g_just_cd(53) := g_array(p_seq_num).just_cd_53;
    g_just_cd(54) := g_array(p_seq_num).just_cd_54;
    g_just_cd(55) := g_array(p_seq_num).just_cd_55;
    g_just_cd(56) := g_array(p_seq_num).just_cd_56;
    g_just_cd(57) := g_array(p_seq_num).just_cd_57;
    g_just_cd(58) := g_array(p_seq_num).just_cd_58;
    g_just_cd(59) := g_array(p_seq_num).just_cd_59;
    g_just_cd(60) := g_array(p_seq_num).just_cd_60;
    g_just_cd(61) := g_array(p_seq_num).just_cd_61;
    g_just_cd(62) := g_array(p_seq_num).just_cd_62;
    g_just_cd(63) := g_array(p_seq_num).just_cd_63;
    g_just_cd(64) := g_array(p_seq_num).just_cd_64;
    g_just_cd(65) := g_array(p_seq_num).just_cd_65;
    g_just_cd(66) := g_array(p_seq_num).just_cd_66;
    g_just_cd(67) := g_array(p_seq_num).just_cd_67;
    g_just_cd(68) := g_array(p_seq_num).just_cd_68;
    g_just_cd(69) := g_array(p_seq_num).just_cd_69;
    g_just_cd(70) := g_array(p_seq_num).just_cd_70;
    g_just_cd(71) := g_array(p_seq_num).just_cd_71;
    g_just_cd(72) := g_array(p_seq_num).just_cd_72;
    g_just_cd(73) := g_array(p_seq_num).just_cd_73;
    g_just_cd(74) := g_array(p_seq_num).just_cd_74;
    g_just_cd(75) := g_array(p_seq_num).just_cd_75;
    g_just_cd(76) := g_array(p_seq_num).just_cd_76;
    g_just_cd(77) := g_array(p_seq_num).just_cd_77;
    g_just_cd(78) := g_array(p_seq_num).just_cd_78;
    g_just_cd(79) := g_array(p_seq_num).just_cd_79;
    g_just_cd(80) := g_array(p_seq_num).just_cd_80;
    g_just_cd(81) := g_array(p_seq_num).just_cd_81;
    g_just_cd(82) := g_array(p_seq_num).just_cd_82;
    g_just_cd(83) := g_array(p_seq_num).just_cd_83;
    g_just_cd(84) := g_array(p_seq_num).just_cd_84;
    g_just_cd(85) := g_array(p_seq_num).just_cd_85;
    g_just_cd(86) := g_array(p_seq_num).just_cd_86;
    g_just_cd(87) := g_array(p_seq_num).just_cd_87;
    g_just_cd(88) := g_array(p_seq_num).just_cd_88;
    g_just_cd(89) := g_array(p_seq_num).just_cd_89;
    g_just_cd(90) := g_array(p_seq_num).just_cd_90;
    g_just_cd(91) := g_array(p_seq_num).just_cd_91;
    g_just_cd(92) := g_array(p_seq_num).just_cd_92;
    g_just_cd(93) := g_array(p_seq_num).just_cd_93;
    g_just_cd(94) := g_array(p_seq_num).just_cd_94;
    g_just_cd(95) := g_array(p_seq_num).just_cd_95;
    g_just_cd(96) := g_array(p_seq_num).just_cd_96;
    g_just_cd(97) := g_array(p_seq_num).just_cd_97;
    g_just_cd(98) := g_array(p_seq_num).just_cd_98;
    g_just_cd(99) := g_array(p_seq_num).just_cd_99;
    g_just_cd(100) := g_array(p_seq_num).just_cd_100;
    g_just_cd(101) := g_array(p_seq_num).just_cd_101;
    g_just_cd(102) := g_array(p_seq_num).just_cd_102;
    g_just_cd(103) := g_array(p_seq_num).just_cd_103;
    g_just_cd(104) := g_array(p_seq_num).just_cd_104;
    g_just_cd(105) := g_array(p_seq_num).just_cd_105;
    g_just_cd(106) := g_array(p_seq_num).just_cd_106;
    g_just_cd(107) := g_array(p_seq_num).just_cd_107;
    g_just_cd(108) := g_array(p_seq_num).just_cd_108;
    g_just_cd(109) := g_array(p_seq_num).just_cd_109;
    g_just_cd(110) := g_array(p_seq_num).just_cd_110;
    g_just_cd(111) := g_array(p_seq_num).just_cd_111;
    g_just_cd(112) := g_array(p_seq_num).just_cd_112;
    g_just_cd(113) := g_array(p_seq_num).just_cd_113;
    g_just_cd(114) := g_array(p_seq_num).just_cd_114;
    g_just_cd(115) := g_array(p_seq_num).just_cd_115;
    g_just_cd(116) := g_array(p_seq_num).just_cd_116;
    g_just_cd(117) := g_array(p_seq_num).just_cd_117;
    g_just_cd(118) := g_array(p_seq_num).just_cd_118;
    g_just_cd(119) := g_array(p_seq_num).just_cd_119;
    g_just_cd(120) := g_array(p_seq_num).just_cd_120;
    g_just_cd(121) := g_array(p_seq_num).just_cd_121;
    g_just_cd(122) := g_array(p_seq_num).just_cd_122;
    g_just_cd(123) := g_array(p_seq_num).just_cd_123;
    g_just_cd(124) := g_array(p_seq_num).just_cd_124;
    g_just_cd(125) := g_array(p_seq_num).just_cd_125;
    g_just_cd(126) := g_array(p_seq_num).just_cd_126;
    g_just_cd(127) := g_array(p_seq_num).just_cd_127;
    g_just_cd(128) := g_array(p_seq_num).just_cd_128;
    g_just_cd(129) := g_array(p_seq_num).just_cd_129;
    g_just_cd(130) := g_array(p_seq_num).just_cd_130;
    g_just_cd(131) := g_array(p_seq_num).just_cd_131;
    g_just_cd(132) := g_array(p_seq_num).just_cd_132;
    g_just_cd(133) := g_array(p_seq_num).just_cd_133;
    g_just_cd(134) := g_array(p_seq_num).just_cd_134;
    g_just_cd(135) := g_array(p_seq_num).just_cd_135;
    g_just_cd(136) := g_array(p_seq_num).just_cd_136;
    g_just_cd(137) := g_array(p_seq_num).just_cd_137;
    g_just_cd(138) := g_array(p_seq_num).just_cd_138;
    g_just_cd(139) := g_array(p_seq_num).just_cd_139;
    g_just_cd(140) := g_array(p_seq_num).just_cd_140;
    g_just_cd(141) := g_array(p_seq_num).just_cd_141;
    g_just_cd(142) := g_array(p_seq_num).just_cd_142;
    g_just_cd(143) := g_array(p_seq_num).just_cd_143;
    g_just_cd(144) := g_array(p_seq_num).just_cd_144;
    g_just_cd(145) := g_array(p_seq_num).just_cd_145;
    g_just_cd(146) := g_array(p_seq_num).just_cd_146;
    g_just_cd(147) := g_array(p_seq_num).just_cd_147;
    g_just_cd(148) := g_array(p_seq_num).just_cd_148;
    g_just_cd(149) := g_array(p_seq_num).just_cd_149;
    g_just_cd(150) := g_array(p_seq_num).just_cd_150;
    g_just_cd(151) := g_array(p_seq_num).just_cd_151;
    g_just_cd(152) := g_array(p_seq_num).just_cd_152;
    g_just_cd(153) := g_array(p_seq_num).just_cd_153;
    g_just_cd(154) := g_array(p_seq_num).just_cd_154;
    g_just_cd(155) := g_array(p_seq_num).just_cd_155;
    g_just_cd(156) := g_array(p_seq_num).just_cd_156;
    g_just_cd(157) := g_array(p_seq_num).just_cd_157;
    g_just_cd(158) := g_array(p_seq_num).just_cd_158;
    g_just_cd(159) := g_array(p_seq_num).just_cd_159;
    g_just_cd(160) := g_array(p_seq_num).just_cd_160;
    g_just_cd(161) := g_array(p_seq_num).just_cd_161;
    g_just_cd(162) := g_array(p_seq_num).just_cd_162;
    g_just_cd(163) := g_array(p_seq_num).just_cd_163;
    g_just_cd(164) := g_array(p_seq_num).just_cd_164;
    g_just_cd(165) := g_array(p_seq_num).just_cd_165;
    g_just_cd(166) := g_array(p_seq_num).just_cd_166;
    g_just_cd(167) := g_array(p_seq_num).just_cd_167;
    g_just_cd(168) := g_array(p_seq_num).just_cd_168;
    g_just_cd(169) := g_array(p_seq_num).just_cd_169;
    g_just_cd(170) := g_array(p_seq_num).just_cd_170;
    g_just_cd(171) := g_array(p_seq_num).just_cd_171;
    g_just_cd(172) := g_array(p_seq_num).just_cd_172;
    g_just_cd(173) := g_array(p_seq_num).just_cd_173;
    g_just_cd(174) := g_array(p_seq_num).just_cd_174;
    g_just_cd(175) := g_array(p_seq_num).just_cd_175;
    g_just_cd(176) := g_array(p_seq_num).just_cd_176;
    g_just_cd(177) := g_array(p_seq_num).just_cd_177;
    g_just_cd(178) := g_array(p_seq_num).just_cd_178;
    g_just_cd(179) := g_array(p_seq_num).just_cd_179;
    g_just_cd(180) := g_array(p_seq_num).just_cd_180;
    g_just_cd(181) := g_array(p_seq_num).just_cd_181;
    g_just_cd(182) := g_array(p_seq_num).just_cd_182;
    g_just_cd(183) := g_array(p_seq_num).just_cd_183;
    g_just_cd(184) := g_array(p_seq_num).just_cd_184;
    g_just_cd(185) := g_array(p_seq_num).just_cd_185;
    g_just_cd(186) := g_array(p_seq_num).just_cd_186;
    g_just_cd(187) := g_array(p_seq_num).just_cd_187;
    g_just_cd(188) := g_array(p_seq_num).just_cd_188;
    g_just_cd(189) := g_array(p_seq_num).just_cd_189;
    g_just_cd(190) := g_array(p_seq_num).just_cd_190;
    g_just_cd(191) := g_array(p_seq_num).just_cd_191;
    g_just_cd(192) := g_array(p_seq_num).just_cd_192;
    g_just_cd(193) := g_array(p_seq_num).just_cd_193;
    g_just_cd(194) := g_array(p_seq_num).just_cd_194;
    g_just_cd(195) := g_array(p_seq_num).just_cd_195;
    g_just_cd(196) := g_array(p_seq_num).just_cd_196;
    g_just_cd(197) := g_array(p_seq_num).just_cd_197;
    g_just_cd(198) := g_array(p_seq_num).just_cd_198;
    g_just_cd(199) := g_array(p_seq_num).just_cd_199;
    g_just_cd(200) := g_array(p_seq_num).just_cd_200;
    g_just_cd(201) := g_array(p_seq_num).just_cd_201;
    g_just_cd(202) := g_array(p_seq_num).just_cd_202;
    g_just_cd(203) := g_array(p_seq_num).just_cd_203;
    g_just_cd(204) := g_array(p_seq_num).just_cd_204;
    g_just_cd(205) := g_array(p_seq_num).just_cd_205;
    g_just_cd(206) := g_array(p_seq_num).just_cd_206;
    g_just_cd(207) := g_array(p_seq_num).just_cd_207;
    g_just_cd(208) := g_array(p_seq_num).just_cd_208;
    g_just_cd(209) := g_array(p_seq_num).just_cd_209;
    g_just_cd(210) := g_array(p_seq_num).just_cd_210;
    g_just_cd(211) := g_array(p_seq_num).just_cd_211;
    g_just_cd(212) := g_array(p_seq_num).just_cd_212;
    g_just_cd(213) := g_array(p_seq_num).just_cd_213;
    g_just_cd(214) := g_array(p_seq_num).just_cd_214;
    g_just_cd(215) := g_array(p_seq_num).just_cd_215;
    g_just_cd(216) := g_array(p_seq_num).just_cd_216;
    g_just_cd(217) := g_array(p_seq_num).just_cd_217;
    g_just_cd(218) := g_array(p_seq_num).just_cd_218;
    g_just_cd(219) := g_array(p_seq_num).just_cd_219;
    g_just_cd(220) := g_array(p_seq_num).just_cd_220;
    g_just_cd(221) := g_array(p_seq_num).just_cd_221;
    g_just_cd(222) := g_array(p_seq_num).just_cd_222;
    g_just_cd(223) := g_array(p_seq_num).just_cd_223;
    g_just_cd(224) := g_array(p_seq_num).just_cd_224;
    g_just_cd(225) := g_array(p_seq_num).just_cd_225;
    g_just_cd(226) := g_array(p_seq_num).just_cd_226;
    g_just_cd(227) := g_array(p_seq_num).just_cd_227;
    g_just_cd(228) := g_array(p_seq_num).just_cd_228;
    g_just_cd(229) := g_array(p_seq_num).just_cd_229;
    g_just_cd(230) := g_array(p_seq_num).just_cd_230;
    g_just_cd(231) := g_array(p_seq_num).just_cd_231;
    g_just_cd(232) := g_array(p_seq_num).just_cd_232;
    g_just_cd(233) := g_array(p_seq_num).just_cd_233;
    g_just_cd(234) := g_array(p_seq_num).just_cd_234;
    g_just_cd(235) := g_array(p_seq_num).just_cd_235;
    g_just_cd(236) := g_array(p_seq_num).just_cd_236;
    g_just_cd(237) := g_array(p_seq_num).just_cd_237;
    g_just_cd(238) := g_array(p_seq_num).just_cd_238;
    g_just_cd(239) := g_array(p_seq_num).just_cd_239;
    g_just_cd(240) := g_array(p_seq_num).just_cd_240;
    g_just_cd(241) := g_array(p_seq_num).just_cd_241;
    g_just_cd(242) := g_array(p_seq_num).just_cd_242;
    g_just_cd(243) := g_array(p_seq_num).just_cd_243;
    g_just_cd(244) := g_array(p_seq_num).just_cd_244;
    g_just_cd(245) := g_array(p_seq_num).just_cd_245;
    g_just_cd(246) := g_array(p_seq_num).just_cd_246;
    g_just_cd(247) := g_array(p_seq_num).just_cd_247;
    g_just_cd(248) := g_array(p_seq_num).just_cd_248;
    g_just_cd(249) := g_array(p_seq_num).just_cd_249;
    g_just_cd(250) := g_array(p_seq_num).just_cd_250;
    g_just_cd(251) := g_array(p_seq_num).just_cd_251;
    g_just_cd(252) := g_array(p_seq_num).just_cd_252;
    g_just_cd(253) := g_array(p_seq_num).just_cd_253;
    g_just_cd(254) := g_array(p_seq_num).just_cd_254;
    g_just_cd(255) := g_array(p_seq_num).just_cd_255;
    g_just_cd(256) := g_array(p_seq_num).just_cd_256;
    g_just_cd(257) := g_array(p_seq_num).just_cd_257;
    g_just_cd(258) := g_array(p_seq_num).just_cd_258;
    g_just_cd(259) := g_array(p_seq_num).just_cd_259;
    g_just_cd(260) := g_array(p_seq_num).just_cd_260;
    g_just_cd(261) := g_array(p_seq_num).just_cd_261;
    g_just_cd(262) := g_array(p_seq_num).just_cd_262;
    g_just_cd(263) := g_array(p_seq_num).just_cd_263;
    g_just_cd(264) := g_array(p_seq_num).just_cd_264;
    g_just_cd(265) := g_array(p_seq_num).just_cd_265;
    g_just_cd(266) := g_array(p_seq_num).just_cd_266;
    g_just_cd(267) := g_array(p_seq_num).just_cd_267;
    g_just_cd(268) := g_array(p_seq_num).just_cd_268;
    g_just_cd(269) := g_array(p_seq_num).just_cd_269;
    g_just_cd(270) := g_array(p_seq_num).just_cd_270;
    g_just_cd(271) := g_array(p_seq_num).just_cd_271;
    g_just_cd(272) := g_array(p_seq_num).just_cd_272;
    g_just_cd(273) := g_array(p_seq_num).just_cd_273;
    g_just_cd(274) := g_array(p_seq_num).just_cd_274;
    g_just_cd(275) := g_array(p_seq_num).just_cd_275;
    g_just_cd(276) := g_array(p_seq_num).just_cd_276;
    g_just_cd(277) := g_array(p_seq_num).just_cd_277;
    g_just_cd(278) := g_array(p_seq_num).just_cd_278;
    g_just_cd(279) := g_array(p_seq_num).just_cd_279;
    g_just_cd(280) := g_array(p_seq_num).just_cd_280;
    g_just_cd(281) := g_array(p_seq_num).just_cd_281;
    g_just_cd(282) := g_array(p_seq_num).just_cd_282;
    g_just_cd(283) := g_array(p_seq_num).just_cd_283;
    g_just_cd(284) := g_array(p_seq_num).just_cd_284;
    g_just_cd(285) := g_array(p_seq_num).just_cd_285;
    g_just_cd(286) := g_array(p_seq_num).just_cd_286;
    g_just_cd(287) := g_array(p_seq_num).just_cd_287;
    g_just_cd(288) := g_array(p_seq_num).just_cd_288;
    g_just_cd(289) := g_array(p_seq_num).just_cd_289;
    g_just_cd(290) := g_array(p_seq_num).just_cd_290;
    g_just_cd(291) := g_array(p_seq_num).just_cd_291;
    g_just_cd(292) := g_array(p_seq_num).just_cd_292;
    g_just_cd(293) := g_array(p_seq_num).just_cd_293;
    g_just_cd(294) := g_array(p_seq_num).just_cd_294;
    g_just_cd(295) := g_array(p_seq_num).just_cd_295;
    g_just_cd(296) := g_array(p_seq_num).just_cd_296;
    g_just_cd(297) := g_array(p_seq_num).just_cd_297;
    g_just_cd(298) := g_array(p_seq_num).just_cd_298;
    g_just_cd(299) := g_array(p_seq_num).just_cd_299;
    g_just_cd(300) := g_array(p_seq_num).just_cd_300;


    --
    g_hide_flag(01) := g_array(p_seq_num).hide_flag_01;
    g_hide_flag(02) := g_array(p_seq_num).hide_flag_02;
    g_hide_flag(03) := g_array(p_seq_num).hide_flag_03;
    g_hide_flag(04) := g_array(p_seq_num).hide_flag_04;
    g_hide_flag(05) := g_array(p_seq_num).hide_flag_05;
    g_hide_flag(06) := g_array(p_seq_num).hide_flag_06;
    g_hide_flag(07) := g_array(p_seq_num).hide_flag_07;
    g_hide_flag(08) := g_array(p_seq_num).hide_flag_08;
    g_hide_flag(09) := g_array(p_seq_num).hide_flag_09;
    g_hide_flag(10) := g_array(p_seq_num).hide_flag_10;
    g_hide_flag(11) := g_array(p_seq_num).hide_flag_11;
    g_hide_flag(12) := g_array(p_seq_num).hide_flag_12;
    g_hide_flag(13) := g_array(p_seq_num).hide_flag_13;
    g_hide_flag(14) := g_array(p_seq_num).hide_flag_14;
    g_hide_flag(15) := g_array(p_seq_num).hide_flag_15;
    g_hide_flag(16) := g_array(p_seq_num).hide_flag_16;
    g_hide_flag(17) := g_array(p_seq_num).hide_flag_17;
    g_hide_flag(18) := g_array(p_seq_num).hide_flag_18;
    g_hide_flag(19) := g_array(p_seq_num).hide_flag_19;
    g_hide_flag(20) := g_array(p_seq_num).hide_flag_20;
    g_hide_flag(21) := g_array(p_seq_num).hide_flag_21;
    g_hide_flag(22) := g_array(p_seq_num).hide_flag_22;
    g_hide_flag(23) := g_array(p_seq_num).hide_flag_23;
    g_hide_flag(24) := g_array(p_seq_num).hide_flag_24;
    g_hide_flag(25) := g_array(p_seq_num).hide_flag_25;
    g_hide_flag(26) := g_array(p_seq_num).hide_flag_26;
    g_hide_flag(27) := g_array(p_seq_num).hide_flag_27;
    g_hide_flag(28) := g_array(p_seq_num).hide_flag_28;
    g_hide_flag(29) := g_array(p_seq_num).hide_flag_29;
    g_hide_flag(30) := g_array(p_seq_num).hide_flag_30;
    g_hide_flag(31) := g_array(p_seq_num).hide_flag_31;
    g_hide_flag(32) := g_array(p_seq_num).hide_flag_32;
    g_hide_flag(33) := g_array(p_seq_num).hide_flag_33;
    g_hide_flag(34) := g_array(p_seq_num).hide_flag_34;
    g_hide_flag(35) := g_array(p_seq_num).hide_flag_35;
    g_hide_flag(36) := g_array(p_seq_num).hide_flag_36;
    g_hide_flag(37) := g_array(p_seq_num).hide_flag_37;
    g_hide_flag(38) := g_array(p_seq_num).hide_flag_38;
    g_hide_flag(39) := g_array(p_seq_num).hide_flag_39;
    g_hide_flag(40) := g_array(p_seq_num).hide_flag_40;
    g_hide_flag(41) := g_array(p_seq_num).hide_flag_41;
    g_hide_flag(42) := g_array(p_seq_num).hide_flag_42;
    g_hide_flag(43) := g_array(p_seq_num).hide_flag_43;
    g_hide_flag(44) := g_array(p_seq_num).hide_flag_44;
    g_hide_flag(45) := g_array(p_seq_num).hide_flag_45;
    g_hide_flag(46) := g_array(p_seq_num).hide_flag_46;
    g_hide_flag(47) := g_array(p_seq_num).hide_flag_47;
    g_hide_flag(48) := g_array(p_seq_num).hide_flag_48;
    g_hide_flag(49) := g_array(p_seq_num).hide_flag_49;
    g_hide_flag(50) := g_array(p_seq_num).hide_flag_50;
    g_hide_flag(51) := g_array(p_seq_num).hide_flag_51;
    g_hide_flag(52) := g_array(p_seq_num).hide_flag_52;
    g_hide_flag(53) := g_array(p_seq_num).hide_flag_53;
    g_hide_flag(54) := g_array(p_seq_num).hide_flag_54;
    g_hide_flag(55) := g_array(p_seq_num).hide_flag_55;
    g_hide_flag(56) := g_array(p_seq_num).hide_flag_56;
    g_hide_flag(57) := g_array(p_seq_num).hide_flag_57;
    g_hide_flag(58) := g_array(p_seq_num).hide_flag_58;
    g_hide_flag(59) := g_array(p_seq_num).hide_flag_59;
    g_hide_flag(60) := g_array(p_seq_num).hide_flag_60;
    g_hide_flag(61) := g_array(p_seq_num).hide_flag_61;
    g_hide_flag(62) := g_array(p_seq_num).hide_flag_62;
    g_hide_flag(63) := g_array(p_seq_num).hide_flag_63;
    g_hide_flag(64) := g_array(p_seq_num).hide_flag_64;
    g_hide_flag(65) := g_array(p_seq_num).hide_flag_65;
    g_hide_flag(66) := g_array(p_seq_num).hide_flag_66;
    g_hide_flag(67) := g_array(p_seq_num).hide_flag_67;
    g_hide_flag(68) := g_array(p_seq_num).hide_flag_68;
    g_hide_flag(69) := g_array(p_seq_num).hide_flag_69;
    g_hide_flag(70) := g_array(p_seq_num).hide_flag_70;
    g_hide_flag(71) := g_array(p_seq_num).hide_flag_71;
    g_hide_flag(72) := g_array(p_seq_num).hide_flag_72;
    g_hide_flag(73) := g_array(p_seq_num).hide_flag_73;
    g_hide_flag(74) := g_array(p_seq_num).hide_flag_74;
    g_hide_flag(75) := g_array(p_seq_num).hide_flag_75;
    g_hide_flag(76) := g_array(p_seq_num).hide_flag_76;
    g_hide_flag(77) := g_array(p_seq_num).hide_flag_77;
    g_hide_flag(78) := g_array(p_seq_num).hide_flag_78;
    g_hide_flag(79) := g_array(p_seq_num).hide_flag_79;
    g_hide_flag(80) := g_array(p_seq_num).hide_flag_80;
    g_hide_flag(81) := g_array(p_seq_num).hide_flag_81;
    g_hide_flag(82) := g_array(p_seq_num).hide_flag_82;
    g_hide_flag(83) := g_array(p_seq_num).hide_flag_83;
    g_hide_flag(84) := g_array(p_seq_num).hide_flag_84;
    g_hide_flag(85) := g_array(p_seq_num).hide_flag_85;
    g_hide_flag(86) := g_array(p_seq_num).hide_flag_86;
    g_hide_flag(87) := g_array(p_seq_num).hide_flag_87;
    g_hide_flag(88) := g_array(p_seq_num).hide_flag_88;
    g_hide_flag(89) := g_array(p_seq_num).hide_flag_89;
    g_hide_flag(90) := g_array(p_seq_num).hide_flag_90;
    g_hide_flag(91) := g_array(p_seq_num).hide_flag_91;
    g_hide_flag(92) := g_array(p_seq_num).hide_flag_92;
    g_hide_flag(93) := g_array(p_seq_num).hide_flag_93;
    g_hide_flag(94) := g_array(p_seq_num).hide_flag_94;
    g_hide_flag(95) := g_array(p_seq_num).hide_flag_95;
    g_hide_flag(96) := g_array(p_seq_num).hide_flag_96;
    g_hide_flag(97) := g_array(p_seq_num).hide_flag_97;
    g_hide_flag(98) := g_array(p_seq_num).hide_flag_98;
    g_hide_flag(99) := g_array(p_seq_num).hide_flag_99;
    g_hide_flag(100) := g_array(p_seq_num).hide_flag_100;
    g_hide_flag(101) := g_array(p_seq_num).hide_flag_101;
    g_hide_flag(102) := g_array(p_seq_num).hide_flag_102;
    g_hide_flag(103) := g_array(p_seq_num).hide_flag_103;
    g_hide_flag(104) := g_array(p_seq_num).hide_flag_104;
    g_hide_flag(105) := g_array(p_seq_num).hide_flag_105;
    g_hide_flag(106) := g_array(p_seq_num).hide_flag_106;
    g_hide_flag(107) := g_array(p_seq_num).hide_flag_107;
    g_hide_flag(108) := g_array(p_seq_num).hide_flag_108;
    g_hide_flag(109) := g_array(p_seq_num).hide_flag_109;
    g_hide_flag(110) := g_array(p_seq_num).hide_flag_110;
    g_hide_flag(111) := g_array(p_seq_num).hide_flag_111;
    g_hide_flag(112) := g_array(p_seq_num).hide_flag_112;
    g_hide_flag(113) := g_array(p_seq_num).hide_flag_113;
    g_hide_flag(114) := g_array(p_seq_num).hide_flag_114;
    g_hide_flag(115) := g_array(p_seq_num).hide_flag_115;
    g_hide_flag(116) := g_array(p_seq_num).hide_flag_116;
    g_hide_flag(117) := g_array(p_seq_num).hide_flag_117;
    g_hide_flag(118) := g_array(p_seq_num).hide_flag_118;
    g_hide_flag(119) := g_array(p_seq_num).hide_flag_119;
    g_hide_flag(120) := g_array(p_seq_num).hide_flag_120;
    g_hide_flag(121) := g_array(p_seq_num).hide_flag_121;
    g_hide_flag(122) := g_array(p_seq_num).hide_flag_122;
    g_hide_flag(123) := g_array(p_seq_num).hide_flag_123;
    g_hide_flag(124) := g_array(p_seq_num).hide_flag_124;
    g_hide_flag(125) := g_array(p_seq_num).hide_flag_125;
    g_hide_flag(126) := g_array(p_seq_num).hide_flag_126;
    g_hide_flag(127) := g_array(p_seq_num).hide_flag_127;
    g_hide_flag(128) := g_array(p_seq_num).hide_flag_128;
    g_hide_flag(129) := g_array(p_seq_num).hide_flag_129;
    g_hide_flag(130) := g_array(p_seq_num).hide_flag_130;
    g_hide_flag(131) := g_array(p_seq_num).hide_flag_131;
    g_hide_flag(132) := g_array(p_seq_num).hide_flag_132;
    g_hide_flag(133) := g_array(p_seq_num).hide_flag_133;
    g_hide_flag(134) := g_array(p_seq_num).hide_flag_134;
    g_hide_flag(135) := g_array(p_seq_num).hide_flag_135;
    g_hide_flag(136) := g_array(p_seq_num).hide_flag_136;
    g_hide_flag(137) := g_array(p_seq_num).hide_flag_137;
    g_hide_flag(138) := g_array(p_seq_num).hide_flag_138;
    g_hide_flag(139) := g_array(p_seq_num).hide_flag_139;
    g_hide_flag(140) := g_array(p_seq_num).hide_flag_140;
    g_hide_flag(141) := g_array(p_seq_num).hide_flag_141;
    g_hide_flag(142) := g_array(p_seq_num).hide_flag_142;
    g_hide_flag(143) := g_array(p_seq_num).hide_flag_143;
    g_hide_flag(144) := g_array(p_seq_num).hide_flag_144;
    g_hide_flag(145) := g_array(p_seq_num).hide_flag_145;
    g_hide_flag(146) := g_array(p_seq_num).hide_flag_146;
    g_hide_flag(147) := g_array(p_seq_num).hide_flag_147;
    g_hide_flag(148) := g_array(p_seq_num).hide_flag_148;
    g_hide_flag(149) := g_array(p_seq_num).hide_flag_149;
    g_hide_flag(150) := g_array(p_seq_num).hide_flag_150;
    g_hide_flag(151) := g_array(p_seq_num).hide_flag_151;
    g_hide_flag(152) := g_array(p_seq_num).hide_flag_152;
    g_hide_flag(153) := g_array(p_seq_num).hide_flag_153;
    g_hide_flag(154) := g_array(p_seq_num).hide_flag_154;
    g_hide_flag(155) := g_array(p_seq_num).hide_flag_155;
    g_hide_flag(156) := g_array(p_seq_num).hide_flag_156;
    g_hide_flag(157) := g_array(p_seq_num).hide_flag_157;
    g_hide_flag(158) := g_array(p_seq_num).hide_flag_158;
    g_hide_flag(159) := g_array(p_seq_num).hide_flag_159;
    g_hide_flag(160) := g_array(p_seq_num).hide_flag_160;
    g_hide_flag(161) := g_array(p_seq_num).hide_flag_161;
    g_hide_flag(162) := g_array(p_seq_num).hide_flag_162;
    g_hide_flag(163) := g_array(p_seq_num).hide_flag_163;
    g_hide_flag(164) := g_array(p_seq_num).hide_flag_164;
    g_hide_flag(165) := g_array(p_seq_num).hide_flag_165;
    g_hide_flag(166) := g_array(p_seq_num).hide_flag_166;
    g_hide_flag(167) := g_array(p_seq_num).hide_flag_167;
    g_hide_flag(168) := g_array(p_seq_num).hide_flag_168;
    g_hide_flag(169) := g_array(p_seq_num).hide_flag_169;
    g_hide_flag(170) := g_array(p_seq_num).hide_flag_170;
    g_hide_flag(171) := g_array(p_seq_num).hide_flag_171;
    g_hide_flag(172) := g_array(p_seq_num).hide_flag_172;
    g_hide_flag(173) := g_array(p_seq_num).hide_flag_173;
    g_hide_flag(174) := g_array(p_seq_num).hide_flag_174;
    g_hide_flag(175) := g_array(p_seq_num).hide_flag_175;
    g_hide_flag(176) := g_array(p_seq_num).hide_flag_176;
    g_hide_flag(177) := g_array(p_seq_num).hide_flag_177;
    g_hide_flag(178) := g_array(p_seq_num).hide_flag_178;
    g_hide_flag(179) := g_array(p_seq_num).hide_flag_179;
    g_hide_flag(180) := g_array(p_seq_num).hide_flag_180;
    g_hide_flag(181) := g_array(p_seq_num).hide_flag_181;
    g_hide_flag(182) := g_array(p_seq_num).hide_flag_182;
    g_hide_flag(183) := g_array(p_seq_num).hide_flag_183;
    g_hide_flag(184) := g_array(p_seq_num).hide_flag_184;
    g_hide_flag(185) := g_array(p_seq_num).hide_flag_185;
    g_hide_flag(186) := g_array(p_seq_num).hide_flag_186;
    g_hide_flag(187) := g_array(p_seq_num).hide_flag_187;
    g_hide_flag(188) := g_array(p_seq_num).hide_flag_188;
    g_hide_flag(189) := g_array(p_seq_num).hide_flag_189;
    g_hide_flag(190) := g_array(p_seq_num).hide_flag_190;
    g_hide_flag(191) := g_array(p_seq_num).hide_flag_191;
    g_hide_flag(192) := g_array(p_seq_num).hide_flag_192;
    g_hide_flag(193) := g_array(p_seq_num).hide_flag_193;
    g_hide_flag(194) := g_array(p_seq_num).hide_flag_194;
    g_hide_flag(195) := g_array(p_seq_num).hide_flag_195;
    g_hide_flag(196) := g_array(p_seq_num).hide_flag_196;
    g_hide_flag(197) := g_array(p_seq_num).hide_flag_197;
    g_hide_flag(198) := g_array(p_seq_num).hide_flag_198;
    g_hide_flag(199) := g_array(p_seq_num).hide_flag_199;
    g_hide_flag(200) := g_array(p_seq_num).hide_flag_200;
    g_hide_flag(201) := g_array(p_seq_num).hide_flag_201;
    g_hide_flag(202) := g_array(p_seq_num).hide_flag_202;
    g_hide_flag(203) := g_array(p_seq_num).hide_flag_203;
    g_hide_flag(204) := g_array(p_seq_num).hide_flag_204;
    g_hide_flag(205) := g_array(p_seq_num).hide_flag_205;
    g_hide_flag(206) := g_array(p_seq_num).hide_flag_206;
    g_hide_flag(207) := g_array(p_seq_num).hide_flag_207;
    g_hide_flag(208) := g_array(p_seq_num).hide_flag_208;
    g_hide_flag(209) := g_array(p_seq_num).hide_flag_209;
    g_hide_flag(210) := g_array(p_seq_num).hide_flag_210;
    g_hide_flag(211) := g_array(p_seq_num).hide_flag_211;
    g_hide_flag(212) := g_array(p_seq_num).hide_flag_212;
    g_hide_flag(213) := g_array(p_seq_num).hide_flag_213;
    g_hide_flag(214) := g_array(p_seq_num).hide_flag_214;
    g_hide_flag(215) := g_array(p_seq_num).hide_flag_215;
    g_hide_flag(216) := g_array(p_seq_num).hide_flag_216;
    g_hide_flag(217) := g_array(p_seq_num).hide_flag_217;
    g_hide_flag(218) := g_array(p_seq_num).hide_flag_218;
    g_hide_flag(219) := g_array(p_seq_num).hide_flag_219;
    g_hide_flag(220) := g_array(p_seq_num).hide_flag_220;
    g_hide_flag(221) := g_array(p_seq_num).hide_flag_221;
    g_hide_flag(222) := g_array(p_seq_num).hide_flag_222;
    g_hide_flag(223) := g_array(p_seq_num).hide_flag_223;
    g_hide_flag(224) := g_array(p_seq_num).hide_flag_224;
    g_hide_flag(225) := g_array(p_seq_num).hide_flag_225;
    g_hide_flag(226) := g_array(p_seq_num).hide_flag_226;
    g_hide_flag(227) := g_array(p_seq_num).hide_flag_227;
    g_hide_flag(228) := g_array(p_seq_num).hide_flag_228;
    g_hide_flag(229) := g_array(p_seq_num).hide_flag_229;
    g_hide_flag(230) := g_array(p_seq_num).hide_flag_230;
    g_hide_flag(231) := g_array(p_seq_num).hide_flag_231;
    g_hide_flag(232) := g_array(p_seq_num).hide_flag_232;
    g_hide_flag(233) := g_array(p_seq_num).hide_flag_233;
    g_hide_flag(234) := g_array(p_seq_num).hide_flag_234;
    g_hide_flag(235) := g_array(p_seq_num).hide_flag_235;
    g_hide_flag(236) := g_array(p_seq_num).hide_flag_236;
    g_hide_flag(237) := g_array(p_seq_num).hide_flag_237;
    g_hide_flag(238) := g_array(p_seq_num).hide_flag_238;
    g_hide_flag(239) := g_array(p_seq_num).hide_flag_239;
    g_hide_flag(240) := g_array(p_seq_num).hide_flag_240;
    g_hide_flag(241) := g_array(p_seq_num).hide_flag_241;
    g_hide_flag(242) := g_array(p_seq_num).hide_flag_242;
    g_hide_flag(243) := g_array(p_seq_num).hide_flag_243;
    g_hide_flag(244) := g_array(p_seq_num).hide_flag_244;
    g_hide_flag(245) := g_array(p_seq_num).hide_flag_245;
    g_hide_flag(246) := g_array(p_seq_num).hide_flag_246;
    g_hide_flag(247) := g_array(p_seq_num).hide_flag_247;
    g_hide_flag(248) := g_array(p_seq_num).hide_flag_248;
    g_hide_flag(249) := g_array(p_seq_num).hide_flag_249;
    g_hide_flag(250) := g_array(p_seq_num).hide_flag_250;
    g_hide_flag(251) := g_array(p_seq_num).hide_flag_251;
    g_hide_flag(252) := g_array(p_seq_num).hide_flag_252;
    g_hide_flag(253) := g_array(p_seq_num).hide_flag_253;
    g_hide_flag(254) := g_array(p_seq_num).hide_flag_254;
    g_hide_flag(255) := g_array(p_seq_num).hide_flag_255;
    g_hide_flag(256) := g_array(p_seq_num).hide_flag_256;
    g_hide_flag(257) := g_array(p_seq_num).hide_flag_257;
    g_hide_flag(258) := g_array(p_seq_num).hide_flag_258;
    g_hide_flag(259) := g_array(p_seq_num).hide_flag_259;
    g_hide_flag(260) := g_array(p_seq_num).hide_flag_260;
    g_hide_flag(261) := g_array(p_seq_num).hide_flag_261;
    g_hide_flag(262) := g_array(p_seq_num).hide_flag_262;
    g_hide_flag(263) := g_array(p_seq_num).hide_flag_263;
    g_hide_flag(264) := g_array(p_seq_num).hide_flag_264;
    g_hide_flag(265) := g_array(p_seq_num).hide_flag_265;
    g_hide_flag(266) := g_array(p_seq_num).hide_flag_266;
    g_hide_flag(267) := g_array(p_seq_num).hide_flag_267;
    g_hide_flag(268) := g_array(p_seq_num).hide_flag_268;
    g_hide_flag(269) := g_array(p_seq_num).hide_flag_269;
    g_hide_flag(270) := g_array(p_seq_num).hide_flag_270;
    g_hide_flag(271) := g_array(p_seq_num).hide_flag_271;
    g_hide_flag(272) := g_array(p_seq_num).hide_flag_272;
    g_hide_flag(273) := g_array(p_seq_num).hide_flag_273;
    g_hide_flag(274) := g_array(p_seq_num).hide_flag_274;
    g_hide_flag(275) := g_array(p_seq_num).hide_flag_275;
    g_hide_flag(276) := g_array(p_seq_num).hide_flag_276;
    g_hide_flag(277) := g_array(p_seq_num).hide_flag_277;
    g_hide_flag(278) := g_array(p_seq_num).hide_flag_278;
    g_hide_flag(279) := g_array(p_seq_num).hide_flag_279;
    g_hide_flag(280) := g_array(p_seq_num).hide_flag_280;
    g_hide_flag(281) := g_array(p_seq_num).hide_flag_281;
    g_hide_flag(282) := g_array(p_seq_num).hide_flag_282;
    g_hide_flag(283) := g_array(p_seq_num).hide_flag_283;
    g_hide_flag(284) := g_array(p_seq_num).hide_flag_284;
    g_hide_flag(285) := g_array(p_seq_num).hide_flag_285;
    g_hide_flag(286) := g_array(p_seq_num).hide_flag_286;
    g_hide_flag(287) := g_array(p_seq_num).hide_flag_287;
    g_hide_flag(288) := g_array(p_seq_num).hide_flag_288;
    g_hide_flag(289) := g_array(p_seq_num).hide_flag_289;
    g_hide_flag(290) := g_array(p_seq_num).hide_flag_290;
    g_hide_flag(291) := g_array(p_seq_num).hide_flag_291;
    g_hide_flag(292) := g_array(p_seq_num).hide_flag_292;
    g_hide_flag(293) := g_array(p_seq_num).hide_flag_293;
    g_hide_flag(294) := g_array(p_seq_num).hide_flag_294;
    g_hide_flag(295) := g_array(p_seq_num).hide_flag_295;
    g_hide_flag(296) := g_array(p_seq_num).hide_flag_296;
    g_hide_flag(297) := g_array(p_seq_num).hide_flag_297;
    g_hide_flag(298) := g_array(p_seq_num).hide_flag_298;
    g_hide_flag(299) := g_array(p_seq_num).hide_flag_299;
    g_hide_flag(300) := g_array(p_seq_num).hide_flag_300;
    --
    g_short_name(01) := g_array(p_seq_num).short_name_01;
    g_short_name(02) := g_array(p_seq_num).short_name_02;
    g_short_name(03) := g_array(p_seq_num).short_name_03;
    g_short_name(04) := g_array(p_seq_num).short_name_04;
    g_short_name(05) := g_array(p_seq_num).short_name_05;
    g_short_name(06) := g_array(p_seq_num).short_name_06;
    g_short_name(07) := g_array(p_seq_num).short_name_07;
    g_short_name(08) := g_array(p_seq_num).short_name_08;
    g_short_name(09) := g_array(p_seq_num).short_name_09;
    g_short_name(10) := g_array(p_seq_num).short_name_10;
    g_short_name(11) := g_array(p_seq_num).short_name_11;
    g_short_name(12) := g_array(p_seq_num).short_name_12;
    g_short_name(13) := g_array(p_seq_num).short_name_13;
    g_short_name(14) := g_array(p_seq_num).short_name_14;
    g_short_name(15) := g_array(p_seq_num).short_name_15;
    g_short_name(16) := g_array(p_seq_num).short_name_16;
    g_short_name(17) := g_array(p_seq_num).short_name_17;
    g_short_name(18) := g_array(p_seq_num).short_name_18;
    g_short_name(19) := g_array(p_seq_num).short_name_19;
    g_short_name(20) := g_array(p_seq_num).short_name_20;
    g_short_name(21) := g_array(p_seq_num).short_name_21;
    g_short_name(22) := g_array(p_seq_num).short_name_22;
    g_short_name(23) := g_array(p_seq_num).short_name_23;
    g_short_name(24) := g_array(p_seq_num).short_name_24;
    g_short_name(25) := g_array(p_seq_num).short_name_25;
    g_short_name(26) := g_array(p_seq_num).short_name_26;
    g_short_name(27) := g_array(p_seq_num).short_name_27;
    g_short_name(28) := g_array(p_seq_num).short_name_28;
    g_short_name(29) := g_array(p_seq_num).short_name_29;
    g_short_name(30) := g_array(p_seq_num).short_name_30;
    g_short_name(31) := g_array(p_seq_num).short_name_31;
    g_short_name(32) := g_array(p_seq_num).short_name_32;
    g_short_name(33) := g_array(p_seq_num).short_name_33;
    g_short_name(34) := g_array(p_seq_num).short_name_34;
    g_short_name(35) := g_array(p_seq_num).short_name_35;
    g_short_name(36) := g_array(p_seq_num).short_name_36;
    g_short_name(37) := g_array(p_seq_num).short_name_37;
    g_short_name(38) := g_array(p_seq_num).short_name_38;
    g_short_name(39) := g_array(p_seq_num).short_name_39;
    g_short_name(40) := g_array(p_seq_num).short_name_40;
    g_short_name(41) := g_array(p_seq_num).short_name_41;
    g_short_name(42) := g_array(p_seq_num).short_name_42;
    g_short_name(43) := g_array(p_seq_num).short_name_43;
    g_short_name(44) := g_array(p_seq_num).short_name_44;
    g_short_name(45) := g_array(p_seq_num).short_name_45;
    g_short_name(46) := g_array(p_seq_num).short_name_46;
    g_short_name(47) := g_array(p_seq_num).short_name_47;
    g_short_name(48) := g_array(p_seq_num).short_name_48;
    g_short_name(49) := g_array(p_seq_num).short_name_49;
    g_short_name(50) := g_array(p_seq_num).short_name_50;
    g_short_name(51) := g_array(p_seq_num).short_name_51;
    g_short_name(52) := g_array(p_seq_num).short_name_52;
    g_short_name(53) := g_array(p_seq_num).short_name_53;
    g_short_name(54) := g_array(p_seq_num).short_name_54;
    g_short_name(55) := g_array(p_seq_num).short_name_55;
    g_short_name(56) := g_array(p_seq_num).short_name_56;
    g_short_name(57) := g_array(p_seq_num).short_name_57;
    g_short_name(58) := g_array(p_seq_num).short_name_58;
    g_short_name(59) := g_array(p_seq_num).short_name_59;
    g_short_name(60) := g_array(p_seq_num).short_name_60;
    g_short_name(61) := g_array(p_seq_num).short_name_61;
    g_short_name(62) := g_array(p_seq_num).short_name_62;
    g_short_name(63) := g_array(p_seq_num).short_name_63;
    g_short_name(64) := g_array(p_seq_num).short_name_64;
    g_short_name(65) := g_array(p_seq_num).short_name_65;
    g_short_name(66) := g_array(p_seq_num).short_name_66;
    g_short_name(67) := g_array(p_seq_num).short_name_67;
    g_short_name(68) := g_array(p_seq_num).short_name_68;
    g_short_name(69) := g_array(p_seq_num).short_name_69;
    g_short_name(70) := g_array(p_seq_num).short_name_70;
    g_short_name(71) := g_array(p_seq_num).short_name_71;
    g_short_name(72) := g_array(p_seq_num).short_name_72;
    g_short_name(73) := g_array(p_seq_num).short_name_73;
    g_short_name(74) := g_array(p_seq_num).short_name_74;
    g_short_name(75) := g_array(p_seq_num).short_name_75;
    g_short_name(76) := g_array(p_seq_num).short_name_76;
    g_short_name(77) := g_array(p_seq_num).short_name_77;
    g_short_name(78) := g_array(p_seq_num).short_name_78;
    g_short_name(79) := g_array(p_seq_num).short_name_79;
    g_short_name(80) := g_array(p_seq_num).short_name_80;
    g_short_name(81) := g_array(p_seq_num).short_name_81;
    g_short_name(82) := g_array(p_seq_num).short_name_82;
    g_short_name(83) := g_array(p_seq_num).short_name_83;
    g_short_name(84) := g_array(p_seq_num).short_name_84;
    g_short_name(85) := g_array(p_seq_num).short_name_85;
    g_short_name(86) := g_array(p_seq_num).short_name_86;
    g_short_name(87) := g_array(p_seq_num).short_name_87;
    g_short_name(88) := g_array(p_seq_num).short_name_88;
    g_short_name(89) := g_array(p_seq_num).short_name_89;
    g_short_name(90) := g_array(p_seq_num).short_name_90;
    g_short_name(91) := g_array(p_seq_num).short_name_91;
    g_short_name(92) := g_array(p_seq_num).short_name_92;
    g_short_name(93) := g_array(p_seq_num).short_name_93;
    g_short_name(94) := g_array(p_seq_num).short_name_94;
    g_short_name(95) := g_array(p_seq_num).short_name_95;
    g_short_name(96) := g_array(p_seq_num).short_name_96;
    g_short_name(97) := g_array(p_seq_num).short_name_97;
    g_short_name(98) := g_array(p_seq_num).short_name_98;
    g_short_name(99) := g_array(p_seq_num).short_name_99;
    g_short_name(100) := g_array(p_seq_num).short_name_100;
    g_short_name(101) := g_array(p_seq_num).short_name_101;
    g_short_name(102) := g_array(p_seq_num).short_name_102;
    g_short_name(103) := g_array(p_seq_num).short_name_103;
    g_short_name(104) := g_array(p_seq_num).short_name_104;
    g_short_name(105) := g_array(p_seq_num).short_name_105;
    g_short_name(106) := g_array(p_seq_num).short_name_106;
    g_short_name(107) := g_array(p_seq_num).short_name_107;
    g_short_name(108) := g_array(p_seq_num).short_name_108;
    g_short_name(109) := g_array(p_seq_num).short_name_109;
    g_short_name(110) := g_array(p_seq_num).short_name_110;
    g_short_name(111) := g_array(p_seq_num).short_name_111;
    g_short_name(112) := g_array(p_seq_num).short_name_112;
    g_short_name(113) := g_array(p_seq_num).short_name_113;
    g_short_name(114) := g_array(p_seq_num).short_name_114;
    g_short_name(115) := g_array(p_seq_num).short_name_115;
    g_short_name(116) := g_array(p_seq_num).short_name_116;
    g_short_name(117) := g_array(p_seq_num).short_name_117;
    g_short_name(118) := g_array(p_seq_num).short_name_118;
    g_short_name(119) := g_array(p_seq_num).short_name_119;
    g_short_name(120) := g_array(p_seq_num).short_name_120;
    g_short_name(121) := g_array(p_seq_num).short_name_121;
    g_short_name(122) := g_array(p_seq_num).short_name_122;
    g_short_name(123) := g_array(p_seq_num).short_name_123;
    g_short_name(124) := g_array(p_seq_num).short_name_124;
    g_short_name(125) := g_array(p_seq_num).short_name_125;
    g_short_name(126) := g_array(p_seq_num).short_name_126;
    g_short_name(127) := g_array(p_seq_num).short_name_127;
    g_short_name(128) := g_array(p_seq_num).short_name_128;
    g_short_name(129) := g_array(p_seq_num).short_name_129;
    g_short_name(130) := g_array(p_seq_num).short_name_130;
    g_short_name(131) := g_array(p_seq_num).short_name_131;
    g_short_name(132) := g_array(p_seq_num).short_name_132;
    g_short_name(133) := g_array(p_seq_num).short_name_133;
    g_short_name(134) := g_array(p_seq_num).short_name_134;
    g_short_name(135) := g_array(p_seq_num).short_name_135;
    g_short_name(136) := g_array(p_seq_num).short_name_136;
    g_short_name(137) := g_array(p_seq_num).short_name_137;
    g_short_name(138) := g_array(p_seq_num).short_name_138;
    g_short_name(139) := g_array(p_seq_num).short_name_139;
    g_short_name(140) := g_array(p_seq_num).short_name_140;
    g_short_name(141) := g_array(p_seq_num).short_name_141;
    g_short_name(142) := g_array(p_seq_num).short_name_142;
    g_short_name(143) := g_array(p_seq_num).short_name_143;
    g_short_name(144) := g_array(p_seq_num).short_name_144;
    g_short_name(145) := g_array(p_seq_num).short_name_145;
    g_short_name(146) := g_array(p_seq_num).short_name_146;
    g_short_name(147) := g_array(p_seq_num).short_name_147;
    g_short_name(148) := g_array(p_seq_num).short_name_148;
    g_short_name(149) := g_array(p_seq_num).short_name_149;
    g_short_name(150) := g_array(p_seq_num).short_name_150;
    g_short_name(151) := g_array(p_seq_num).short_name_151;
    g_short_name(152) := g_array(p_seq_num).short_name_152;
    g_short_name(153) := g_array(p_seq_num).short_name_153;
    g_short_name(154) := g_array(p_seq_num).short_name_154;
    g_short_name(155) := g_array(p_seq_num).short_name_155;
    g_short_name(156) := g_array(p_seq_num).short_name_156;
    g_short_name(157) := g_array(p_seq_num).short_name_157;
    g_short_name(158) := g_array(p_seq_num).short_name_158;
    g_short_name(159) := g_array(p_seq_num).short_name_159;
    g_short_name(160) := g_array(p_seq_num).short_name_160;
    g_short_name(161) := g_array(p_seq_num).short_name_161;
    g_short_name(162) := g_array(p_seq_num).short_name_162;
    g_short_name(163) := g_array(p_seq_num).short_name_163;
    g_short_name(164) := g_array(p_seq_num).short_name_164;
    g_short_name(165) := g_array(p_seq_num).short_name_165;
    g_short_name(166) := g_array(p_seq_num).short_name_166;
    g_short_name(167) := g_array(p_seq_num).short_name_167;
    g_short_name(168) := g_array(p_seq_num).short_name_168;
    g_short_name(169) := g_array(p_seq_num).short_name_169;
    g_short_name(170) := g_array(p_seq_num).short_name_170;
    g_short_name(171) := g_array(p_seq_num).short_name_171;
    g_short_name(172) := g_array(p_seq_num).short_name_172;
    g_short_name(173) := g_array(p_seq_num).short_name_173;
    g_short_name(174) := g_array(p_seq_num).short_name_174;
    g_short_name(175) := g_array(p_seq_num).short_name_175;
    g_short_name(176) := g_array(p_seq_num).short_name_176;
    g_short_name(177) := g_array(p_seq_num).short_name_177;
    g_short_name(178) := g_array(p_seq_num).short_name_178;
    g_short_name(179) := g_array(p_seq_num).short_name_179;
    g_short_name(180) := g_array(p_seq_num).short_name_180;
    g_short_name(181) := g_array(p_seq_num).short_name_181;
    g_short_name(182) := g_array(p_seq_num).short_name_182;
    g_short_name(183) := g_array(p_seq_num).short_name_183;
    g_short_name(184) := g_array(p_seq_num).short_name_184;
    g_short_name(185) := g_array(p_seq_num).short_name_185;
    g_short_name(186) := g_array(p_seq_num).short_name_186;
    g_short_name(187) := g_array(p_seq_num).short_name_187;
    g_short_name(188) := g_array(p_seq_num).short_name_188;
    g_short_name(189) := g_array(p_seq_num).short_name_189;
    g_short_name(190) := g_array(p_seq_num).short_name_190;
    g_short_name(191) := g_array(p_seq_num).short_name_191;
    g_short_name(192) := g_array(p_seq_num).short_name_192;
    g_short_name(193) := g_array(p_seq_num).short_name_193;
    g_short_name(194) := g_array(p_seq_num).short_name_194;
    g_short_name(195) := g_array(p_seq_num).short_name_195;
    g_short_name(196) := g_array(p_seq_num).short_name_196;
    g_short_name(197) := g_array(p_seq_num).short_name_197;
    g_short_name(198) := g_array(p_seq_num).short_name_198;
    g_short_name(199) := g_array(p_seq_num).short_name_199;
    g_short_name(200) := g_array(p_seq_num).short_name_200;
    g_short_name(201) := g_array(p_seq_num).short_name_201;
    g_short_name(202) := g_array(p_seq_num).short_name_202;
    g_short_name(203) := g_array(p_seq_num).short_name_203;
    g_short_name(204) := g_array(p_seq_num).short_name_204;
    g_short_name(205) := g_array(p_seq_num).short_name_205;
    g_short_name(206) := g_array(p_seq_num).short_name_206;
    g_short_name(207) := g_array(p_seq_num).short_name_207;
    g_short_name(208) := g_array(p_seq_num).short_name_208;
    g_short_name(209) := g_array(p_seq_num).short_name_209;
    g_short_name(210) := g_array(p_seq_num).short_name_210;
    g_short_name(211) := g_array(p_seq_num).short_name_211;
    g_short_name(212) := g_array(p_seq_num).short_name_212;
    g_short_name(213) := g_array(p_seq_num).short_name_213;
    g_short_name(214) := g_array(p_seq_num).short_name_214;
    g_short_name(215) := g_array(p_seq_num).short_name_215;
    g_short_name(216) := g_array(p_seq_num).short_name_216;
    g_short_name(217) := g_array(p_seq_num).short_name_217;
    g_short_name(218) := g_array(p_seq_num).short_name_218;
    g_short_name(219) := g_array(p_seq_num).short_name_219;
    g_short_name(220) := g_array(p_seq_num).short_name_220;
    g_short_name(221) := g_array(p_seq_num).short_name_221;
    g_short_name(222) := g_array(p_seq_num).short_name_222;
    g_short_name(223) := g_array(p_seq_num).short_name_223;
    g_short_name(224) := g_array(p_seq_num).short_name_224;
    g_short_name(225) := g_array(p_seq_num).short_name_225;
    g_short_name(226) := g_array(p_seq_num).short_name_226;
    g_short_name(227) := g_array(p_seq_num).short_name_227;
    g_short_name(228) := g_array(p_seq_num).short_name_228;
    g_short_name(229) := g_array(p_seq_num).short_name_229;
    g_short_name(230) := g_array(p_seq_num).short_name_230;
    g_short_name(231) := g_array(p_seq_num).short_name_231;
    g_short_name(232) := g_array(p_seq_num).short_name_232;
    g_short_name(233) := g_array(p_seq_num).short_name_233;
    g_short_name(234) := g_array(p_seq_num).short_name_234;
    g_short_name(235) := g_array(p_seq_num).short_name_235;
    g_short_name(236) := g_array(p_seq_num).short_name_236;
    g_short_name(237) := g_array(p_seq_num).short_name_237;
    g_short_name(238) := g_array(p_seq_num).short_name_238;
    g_short_name(239) := g_array(p_seq_num).short_name_239;
    g_short_name(240) := g_array(p_seq_num).short_name_240;
    g_short_name(241) := g_array(p_seq_num).short_name_241;
    g_short_name(242) := g_array(p_seq_num).short_name_242;
    g_short_name(243) := g_array(p_seq_num).short_name_243;
    g_short_name(244) := g_array(p_seq_num).short_name_244;
    g_short_name(245) := g_array(p_seq_num).short_name_245;
    g_short_name(246) := g_array(p_seq_num).short_name_246;
    g_short_name(247) := g_array(p_seq_num).short_name_247;
    g_short_name(248) := g_array(p_seq_num).short_name_248;
    g_short_name(249) := g_array(p_seq_num).short_name_249;
    g_short_name(250) := g_array(p_seq_num).short_name_250;
    g_short_name(251) := g_array(p_seq_num).short_name_251;
    g_short_name(252) := g_array(p_seq_num).short_name_252;
    g_short_name(253) := g_array(p_seq_num).short_name_253;
    g_short_name(254) := g_array(p_seq_num).short_name_254;
    g_short_name(255) := g_array(p_seq_num).short_name_255;
    g_short_name(256) := g_array(p_seq_num).short_name_256;
    g_short_name(257) := g_array(p_seq_num).short_name_257;
    g_short_name(258) := g_array(p_seq_num).short_name_258;
    g_short_name(259) := g_array(p_seq_num).short_name_259;
    g_short_name(260) := g_array(p_seq_num).short_name_260;
    g_short_name(261) := g_array(p_seq_num).short_name_261;
    g_short_name(262) := g_array(p_seq_num).short_name_262;
    g_short_name(263) := g_array(p_seq_num).short_name_263;
    g_short_name(264) := g_array(p_seq_num).short_name_264;
    g_short_name(265) := g_array(p_seq_num).short_name_265;
    g_short_name(266) := g_array(p_seq_num).short_name_266;
    g_short_name(267) := g_array(p_seq_num).short_name_267;
    g_short_name(268) := g_array(p_seq_num).short_name_268;
    g_short_name(269) := g_array(p_seq_num).short_name_269;
    g_short_name(270) := g_array(p_seq_num).short_name_270;
    g_short_name(271) := g_array(p_seq_num).short_name_271;
    g_short_name(272) := g_array(p_seq_num).short_name_272;
    g_short_name(273) := g_array(p_seq_num).short_name_273;
    g_short_name(274) := g_array(p_seq_num).short_name_274;
    g_short_name(275) := g_array(p_seq_num).short_name_275;
    g_short_name(276) := g_array(p_seq_num).short_name_276;
    g_short_name(277) := g_array(p_seq_num).short_name_277;
    g_short_name(278) := g_array(p_seq_num).short_name_278;
    g_short_name(279) := g_array(p_seq_num).short_name_279;
    g_short_name(280) := g_array(p_seq_num).short_name_280;
    g_short_name(281) := g_array(p_seq_num).short_name_281;
    g_short_name(282) := g_array(p_seq_num).short_name_282;
    g_short_name(283) := g_array(p_seq_num).short_name_283;
    g_short_name(284) := g_array(p_seq_num).short_name_284;
    g_short_name(285) := g_array(p_seq_num).short_name_285;
    g_short_name(286) := g_array(p_seq_num).short_name_286;
    g_short_name(287) := g_array(p_seq_num).short_name_287;
    g_short_name(288) := g_array(p_seq_num).short_name_288;
    g_short_name(289) := g_array(p_seq_num).short_name_289;
    g_short_name(290) := g_array(p_seq_num).short_name_290;
    g_short_name(291) := g_array(p_seq_num).short_name_291;
    g_short_name(292) := g_array(p_seq_num).short_name_292;
    g_short_name(293) := g_array(p_seq_num).short_name_293;
    g_short_name(294) := g_array(p_seq_num).short_name_294;
    g_short_name(295) := g_array(p_seq_num).short_name_295;
    g_short_name(296) := g_array(p_seq_num).short_name_296;
    g_short_name(297) := g_array(p_seq_num).short_name_297;
    g_short_name(298) := g_array(p_seq_num).short_name_298;
    g_short_name(299) := g_array(p_seq_num).short_name_299;
    g_short_name(300) := g_array(p_seq_num).short_name_300;
    --
    g_last_rcd_processed := p_ext_rcd_id;
    --
  end if;
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
--
end load_arrays;
-----------------------------------------------------------------------------
Procedure WRITE_WARNING
           (p_err_name in varchar2,
            p_ext_rslt_id in number default null ,
            l_value       in varchar2 default null  ) is
--
  l_proc     varchar2(72) := g_package||'write_warning';
--
  l_err_name   varchar2(2000) ;
begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
  if l_value is not null then
     if to_number(substr(p_err_name,5,5)) = 91870 then
        l_err_name := ben_ext_fmt.get_error_msg(to_number(substr(p_err_name,5,5)) ,p_err_name ) ;
        l_err_name := l_err_name || ' - '|| l_value ;
     end if ;

   end if ;
   if g_business_group_id is not null then
     ben_ext_util.write_err
      (p_err_num => to_number(substr(p_err_name,5,5)),
       p_err_name => l_err_name , --p_err_name,
       p_typ_cd => 'W',
       p_person_id => g_person_id,
       p_ext_rslt_id  => p_ext_rslt_id,
       p_business_group_id => g_business_group_id);
     commit;
   end if;
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
--
end write_warning;
-----------------------------------------------------------------------------

Procedure MAIN
          (errbuf            out nocopy varchar2,   --needed by concurrent manager.
           retcode           out nocopy number,     --needed by concurrent manager.
           p_ext_rslt_id     in number ,
           p_output_type     in varchar2 default null  ,
           p_out_dummy         in varchar2  default null,
           p_xdo_template_id in number  default null   ,
           p_source          in varchar2  default 'BENXWRIT'
          ) is
--
--
file_handle utl_file.file_type;
l_output_name ben_ext_rslt.output_name%type ;
l_drctry_name ben_ext_rslt.drctry_name%type ;
l_ext_stat_cd ben_ext_rslt.ext_stat_cd%type ;
-- hnarayan - bug fix 2066883 - changed size of l_val from 2000 to 32000
-- l_val varchar2(2000);
l_val varchar2(32700);
-- RCHASE wwbug 1412809 fix - added l_val_all
l_val_all varchar2(32700);
-- hnarayan - bug fix 2066883 - changed size of l_tmp from 2000 to 32000
-- l_tmp varchar2(2000);
l_tmp varchar2(32700);
l_length number;
l_accum_length number :=0 ;
job_failure exception;
l_dummy varchar2(1);
l_request_id number;
l_rcd_count number :=0;
l_just_cd ben_ext_data_elmt.just_cd%type ;
l_output_type  varchar2(30)  ;
l_xdo_template_id number     ;
l_cm_display_flag  varchar2(30)  ;
l_spcl_hndl_flag  ben_ext_dfn.spcl_hndl_flag%type ;
l_delimiter      ben_ext_data_elmt_in_rcd.DLMTR_VAL%type  ;
--
cursor c_xrs is
  select xrs.output_name,
         xrs.drctry_name,
         xrs.ext_stat_cd,
         xrs.business_group_id,
         xdf.spcl_hndl_flag,
         nvl(xrs.output_type, xdf.output_type ) output_type  ,
         xdf.cm_display_flag ,
         nvl(xrs.xdo_template_id, xdf.xdo_template_id) xdo_template_id
    from ben_ext_rslt xrs,
         ben_ext_dfn  xdf
   where xrs.ext_rslt_id = p_ext_rslt_id
     and xdf.ext_dfn_id  = xrs.ext_dfn_id;
--
cursor c_xrd is
  select xrd.ext_rcd_id,
         xrd.person_id,
         xrd.val_01,
         xrd.val_02,
         xrd.val_03,
         xrd.val_04,
         xrd.val_05,
         xrd.val_06,
         xrd.val_07,
         xrd.val_08,
         xrd.val_09,
         xrd.val_10,
         xrd.val_11,
         xrd.val_12,
         xrd.val_13,
         xrd.val_14,
         xrd.val_15,
         xrd.val_16,
         xrd.val_17,
         xrd.val_18,
         xrd.val_19,
         xrd.val_20,
         xrd.val_21,
         xrd.val_22,
         xrd.val_23,
         xrd.val_24,
         xrd.val_25,
         xrd.val_26,
         xrd.val_27,
         xrd.val_28,
         xrd.val_29,
         xrd.val_30,
         xrd.val_31,
         xrd.val_32,
         xrd.val_33,
         xrd.val_34,
         xrd.val_35,
         xrd.val_36,
         xrd.val_37,
         xrd.val_38,
         xrd.val_39,
         xrd.val_40,
         xrd.val_41,
         xrd.val_42,
         xrd.val_43,
         xrd.val_44,
         xrd.val_45,
         xrd.val_46,
         xrd.val_47,
         xrd.val_48,
         xrd.val_49,
         xrd.val_50,
         xrd.val_51,
         xrd.val_52,
         xrd.val_53,
         xrd.val_54,
         xrd.val_55,
         xrd.val_56,
         xrd.val_57,
         xrd.val_58,
         xrd.val_59,
         xrd.val_60,
         xrd.val_61,
         xrd.val_62,
         xrd.val_63,
         xrd.val_64,
         xrd.val_65,
         xrd.val_66,
         xrd.val_67,
         xrd.val_68,
         xrd.val_69,
         xrd.val_70,
         xrd.val_71,
         xrd.val_72,
         xrd.val_73,
         xrd.val_74,
         xrd.val_75,
         xrd.val_76,
         xrd.val_77,
         xrd.val_78,
         xrd.val_79,
         xrd.val_80,
         xrd.val_81,
         xrd.val_82,
         xrd.val_83,
         xrd.val_84,
         xrd.val_85,
         xrd.val_86,
         xrd.val_87,
         xrd.val_88,
         xrd.val_89,
         xrd.val_90,
         xrd.val_91,
         xrd.val_92,
         xrd.val_93,
         xrd.val_94,
         xrd.val_95,
         xrd.val_96,
         xrd.val_97,
         xrd.val_98,
         xrd.val_99,
         xrd.val_100,
         xrd.val_101,
         xrd.val_102,
         xrd.val_103,
         xrd.val_104,
         xrd.val_105,
         xrd.val_106,
         xrd.val_107,
         xrd.val_108,
         xrd.val_109,
         xrd.val_110,
         xrd.val_111,
         xrd.val_112,
         xrd.val_113,
         xrd.val_114,
         xrd.val_115,
         xrd.val_116,
         xrd.val_117,
         xrd.val_118,
         xrd.val_119,
         xrd.val_120,
         xrd.val_121,
         xrd.val_122,
         xrd.val_123,
         xrd.val_124,
         xrd.val_125,
         xrd.val_126,
         xrd.val_127,
         xrd.val_128,
         xrd.val_129,
         xrd.val_130,
         xrd.val_131,
         xrd.val_132,
         xrd.val_133,
         xrd.val_134,
         xrd.val_135,
         xrd.val_136,
         xrd.val_137,
         xrd.val_138,
         xrd.val_139,
         xrd.val_140,
         xrd.val_141,
         xrd.val_142,
         xrd.val_143,
         xrd.val_144,
         xrd.val_145,
         xrd.val_146,
         xrd.val_147,
         xrd.val_148,
         xrd.val_149,
         xrd.val_150,
         xrd.val_151,
         xrd.val_152,
         xrd.val_153,
         xrd.val_154,
         xrd.val_155,
         xrd.val_156,
         xrd.val_157,
         xrd.val_158,
         xrd.val_159,
         xrd.val_160,
         xrd.val_161,
         xrd.val_162,
         xrd.val_163,
         xrd.val_164,
         xrd.val_165,
         xrd.val_166,
         xrd.val_167,
         xrd.val_168,
         xrd.val_169,
         xrd.val_170,
         xrd.val_171,
         xrd.val_172,
         xrd.val_173,
         xrd.val_174,
         xrd.val_175,
         xrd.val_176,
         xrd.val_177,
         xrd.val_178,
         xrd.val_179,
         xrd.val_180,
         xrd.val_181,
         xrd.val_182,
         xrd.val_183,
         xrd.val_184,
         xrd.val_185,
         xrd.val_186,
         xrd.val_187,
         xrd.val_188,
         xrd.val_189,
         xrd.val_190,
         xrd.val_191,
         xrd.val_192,
         xrd.val_193,
         xrd.val_194,
         xrd.val_195,
         xrd.val_196,
         xrd.val_197,
         xrd.val_198,
         xrd.val_199,
         xrd.val_200,
         xrd.val_201,
         xrd.val_202,
         xrd.val_203,
         xrd.val_204,
         xrd.val_205,
         xrd.val_206,
         xrd.val_207,
         xrd.val_208,
         xrd.val_209,
         xrd.val_210,
         xrd.val_211,
         xrd.val_212,
         xrd.val_213,
         xrd.val_214,
         xrd.val_215,
         xrd.val_216,
         xrd.val_217,
         xrd.val_218,
         xrd.val_219,
         xrd.val_220,
         xrd.val_221,
         xrd.val_222,
         xrd.val_223,
         xrd.val_224,
         xrd.val_225,
         xrd.val_226,
         xrd.val_227,
         xrd.val_228,
         xrd.val_229,
         xrd.val_230,
         xrd.val_231,
         xrd.val_232,
         xrd.val_233,
         xrd.val_234,
         xrd.val_235,
         xrd.val_236,
         xrd.val_237,
         xrd.val_238,
         xrd.val_239,
         xrd.val_240,
         xrd.val_241,
         xrd.val_242,
         xrd.val_243,
         xrd.val_244,
         xrd.val_245,
         xrd.val_246,
         xrd.val_247,
         xrd.val_248,
         xrd.val_249,
         xrd.val_250,
         xrd.val_251,
         xrd.val_252,
         xrd.val_253,
         xrd.val_254,
         xrd.val_255,
         xrd.val_256,
         xrd.val_257,
         xrd.val_258,
         xrd.val_259,
         xrd.val_260,
         xrd.val_261,
         xrd.val_262,
         xrd.val_263,
         xrd.val_264,
         xrd.val_265,
         xrd.val_266,
         xrd.val_267,
         xrd.val_268,
         xrd.val_269,
         xrd.val_270,
         xrd.val_271,
         xrd.val_272,
         xrd.val_273,
         xrd.val_274,
         xrd.val_275,
         xrd.val_276,
         xrd.val_277,
         xrd.val_278,
         xrd.val_279,
         xrd.val_280,
         xrd.val_281,
         xrd.val_282,
         xrd.val_283,
         xrd.val_284,
         xrd.val_285,
         xrd.val_286,
         xrd.val_287,
         xrd.val_288,
         xrd.val_289,
         xrd.val_290,
         xrd.val_291,
         xrd.val_292,
         xrd.val_293,
         xrd.val_294,
         xrd.val_295,
         xrd.val_296,
         xrd.val_297,
         xrd.val_298,
         xrd.val_299,
         xrd.val_300,
        xrf.seq_num
 from   ben_ext_rslt_dtl xrd,
        ben_ext_rslt xrs,
        ben_ext_dfn xdf,
        ben_ext_rcd_in_file xrf
 where  xrd.ext_rslt_id = p_ext_rslt_id
 and  xrd.ext_rslt_id = xrs.ext_rslt_id
 and  xrs.ext_dfn_id = xdf.ext_dfn_id
 and  xdf.ext_file_id = xrf.ext_file_id
 and  xrd.ext_rcd_id = xrf.ext_rcd_id
 and (xrd.ext_rcd_in_file_id is null
      or xrd.ext_rcd_in_file_id = xrf.ext_rcd_in_file_id ) -- or condition taken care of previous results
 and  xrf.hide_flag = 'N'
 order by xrd.group_val_01,
          xrd.group_val_02,
          xrd.prmy_sort_val,
          xrd.scnd_sort_val,
          xrd.thrd_sort_val,
          xrf.seq_num ;  -- this is addedd  ther are  many time header may not sorted in order
--
cursor c_xrd1 is --this cursor is for validation only.
  select 'x'
  from   ben_ext_rslt_dtl xrd
  where xrd.ext_rslt_id = p_ext_rslt_id;
--
-- BUG - 3954449 ADDED UNION CLAUSE
--
/*
-- apps may not have acces gv$system_parameter2, create compilation error
cursor c_utl is
  select 'x'
  from gv$system_parameter
  where name = 'utl_file_dir'
  and value like ('%' || l_drctry_name || '%')
  union
  select 'x'
  from gv$system_parameter2
  where name = 'utl_file_dir'
  and value like ('%' || l_drctry_name || '%');
*/
--
  cursor c_xel_name(p_ext_rcd_id number  ,
                    p_seq_num  number) is
  select  xel.name
    from  ben_ext_data_elmt xel,
          ben_Ext_data_elmt_in_rcd xdr
    where xdr.ext_data_elmt_id = xel.ext_data_elmt_id
      and xdr.ext_rcd_id = p_ext_rcd_id
      and xdr.seq_num    = p_seq_num
   ;
   l_ext_data_elmt_name  ben_ext_data_elmt.name%type ;
   l_prev_seq_num        number ;


  cursor c_xdoi (c_xdo_id  number)  is
  select application_short_name ,
         template_code ,
         default_language,
         default_territory
  from xdo_templates_b
 where template_id = c_xdo_id  ;

 l_application_short_name  xdo_templates_b.application_short_name%type ;
 l_template_code           xdo_templates_b.template_code%type ;
 l_default_language        xdo_templates_b.default_language%type ;
 l_default_territory       xdo_templates_b.default_territory%type ;
 l_fnd_out                 boolean ;
 l_output_code             varchar2(25) ;

--
  l_proc     varchar2(72) := g_package||'main';
  l_max_ext_line_size  Number ;
  l_max_prf_value      Number ;
  -- l_defined            Boolean ;
  l_last_elmt_short_name ben_Ext_fld.short_name%type ;
  l_prev_elmt_short_name ben_Ext_fld.short_name%type ;
  l_prev_person_id    Number ;
--
begin
--
  hr_Utility.set_location('Entering'||l_proc, 5);
--
initialize_globals;

--
open c_xrs;
   fetch c_xrs into l_output_name
                   ,l_drctry_name
                   ,l_ext_stat_cd
                   ,g_business_group_id
                   ,l_spcl_hndl_flag
                   ,l_output_type
                   ,l_cm_display_flag
                   ,l_xdo_template_id
                   ;

   if c_xrs%notfound then
     close c_xrs;
     g_err_name := 'BEN_91873_EXT_NOT_FOUND';
     raise job_failure;
   end if;

close c_xrs;

--- validate the output type
if p_output_type is not null then
   l_output_type      := p_output_type ;
   l_xdo_template_id  := nvl(p_xdo_template_id, l_xdo_template_id ) ;

   if l_output_type in ('F', 'X') and l_xdo_template_id is not null then
       l_xdo_template_id := null ;
   end if ;

   if l_output_type not in ('F', 'X') and l_xdo_template_id is null and
      p_source  <>  'BENXMLWRIT'     then
      fnd_message.set_name('BEN','BEN_94036_EXT_XDO_PDF_NULL');
      fnd_message.raise_error;
   end if ;

end if ;

-- assign default to display flag
if l_cm_display_flag is null then
   l_cm_display_flag := 'N' ;
end if ;
--
open c_xrd1;
   fetch c_xrd1 into l_dummy;
   if c_xrd1%notfound then
     close c_xrd1;
     g_err_name := 'BEN_91872_EXT_NO_DTL_ERR';
     raise job_failure;
   end if;
close c_xrd1;
--
if l_ext_stat_cd not in ('A','S','E','W') then
  g_err_name := 'BEN_91875_EXT_INVLD_STAT';
  raise job_failure;
end if;
--
  hr_Utility.set_location('dir '||l_drctry_name, 5);
  /*
   -- 4143619 - Dont need this SQL for validating the directory
   -- if utl_file.fopen fails to find the directory, it will
   -- raise invalid path exception where this message will now be displayed.
    open c_utl;
    fetch c_utl into l_dummy;
    if c_utl%notfound then
      close c_utl;
      g_err_name := 'BEN_91874_EXT_DRCTRY_ERR';
      raise job_failure;
    end if;
  close c_utl;
 */
--
if l_output_name is null  and l_cm_display_flag <> 'Y'  then
     g_err_name := 'BEN_91871_EXT_OUTFILE_WARN'; --filename was not specified,
     raise job_failure;
end if;
--


---- if the disply is on   and the source is BENXWRIT and  xdo is not null  then
---- assume the ext writ proceess is executed by mistake
---  redirect the  extract xml write process

if  l_cm_display_flag = 'Y' and  p_source = 'BENXWRIT'  and p_xdo_template_id is not null then

    open  c_xdoi (l_xdo_template_id ) ;
    fetch c_xdoi  into
          l_application_short_name ,
          l_template_code ,
          l_default_language,
          l_default_territory ;
    close c_xdoi ;

   if l_output_type = 'H'  then
      l_output_code := 'HTML' ;
   elsif  l_output_type = 'R'  then
      l_output_code := 'RTF' ;
   elsif  l_output_type = 'P'  then
      l_output_code := 'PDF' ;
   elsif  l_output_type = 'E'  then
      l_output_code := 'EXCEL' ;
   else
      l_output_code := 'PDF' ;
   end if ;

    --- popilate the variable for post poroccing of cm - templates

    l_fnd_out := fnd_request.add_layout
                (template_appl_name => l_application_short_name,
                 template_code      => l_template_code,
                 template_language  => l_default_language,
                 template_territory => l_default_territory,
                 output_format      => l_output_code
                 ) ;

     --- call the concurrent manager with  XML output


     l_request_id := fnd_request.submit_request
             (application => 'BEN',
              program     => 'BENXMLWRIT',
              description => NULL,
              sub_request => FALSE,
              argument1   => p_ext_rslt_id,
              argument2   => l_output_type ,
              argument3   => null,
              argument4   => 'BENXMLWRIT'
         );

    return ;
end if ;



-- ----------------------------------------------------------------------------------------

--  Start - Bug : 2066883
--  Changed code to use value set at new profile created to store the max extract ine size
--

---- we can avoid this for  xml

if nvl(l_output_type,'F')  = 'F' then
   --
   -- Bug : 3776045
   -- Use FND_PROFILE.GET to get CACHED profile value.
   /*
   fnd_profile.get_specific( name_z              => 'BEN_MAX_EXT_LINE_SIZE'
   		            ,user_id_z           => fnd_global.user_id
   		            ,responsibility_id_z => fnd_global.resp_id
                            ,application_id_z    => fnd_global.resp_appl_id
                            ,val_z               => l_max_prf_value
                            ,defined_z           => l_defined );
   */
   fnd_profile.get( NAME => 'BEN_MAX_EXT_LINE_SIZE'
                   ,VAL  => l_max_prf_value );
   --
   -- Bug : 3776045
   --
   if (l_max_prf_value is null /*or l_defined = FALSE*/  ) then
       -- if max value is not set then set the max extract line size to 32767 .
       l_max_ext_line_size := 32767 ;
   elsif l_max_prf_value < 1 then
       l_max_ext_line_size :=  32767 ;
   else
       l_max_ext_line_size := l_max_prf_value ;
   end if ;



--
   if  l_cm_display_flag <> 'Y' then
       file_handle := utl_file.fopen (l_drctry_name,l_output_name,'w' , l_max_ext_line_size );
   end if ;
--
--  End - Bug : 2066883
--  ----------------------------------------------------------------------------------------
--
   for l_xrd in c_xrd loop
     --
     g_person_id := l_xrd.person_id;

     -- if the previous person if and current person_id is not same
     -- and previous rcord last element is continues then write the record
     -- and reintialise  the variable

    if g_person_id <> l_prev_person_id and  l_prev_elmt_short_name = 'RECLINKS' and  l_val_all is not null    then

       hr_utility.set_location(' writing last person Record ' || l_prev_person_id, 99 ) ;

       if nvl(l_spcl_hndl_flag,'x') = 'Y' and l_delimiter is not  null then
          if l_val_all is not null and  length(l_val_all) > 1  then
             l_val_all := rtrim(substr(l_val_all,1, (length(l_val_all)-1)),l_delimiter)
                         || substr(l_val_all,-1)  ;
             hr_utility.set_location('  triming  ' , 428 );
          end if ;

       end if ;
       if l_cm_display_flag  = 'Y' then
          fnd_file.put_line(FND_FILE.OUTPUT, l_val_all ) ;
       else
          utl_file.put_line(file_handle,l_val_all);
       end if ;
       l_accum_length := 0;
       l_val := '';
       l_val_all := '';
    end if ;
    --
    load_arrays
     (l_xrd.ext_rcd_id,
      l_xrd.val_01,
      l_xrd.val_02,
      l_xrd.val_03,
      l_xrd.val_04,
      l_xrd.val_05,
      l_xrd.val_06,
      l_xrd.val_07,
      l_xrd.val_08,
      l_xrd.val_09,
      l_xrd.val_10,
      l_xrd.val_11,
      l_xrd.val_12,
      l_xrd.val_13,
      l_xrd.val_14,
      l_xrd.val_15,
      l_xrd.val_16,
      l_xrd.val_17,
     l_xrd.val_18,
     l_xrd.val_19,
     l_xrd.val_20,
     l_xrd.val_21,
     l_xrd.val_22,
     l_xrd.val_23,
     l_xrd.val_24,
     l_xrd.val_25,
     l_xrd.val_26,
     l_xrd.val_27,
     l_xrd.val_28,
     l_xrd.val_29,
     l_xrd.val_30,
     l_xrd.val_31,
     l_xrd.val_32,
     l_xrd.val_33,
     l_xrd.val_34,
     l_xrd.val_35,
     l_xrd.val_36,
     l_xrd.val_37,
     l_xrd.val_38,
     l_xrd.val_39,
     l_xrd.val_40,
     l_xrd.val_41,
     l_xrd.val_42,
     l_xrd.val_43,
     l_xrd.val_44,
     l_xrd.val_45,
     l_xrd.val_46,
     l_xrd.val_47,
     l_xrd.val_48,
     l_xrd.val_49,
     l_xrd.val_50,
     l_xrd.val_51,
     l_xrd.val_52,
     l_xrd.val_53,
     l_xrd.val_54,
     l_xrd.val_55,
     l_xrd.val_56,
     l_xrd.val_57,
     l_xrd.val_58,
     l_xrd.val_59,
     l_xrd.val_60,
     l_xrd.val_61,
     l_xrd.val_62,
     l_xrd.val_63,
     l_xrd.val_64,
     l_xrd.val_65,
     l_xrd.val_66,
     l_xrd.val_67,
     l_xrd.val_68,
     l_xrd.val_69,
     l_xrd.val_70,
     l_xrd.val_71,
     l_xrd.val_72,
     l_xrd.val_73,
     l_xrd.val_74,
     l_xrd.val_75,
     l_xrd.val_76,
     l_xrd.val_77,
     l_xrd.val_78,
     l_xrd.val_79,
     l_xrd.val_80,
     l_xrd.val_81,
     l_xrd.val_82,
     l_xrd.val_83,
     l_xrd.val_84,
     l_xrd.val_85,
     l_xrd.val_86,
     l_xrd.val_87,
     l_xrd.val_88,
     l_xrd.val_89,
     l_xrd.val_90,
     l_xrd.val_91,
     l_xrd.val_92,
     l_xrd.val_93,
     l_xrd.val_94,
     l_xrd.val_95,
     l_xrd.val_96,
     l_xrd.val_97,
     l_xrd.val_98,
     l_xrd.val_99,
     l_xrd.val_100,
     l_xrd.val_101,
     l_xrd.val_102,
     l_xrd.val_103,
     l_xrd.val_104,
     l_xrd.val_105,
     l_xrd.val_106,
     l_xrd.val_107,
     l_xrd.val_108,
     l_xrd.val_109,
     l_xrd.val_110,
     l_xrd.val_111,
     l_xrd.val_112,
     l_xrd.val_113,
     l_xrd.val_114,
     l_xrd.val_115,
     l_xrd.val_116,
     l_xrd.val_117,
     l_xrd.val_118,
     l_xrd.val_119,
     l_xrd.val_120,
     l_xrd.val_121,
     l_xrd.val_122,
     l_xrd.val_123,
     l_xrd.val_124,
     l_xrd.val_125,
     l_xrd.val_126,
     l_xrd.val_127,
     l_xrd.val_128,
     l_xrd.val_129,
     l_xrd.val_130,
     l_xrd.val_131,
     l_xrd.val_132,
     l_xrd.val_133,
     l_xrd.val_134,
     l_xrd.val_135,
     l_xrd.val_136,
     l_xrd.val_137,
     l_xrd.val_138,
     l_xrd.val_139,
     l_xrd.val_140,
     l_xrd.val_141,
     l_xrd.val_142,
     l_xrd.val_143,
     l_xrd.val_144,
     l_xrd.val_145,
     l_xrd.val_146,
     l_xrd.val_147,
     l_xrd.val_148,
     l_xrd.val_149,
     l_xrd.val_150,
     l_xrd.val_151,
     l_xrd.val_152,
     l_xrd.val_153,
     l_xrd.val_154,
     l_xrd.val_155,
     l_xrd.val_156,
     l_xrd.val_157,
     l_xrd.val_158,
     l_xrd.val_159,
     l_xrd.val_160,
     l_xrd.val_161,
     l_xrd.val_162,
     l_xrd.val_163,
     l_xrd.val_164,
     l_xrd.val_165,
     l_xrd.val_166,
     l_xrd.val_167,
     l_xrd.val_168,
     l_xrd.val_169,
     l_xrd.val_170,
     l_xrd.val_171,
     l_xrd.val_172,
     l_xrd.val_173,
     l_xrd.val_174,
     l_xrd.val_175,
     l_xrd.val_176,
     l_xrd.val_177,
     l_xrd.val_178,
     l_xrd.val_179,
     l_xrd.val_180,
     l_xrd.val_181,
     l_xrd.val_182,
     l_xrd.val_183,
     l_xrd.val_184,
     l_xrd.val_185,
     l_xrd.val_186,
     l_xrd.val_187,
     l_xrd.val_188,
     l_xrd.val_189,
     l_xrd.val_190,
     l_xrd.val_191,
     l_xrd.val_192,
     l_xrd.val_193,
     l_xrd.val_194,
     l_xrd.val_195,
     l_xrd.val_196,
     l_xrd.val_197,
     l_xrd.val_198,
     l_xrd.val_199,
     l_xrd.val_200,
     l_xrd.val_201,
     l_xrd.val_202,
     l_xrd.val_203,
     l_xrd.val_204,
     l_xrd.val_205,
     l_xrd.val_206,
     l_xrd.val_207,
     l_xrd.val_208,
     l_xrd.val_209,
     l_xrd.val_210,
     l_xrd.val_211,
     l_xrd.val_212,
     l_xrd.val_213,
     l_xrd.val_214,
     l_xrd.val_215,
     l_xrd.val_216,
     l_xrd.val_217,
     l_xrd.val_218,
     l_xrd.val_219,
     l_xrd.val_220,
     l_xrd.val_221,
     l_xrd.val_222,
     l_xrd.val_223,
     l_xrd.val_224,
     l_xrd.val_225,
     l_xrd.val_226,
     l_xrd.val_227,
     l_xrd.val_228,
     l_xrd.val_229,
     l_xrd.val_230,
     l_xrd.val_231,
     l_xrd.val_232,
     l_xrd.val_233,
     l_xrd.val_234,
     l_xrd.val_235,
     l_xrd.val_236,
     l_xrd.val_237,
     l_xrd.val_238,
     l_xrd.val_239,
     l_xrd.val_240,
     l_xrd.val_241,
     l_xrd.val_242,
     l_xrd.val_243,
     l_xrd.val_244,
     l_xrd.val_245,
     l_xrd.val_246,
     l_xrd.val_247,
     l_xrd.val_248,
     l_xrd.val_249,
     l_xrd.val_250,
     l_xrd.val_251,
     l_xrd.val_252,
     l_xrd.val_253,
     l_xrd.val_254,
     l_xrd.val_255,
     l_xrd.val_256,
     l_xrd.val_257,
     l_xrd.val_258,
     l_xrd.val_259,
     l_xrd.val_260,
     l_xrd.val_261,
     l_xrd.val_262,
     l_xrd.val_263,
     l_xrd.val_264,
     l_xrd.val_265,
     l_xrd.val_266,
     l_xrd.val_267,
     l_xrd.val_268,
     l_xrd.val_269,
     l_xrd.val_270,
     l_xrd.val_271,
     l_xrd.val_272,
     l_xrd.val_273,
     l_xrd.val_274,
     l_xrd.val_275,
     l_xrd.val_276,
     l_xrd.val_277,
     l_xrd.val_278,
     l_xrd.val_279,
     l_xrd.val_280,
     l_xrd.val_281,
     l_xrd.val_282,
     l_xrd.val_283,
     l_xrd.val_284,
     l_xrd.val_285,
     l_xrd.val_286,
     l_xrd.val_287,
     l_xrd.val_288,
     l_xrd.val_289,
     l_xrd.val_290,
     l_xrd.val_291,
     l_xrd.val_292,
     l_xrd.val_293,
     l_xrd.val_294,
     l_xrd.val_295,
     l_xrd.val_296,
     l_xrd.val_297,
     l_xrd.val_298,
     l_xrd.val_299,
     l_xrd.val_300,
     l_xrd.seq_num);
     --
     l_delimiter := null ;
     l_last_elmt_short_name := null ;
     l_prev_seq_num         := null ;
     hr_utility.set_location( 'high seq ' || g_array(l_xrd.seq_num).highest_seq_num , 70) ;
     hr_utility.set_location( 'seq ' || l_xrd.seq_num, 70) ;

     for k in 1..g_array(l_xrd.seq_num).highest_seq_num loop
        --
        -- added condition for 4242821
        --
        if g_hide_flag(k) = 'N' then
           if l_val is not null and g_strt_pos(k) is not null then
              --
              hr_utility.set_location( ' before length ', 99);
              -- determine number of characters that need to be written.
              l_length := g_strt_pos(k) - 1 - l_accum_length;

              hr_utility.set_location( ' length ' || l_length , 99);
              hr_utility.set_location( ' length val ' || length(l_val) , 99);
              -- validate whether l_val length is more then the max line sixe
              -- if the size more then 32700 then the variable may error so validate
              if length(l_val) > l_max_ext_line_size then
                 raise  utl_file.invalid_maxlinesize  ;
              end if;

             -- add a warning when truncating data.
                if length(l_val) > l_length then

                    l_ext_data_elmt_name  := null ;
                    open c_xel_name (l_xrd.ext_rcd_id,l_prev_seq_num) ;
                    fetch c_xel_name into l_ext_data_elmt_name ;
                    close c_xel_name  ;
                    hr_utility.set_location( ' element  ' || l_ext_data_elmt_name || '  -  '|| l_prev_seq_num , 99);
                   write_warning('BEN_91870_EXT_TRUNC_WARN' , p_ext_rslt_id ,l_ext_data_elmt_name  );
                end if;
             -- if l_val exceeds l_length we must truncate.
                l_val := substr(l_val,1,l_length);
             -- if l_val falls short of l_length we must pad with blanks.
                if l_just_cd = 'R' then
                  l_val := lpad(l_val,l_length);
                else
                  l_val := rpad(l_val,l_length);
                end if;
             -- now write l_val.
             -- RCHASE wwbug 1412809 fix - Changed utl_file.put statement to varchar
             --                            assignment and moved to final put_line.

                -- when the lenght exceeds the max length then  throw the error with
                -- dont let the system erroes with ORA error
                hr_utility.set_location( ' length l_val_all ' ||  length(l_val_all||l_val) , 99);
                if  length(l_val_all||l_val) >  l_max_ext_line_size  then      -- variable defined to 32700
                    hr_utility.set_location( ' raise warning ' ||  length(l_val_all||l_val) , 99);
                    raise  utl_file.invalid_maxlinesize  ;
                end if ;

                l_val_all:=l_val_all||l_val;
                l_prev_seq_num  := k ;
                --utl_file.put(file_handle,l_val);
             -- RCHASE end
             -- add to length written accumlator.
                l_accum_length := l_accum_length +l_length;
             -- init l_val
                l_val := '';
             --
           end if;
           --
           -- if data element is hidden wipe it out.
           if g_hide_flag(k) = 'Y' then
              l_tmp := '';
           else

              l_tmp := g_val(k);
           end if;

           --  build the record.
           if  length(l_val || l_tmp || g_dlmtr_val(k)) >  l_max_ext_line_size  then      -- variable defined to 32700
                hr_utility.set_location( ' raise warning ' ||  length(l_val || l_tmp || g_dlmtr_val(k)) , 99);
               raise  utl_file.invalid_maxlinesize  ;
           end if ;

           l_val :=  l_val || l_tmp || g_dlmtr_val(k);
           -- store the justification code in buffer.
           l_just_cd := g_just_cd(k);
           -- handle null values such as fillers.
           if l_val is null then
             l_val := ' ';
           else
             if g_strt_pos(k) is not null then
                l_prev_seq_num  := k ;
             end if ;
           end if;
           -- this is variable use for ansi to  remove the last delimiters
           -- this is taken from the delimiter instead of hardcoding *
           -- so only first avaialble is taken to variable, the last one can not be taken that
           -- end of row delimiter. if user use different dlimiter for column that is against ansi
           if l_delimiter is null then
              l_delimiter := g_dlmtr_val(k) ;
           end if;
        end if ;
        --- continue
        l_last_elmt_short_name := nvl( g_short_name(k) , '-1') ;
      end loop;


      hr_utility.set_location( ' length l_val_all ' ||  length(l_val_all||l_val) , 99);
       -- when the lenght exceeds the max length then  throw the error with
       -- dont let the system erroes with ORA error
      if  length(l_val_all||l_val) >  l_max_ext_line_size  then      -- variable defined to 32700
            hr_utility.set_location( ' raise warning ' ||  length(l_val_all||l_val) , 99);
            raise  utl_file.invalid_maxlinesize  ;
      end if ;

      l_val_all := l_val_all||l_val ;


     --- whne the last element is 'RECLINKS' then  dont write to the file
     --  continue  with next record
     hr_utility.set_location(' last_elmt_short_name ' || l_last_elmt_short_name, 428 );
     if  l_last_elmt_short_name <>  'RECLINKS'  then
         -- when the last coulmns are null the delimiter appear in  record
         -- as per ansi std the last deliter should not apper without data in the column
         -- the reciord end with data then the endof record delimiter , there should not be
         -- column delimiter between end of record delimiter and data
         -- so -1 lenth of string is trimed for the dlimiter 3115428
         if nvl(l_spcl_hndl_flag,'x') = 'Y' and l_delimiter is not  null then
            if l_val_all is not null and  length(l_val_all) > 1  then
                l_val_all := rtrim(substr(l_val_all,1, (length(l_val_all)-1)),l_delimiter)
                         || substr(l_val_all,-1)  ;
                hr_utility.set_location('  triming  ' , 428 );
           end if ;

         end if ;
         --
         -- RCHASE wwbug 1412809 fix - altered put_line by adding l_val_all
         if l_cm_display_flag  = 'Y' then
            fnd_file.put_line(FND_FILE.OUTPUT, l_val_all ) ;
         else
            utl_file.put_line(file_handle,l_val_all);
         end if ;

         --utl_file.put_line(file_handle,l_val_all);
         l_accum_length := 0;
         --l_val := '';
         l_val_all := '';
      end if ;
      l_val := '';
      l_rcd_count := l_rcd_count + 1;
      -- to continue the record
      l_prev_person_id        := g_person_id  ;
      l_prev_elmt_short_name  := l_last_elmt_short_name ;
      --
  end loop;

  -- if the last person last records last element is relink , write the record
  if  l_last_elmt_short_name =   'RECLINKS'  then

        if nvl(l_spcl_hndl_flag,'x') = 'Y' and l_delimiter is not  null then
          if l_val_all is not null and  length(l_val_all) > 1  then
             l_val_all := rtrim(substr(l_val_all,1, (length(l_val_all)-1)),l_delimiter)
                         || substr(l_val_all,-1)  ;
             hr_utility.set_location('  triming  ' , 428 );
          end if ;
        end if ;
         if l_cm_display_flag  = 'Y' then
          fnd_file.put_line(FND_FILE.OUTPUT, l_val_all ) ;
       else
          utl_file.put_line(file_handle,l_val_all);
       end if ;
       --utl_file.put_line(file_handle,l_val_all);
  end if ;
  --
  if l_cm_display_flag  <>  'Y' then
     utl_file.fclose(file_handle);
  end if ;

Else   -- this is called for xml and pdf
   --- call the function to write the xml file
    ben_Ext_xml_write.main(p_output_name     => l_output_name,
                           p_drctry_name     => l_drctry_name,
                           p_ext_rslt_id     => p_ext_rslt_id,
                           p_rec_count       => l_rcd_count ,
                           p_output_type     => l_output_type,
                           p_cm_display_flag => nvl(l_cm_display_flag,'N'),
                           p_xdo_template_id => l_xdo_template_id  ,
                           p_source          => p_source ) ;


end if ;
--
-- now call the error report to report warnings etc.
        l_request_id := fnd_request.submit_request
        (application => 'BEN',
         program     => 'BENXERRO',
         description => NULL,
         sub_request => FALSE,
         argument1   => fnd_global.conc_request_id);
--
-- write to logfile a successful completion message
       fnd_message.set_name('BEN','BEN_91877_GENERAL_JOB_SUCCESS');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
--
-- write to logfile the record count
       fnd_message.set_name('BEN','BEN_91878_EXT_TTL_RCRDS');
       fnd_file.put_line(fnd_file.log, to_char(l_rcd_count)||' '||fnd_message.get || ' ' || l_drctry_name||'/'||l_output_name);
--
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
--
EXCEPTION
--
    WHEN job_failure THEN
       fnd_message.set_name('BEN',g_err_name);
       fnd_file.put_line(fnd_file.log, fnd_message.get);
        write_warning(g_err_name , p_ext_rslt_id );
       fnd_message.raise_error;
--
    WHEN utl_file.invalid_path then
        fnd_message.set_name('BEN', 'BEN_91874_EXT_DRCTRY_ERR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        write_warning('BEN_91874_EXT_DRCTRY_ERR' , p_ext_rslt_id );
        fnd_message.raise_error;
--
    WHEN utl_file.invalid_mode then
        fnd_message.set_name('BEN', 'BEN_92249_UTL_INVLD_MODE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        write_warning('BEN_92249_UTL_INVLD_MODE' , p_ext_rslt_id );
        fnd_message.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        fnd_message.set_name('BEN', 'BEN_92250_UTL_INVLD_FILEHANDLE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        write_warning('BEN_92250_UTL_INVLD_FILEHANDLE' , p_ext_rslt_id );
        fnd_message.raise_error;
--
    WHEN utl_file.invalid_operation then
        fnd_message.set_name('BEN', 'BEN_92251_UTL_INVLD_OPER');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        write_warning('BEN_92251_UTL_INVLD_OPER' , p_ext_rslt_id );
        fnd_message.raise_error;
--
    WHEN utl_file.read_error then
        fnd_message.set_name('BEN', 'BEN_92252_UTL_READ_ERROR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        write_warning('BEN_92252_UTL_READ_ERROR' , p_ext_rslt_id );
        fnd_message.raise_error;
--
    WHEN utl_file.internal_error then
        fnd_message.set_name('BEN', 'BEN_92253_UTL_INTRNL_ERROR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        write_warning('BEN_92253_UTL_INTRNL_ERROR' , p_ext_rslt_id );
        fnd_message.raise_error;
--
--  -----------------------------------------------------------------------
--  Start - Bug : 2066883
    WHEN utl_file.invalid_maxlinesize  then
        fnd_message.set_name ('BEN' ,'BEN_92492_UTL_LINESIZE_ERROR');
        fnd_file.put_line(fnd_file.log , fnd_message.get );
        write_warning('BEN_92492_UTL_LINESIZE_ERROR' , p_ext_rslt_id );
        fnd_message.raise_error ;
--  End - Bug : 2066883
-- -----------------------------------------------------------------------

    WHEN others THEN
       hr_utility.set_location ( ' other excep ' || substr(sqlerrm,1,70)  , 99 ) ;
       fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
       fnd_message.set_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_message.raise_error;
--
END main;
--
END; --package

/
