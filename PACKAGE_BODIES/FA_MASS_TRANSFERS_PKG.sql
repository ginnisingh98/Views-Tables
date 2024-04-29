--------------------------------------------------------
--  DDL for Package Body FA_MASS_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_TRANSFERS_PKG" AS
/* $Header: FAXMTFRB.pls 120.5.12010000.2 2009/07/19 14:07:00 glchen ship $ */


/** The following describes what this function expects as parameters
    x_mass_transfer_id  valid mass transfer id
    x_from_glccid  valid expense account
    x_to_glccid    null or -99 **/

function famtgcc ( x_mass_transfer_id in     number,
                   x_from_glccid      in     number,
                   x_to_glccid        in out nocopy number , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   v_chart_of_accounts_id    number(15);
   v_nsegs                   number;
   v_to_conc_segs            varchar2(2000) := null;
   v_delimiter               varchar2(1);
   v_message                 varchar2(512);

   v_to_segarray             FND_FLEX_EXT.SEGMENTARRAY;
   v_from_segarray           FND_FLEX_EXT.SEGMENTARRAY;

   flex_error EXCEPTION;
   comb_error EXCEPTION;

   CURSOR c_mtfr is
   select book_type_code,
          to_gl_ccid,
          segment1,
          segment2,
          segment3,
          segment4,
          segment5,
          segment6,
          segment7,
          segment8,
          segment9,
          segment10,
          segment11,
          segment12,
          segment13,
          segment14,
          segment15,
          segment16,
          segment17,
          segment18,
          segment19,
          segment20,
          segment21,
          segment22,
          segment23,
          segment24,
          segment25,
          segment26,
          segment27,
          segment28,
          segment29,
          segment30
     from fa_mass_transfers
    where mass_transfer_id = x_mass_transfer_id;

    mtfr_rec c_mtfr%ROWTYPE := null;


    CURSOR C_glcc IS
    select nvl(glcc.code_combination_id, -99)
    from gl_code_combinations glcc,
         ( select * from gl_code_combinations
                   where code_combination_id = x_from_glccid ) from_glcc
    where  glcc.segment1 = nvl(mtfr_rec.segment1, from_glcc.segment1)
    and   glcc.segment2 = nvl(mtfr_rec.segment2, from_glcc.segment2)
    and   glcc.segment3 = nvl(mtfr_rec.segment3, from_glcc.segment3)
    and   glcc.segment4 = nvl(mtfr_rec.segment4, from_glcc.segment4)
    and   glcc.segment5 = nvl(mtfr_rec.segment5, from_glcc.segment5)
    and   glcc.segment6 = nvl(mtfr_rec.segment6, from_glcc.segment6)
    and   glcc.segment7 = nvl(mtfr_rec.segment7, from_glcc.segment7)
    and   glcc.segment8 = nvl(mtfr_rec.segment8, from_glcc.segment8)
    and   glcc.segment9 = nvl(mtfr_rec.segment9, from_glcc.segment9)
    and   glcc.segment10 = nvl(mtfr_rec.segment10, from_glcc.segment10)
    and   glcc.segment11 = nvl(mtfr_rec.segment11, from_glcc.segment11)
    and   glcc.segment12 = nvl(mtfr_rec.segment12, from_glcc.segment12)
    and   glcc.segment13 = nvl(mtfr_rec.segment13, from_glcc.segment13)
    and   glcc.segment14 = nvl(mtfr_rec.segment14, from_glcc.segment14)
    and   glcc.segment15 = nvl(mtfr_rec.segment15, from_glcc.segment15)
    and   glcc.segment16 = nvl(mtfr_rec.segment16, from_glcc.segment16)
    and   glcc.segment17 = nvl(mtfr_rec.segment17, from_glcc.segment17)
    and   glcc.segment18 = nvl(mtfr_rec.segment18, from_glcc.segment18)
    and   glcc.segment19 = nvl(mtfr_rec.segment19, from_glcc.segment19)
    and   glcc.segment20 = nvl(mtfr_rec.segment20, from_glcc.segment20)
    and   glcc.segment21 = nvl(mtfr_rec.segment21, from_glcc.segment21)
    and   glcc.segment22 = nvl(mtfr_rec.segment22, from_glcc.segment22)
    and   glcc.segment23 = nvl(mtfr_rec.segment23, from_glcc.segment23)
    and   glcc.segment24 = nvl(mtfr_rec.segment24, from_glcc.segment24)
    and   glcc.segment25 = nvl(mtfr_rec.segment25, from_glcc.segment25)
    and   glcc.segment26 = nvl(mtfr_rec.segment26, from_glcc.segment26)
    and   glcc.segment27 = nvl(mtfr_rec.segment27, from_glcc.segment27)
    and   glcc.segment28 = nvl(mtfr_rec.segment28, from_glcc.segment28)
    and   glcc.segment29 = nvl(mtfr_rec.segment29, from_glcc.segment29)
    and   glcc.segment30 = nvl(mtfr_rec.segment30, from_glcc.segment30)
    and glcc.chart_of_accounts_id = v_chart_of_accounts_id ;

  BEGIN

     -- initialize
     mtfr_rec := null;

     OPEN c_mtfr;
     FETCH C_mtfr INTO mtfr_rec;
     CLOSE c_mtfr;

     if mtfr_rec.to_gl_ccid is null then

        if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('FA_MASS_TRANSFERS.famtgcc','to_gl_ccid ','null', p_log_level_rec => p_log_level_rec);
        end if;


        --  Get Chart of Accounts ID
        Select sob.chart_of_accounts_id
        Into   v_chart_of_accounts_id
        From   fa_book_controls bc,
               gl_sets_of_books sob
        Where  sob.set_of_books_id = bc.set_of_books_id
        And    bc.book_type_code  = mtfr_rec.book_type_code;


        OPEN c_glcc;
        FETCH c_glcc into x_to_glccid;
        CLOSE c_glcc;

        -- x_to_glccid := -99;
        if x_to_glccid = -99 then

           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add('FA_MASS_TRANSFERS.famtgcc','x_to_glccid','null', p_log_level_rec => p_log_level_rec);
           end if;


           -- the ccid does not exist and so needs to be created

           -- initialize segment array
           v_from_segarray.delete;

           if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('FA_MASS_TRANSFERS.famtgcc','calling','FND_FLEX_EXT.GET_SEGMENTS', p_log_level_rec => p_log_level_rec);
           end if;

           -- Get from_glccid segment array in the displayed order
           IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                application_short_name => 'SQLGL',
                                key_flex_code          => 'GL#',
                                structure_number       => v_chart_of_accounts_id,
                                combination_id         => x_from_glccid,
                                n_segments             => v_nsegs,
                                segments               => v_from_segarray)) THEN
                raise flex_error;
           END IF;

           if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('FA_MASS_TRANSFERS.famtgcc','calling',' get_segarray ', p_log_level_rec => p_log_level_rec);
           end if;

           -- Prepare segment array for To_gl_ccid
           if NOT get_segarray ( x_mass_transfer_id => x_mass_transfer_id,
                                 x_structure_number => v_chart_of_accounts_id,
                                 x_delimiter        => v_delimiter,
                                 x_nsegments        => v_nsegs,
                                 x_seg_array        => v_to_segarray,
                                 p_log_level_rec    => p_log_level_rec ) then
              raise flex_error;
           end if;

           -- replace missing segments of to_array with those of from_array
           -- this will be then used to generate the new ccid

           for i in 1..v_nsegs Loop
              if v_to_segarray(i) is null then
                 v_to_segarray(i) := v_from_segarray(i);
              end if;
           end loop;


           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add('FA_MASS_TRANSFERS.famtgcc','calling','FND_FLEX_EXT.GET_COMBINATION_ID', p_log_level_rec => p_log_level_rec);
           end if;

           -- Updating array with new account value
           IF (NOT FND_FLEX_EXT.GET_COMBINATION_ID( 'SQLGL',
                                                    'GL#',
                                                     v_chart_of_accounts_id,
                                                     SYSDATE,
                                                     v_nsegs,
                                                     v_to_segarray,
                                                     x_to_glccid)) THEN
              raise comb_error;
           END IF;
         end if;  /* if x_gl_ccid = -99 */

      else
         x_to_glccid := mtfr_rec.to_gl_ccid;
      end if;

      return (TRUE);

