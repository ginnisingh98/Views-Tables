--------------------------------------------------------
--  DDL for Package FA_MASS_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_TRANSFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXMTFRS.pls 120.3.12010000.2 2009/07/19 11:23:41 glchen ship $ */

-- ---------------------------------------------------------------
-- Called from Mass transfer Pro*C process
-- Takes in Mass transfer ID, GL_ccid for the From Expense Account
-- Spits out the New GL_ccid for the To Expense Account
-- ---------------------------------------------------------------
function famtgcc ( x_mass_transfer_id in number,
                   x_from_glccid in     number,
                   x_to_glccid   in out nocopy number , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

-- --------------------------------------------------------------
-- Called from Form FAXMAMTF
--
-- --------------------------------------------------------------
/* obseleted - see bug2762973
PROCEDURE get_nsegments ( x_structure_number  in number,
                         x_delimiter      in out nocopy varchar2,
                         x_nsegments      in out nocopy number,
                         x_error_code     in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
*/

/* Added - see bug2762973 */

/* This function is called from Mass Transfers
   form ( FAXMAMTF.fmb ). It returns delimiter,
   no of segments, and segment is the display
   order in a segment array */
FUNCTION get_conc_segments( x_mass_transfer_id in number,
                            x_structure_number in number,
                            x_delimiter        in out nocopy varchar2,
                            x_nsegments        in out nocopy number,
                            x_concat_segments  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN ;


/* This function is used by get_conc_segments and
   Mass Transfers Report FAS811.rdf. It returns
   delimiter, no of segments, and segments is the
   display order in a segment array */
FUNCTION get_segarray(  x_mass_transfer_id in number,
                        x_structure_number in number,
                        x_delimiter        in out nocopy varchar2,
                        x_nsegments        in out nocopy number,
                        x_seg_array        in out nocopy fnd_flex_ext.segmentarray , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN ;

END FA_MASS_TRANSFERS_PKG;

/