EXCEPTION
   when flex_error THEN

        v_message := FND_FLEX_EXT.GET_ENCODED_MESSAGE;
        fnd_msg_pub.add;

        FA_SRVR_MSG.add_message(CALLING_FN => 'FA_MASS_TRANSFERS_PKG.famtgcc', p_log_level_rec => p_log_level_rec);

        RETURN (FALSE);

   when comb_error then

        v_message := FND_FLEX_EXT.GET_ENCODED_MESSAGE;
        fnd_msg_pub.add;

        for i in 1..v_to_segarray.count loop
           if (i = 1) then
              v_to_conc_segs := v_to_segarray(i);
           else
              v_to_conc_segs := v_to_conc_segs || v_delimiter || v_to_segarray(i);
           end if;
        end loop;

        FA_SRVR_MSG.ADD_MESSAGE(
                     CALLING_FN=>'FA_MASS_TRANSFERS.famtgcc',
                     NAME=>'FA_FLEXBUILDER_FAIL_CCID',
                     TOKEN1 => 'ACCOUNT_TYPE',
                     VALUE1 => 'DEPRN_EXP',
                     TOKEN2 => 'BOOK_TYPE_CODE',
                     VALUE2 => mtfr_rec.book_type_code,
                     TOKEN3 => 'DIST_ID',
                     VALUE3 => 'NEW',
                     TOKEN4 => 'CONCAT_SEGS',
                     VALUE4 => v_to_conc_segs
                     , p_log_level_rec => p_log_level_rec);

        RETURN (FALSE);

   when others then

        FA_SRVR_MSG.ADD_SQL_ERROR (
                  CALLING_FN => 'FA_MASS_TRANSFERS.famtgcc', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);

END ;


/* This function is used by get_conc_segments and
   Mass Transfers Report FAS811.rdf. It returns
   delimiter, no of segments, and segments is the
   display order in a segment array */

FUNCTION get_segarray(  x_mass_transfer_id in number,
                        x_structure_number in number,
                        x_delimiter        in out nocopy varchar2,
                        x_nsegments        in out nocopy number,
                        x_seg_array        in out nocopy fnd_flex_ext.segmentarray , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

v_nsegs           number:= null;
v_seg_list        fnd_flex_key_api.segment_list;
v_flex_type       fnd_flex_key_api.flexfield_type;
v_struct_type     fnd_flex_key_api.structure_type;
v_seg             fnd_flex_key_api.segment_type;
-- v_seg_array       fnd_flex_ext.segmentarray;

TYPE my_rec_type IS RECORD
   (colname    varchar2(30),
    colvalue   varchar2(150));

TYPE my_arr_type IS TABLE OF my_rec_type INDEX BY BINARY_INTEGER;
myseg_array my_arr_type;

Cursor C_mtfr is
      select segment1, segment2, segment3, segment4, segment5,
             segment6, segment7, segment8, segment9, segment10,
             segment11, segment12, segment13, segment14, segment15,
             segment16, segment17, segment18, segment19, segment20,
             segment21, segment22, segment23, segment24, segment25,
             segment26, segment27, segment28, segment29, segment30
      from fa_mass_transfers
      where mass_transfer_id = x_mass_transfer_id;

    mtfr_rec c_mtfr%ROWTYPE := null;
BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('FA_MASS_TRANSFERS.get_segarray','calling','fnd_flex_ext.get_delimiter', p_log_level_rec => p_log_level_rec);
   end if;

   x_delimiter := fnd_flex_ext.get_delimiter(
                               application_short_name => 'SQLGL'
                             , key_flex_code          =>  'GL#'
                             , structure_number       =>  x_structure_number );

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('FA_MASS_TRANSFERS.get_segarray','calling','fnd_flex_key_api.set_session_mode', p_log_level_rec => p_log_level_rec);
   end if;


   fnd_flex_key_api.set_session_mode('customer_data');


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('FA_MASS_TRANSFERS.get_segarray','calling','fnd_flex_key_api.find_flexfield', p_log_level_rec => p_log_level_rec);
   end if;

   v_flex_type := fnd_flex_key_api.find_flexfield(
                                   appl_short_name => 'SQLGL',
                                   flex_code       => 'GL#' );

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('FA_MASS_TRANSFERS.get_segarray','calling','fnd_flex_key_api.find_structure', p_log_level_rec => p_log_level_rec);
   end if;


   v_struct_type := fnd_flex_key_api.find_structure(
                                     flexfield        => v_flex_type,
                                     structure_number => x_structure_number );

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('FA_MASS_TRANSFERS.get_segarray','calling','fnd_flex_key_api.get_segments', p_log_level_rec => p_log_level_rec);
   end if;


   fnd_flex_key_api.get_segments( flexfield => v_flex_type,
                                  structure => v_struct_type,
                                  --enabled_only  => enabled_flag,
                                  nsegments => x_nsegments,
                                  segments  => v_seg_list );

   -- initialize
   mtfr_rec := null;

   OPEN c_mtfr;
   FETCH C_mtfr INTO mtfr_rec;
   CLOSE c_mtfr;

   for i in 1..30 Loop

        myseg_array(i).colname := 'SEGMENT'||i;
        if i= 1 then
         myseg_array(i).colvalue := mtfr_rec.segment1;
        elsif i= 2 then
          myseg_array(i).colvalue := mtfr_rec.segment2;
        elsif i= 3 then
          myseg_array(i).colvalue := mtfr_rec.segment3;
        elsif i= 4 then
          myseg_array(i).colvalue := mtfr_rec.segment4;
        elsif i= 5 then
          myseg_array(i).colvalue := mtfr_rec.segment5;
        elsif i= 6 then
          myseg_array(i).colvalue := mtfr_rec.segment6;
        elsif i= 7 then
          myseg_array(i).colvalue := mtfr_rec.segment7;
        elsif i= 8 then
          myseg_array(i).colvalue := mtfr_rec.segment8;
        elsif i= 9 then
          myseg_array(i).colvalue := mtfr_rec.segment9;
        elsif i= 10 then
          myseg_array(i).colvalue := mtfr_rec.segment10;
        elsif i= 11 then
         myseg_array(i).colvalue := mtfr_rec.segment11;
        elsif i= 12 then
          myseg_array(i).colvalue := mtfr_rec.segment12;
        elsif i= 13 then
          myseg_array(i).colvalue := mtfr_rec.segment13;
        elsif i= 14 then
          myseg_array(i).colvalue := mtfr_rec.segment14;
        elsif i= 15 then
          myseg_array(i).colvalue := mtfr_rec.segment15;
        elsif i= 16 then
          myseg_array(i).colvalue := mtfr_rec.segment16;
        elsif i= 17 then
          myseg_array(i).colvalue := mtfr_rec.segment17;
        elsif i= 18 then
          myseg_array(i).colvalue := mtfr_rec.segment18;
        elsif i= 19 then
          myseg_array(i).colvalue := mtfr_rec.segment19;
        elsif i= 20 then
          myseg_array(i).colvalue := mtfr_rec.segment20;
        end if;
   end loop;

   --
   -- The segments in the seg_list array are sorted in display order.
   -- i.e. sorted by segment number.
   --
   for i in 1..x_nsegments loop
     v_seg := fnd_flex_key_api.find_segment(v_flex_type, v_struct_type, v_seg_list(i));

      for j in 1..myseg_array.count loop

          if (v_seg.column_name = myseg_array(j).colname) then
                 x_seg_array(i) := myseg_array(j).colvalue;
          end if;
      end loop;
   end loop;

   return TRUE;

exception
  when others then
       FA_SRVR_MSG.ADD_SQL_ERROR (
                   CALLING_FN => 'FA_MASS_TRANSFERS.get_segarray', p_log_level_rec => p_log_level_rec);
       RETURN (FALSE);

END get_segarray;


/* This function is called from Mass Transfers
   form ( FAXMAMTF.fmb ). It returns delimiter,
   no of segments, and segment is the display
   order in a segment array */

FUNCTION get_conc_segments( x_mass_transfer_id in number,
                            x_structure_number in number,
                            x_delimiter        in out nocopy varchar2,
                            x_nsegments        in out nocopy number,
                            x_concat_segments  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

v_seg_array fnd_flex_ext.segmentarray;

BEGIN


   if NOT get_segarray ( x_mass_transfer_id => x_mass_transfer_id,
                         x_structure_number => x_structure_number,
                         x_delimiter        => x_delimiter,
                         x_nsegments        => x_nsegments,
                         x_seg_array        => v_seg_array,
                         p_log_level_rec    => p_log_level_rec ) then
                    return FALSE;
   end if;

   --
   -- Now we have the all segment values in correct order in segarray.
   --

   x_concat_segments := fnd_flex_ext.concatenate_segments(
                                     x_nsegments,
                                     v_seg_array,
                                     x_delimiter);

   return TRUE;
exception
  when others then
       FA_SRVR_MSG.ADD_SQL_ERROR (
                   CALLING_FN => 'FA_MASS_TRANSFERS.get_conc_segments', p_log_level_rec => p_log_level_rec);
       RETURN (FALSE);

END get_conc_segments;


END FA_MASS_TRANSFERS_PKG;

/
