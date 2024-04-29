--------------------------------------------------------
--  DDL for Package HXC_TRANS_DISPLAY_KEY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TRANS_DISPLAY_KEY_UTILS" AUTHID CURRENT_USER AS
/* $Header: hxctdkut.pkh 120.2 2007/12/14 06:52:04 bbayragi noship $ */
--
-- This type is used to store whether a row index is used when retrieving
-- a timecard for use in the middle tier.  Usually it is indexed by
-- the row index, and is given value 1 if the row is used., 0 otherwise.
-- i.e.
-- Index   Value
--     1       1
--     2       <Index does not exist>
--     3       1
--
-- Would indicate that for this particular timecard, rows 1 and 3 are used
-- for this particular timecard, but that no details appeared on row 2
-- according to the display translation key.  I.e. action must be taken
-- to ensure the timecard appears properly.
--
   TYPE translation_row_used is table of pls_integer index by binary_integer;
--
-- This constant is used to specify the token between the components of the
-- the translation display key.
--
   c_key_separator CONSTANT varchar2(1) := '|';
--
-- ----------------------------------------------------------------------------
-- |------------------------<     missing_rows     >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns true if there are any missing rows as
--   specified by the display translation key - i.e. if the index
--   is not sequential.
--
-- Prerequisites:
--   The function must be passed a valid translation row used object
--   which can be empty.  The object, if containing data, must start
--   the rows at index 1, not 0.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_row_data                        N varchar2 Row data object, as built
--                                                when retrieving the
--                                                timecard.
--
-- Post Success:
--   True is there are gaps in the row data index, i.e. there are missing rows
--   false otherwise.  If the row data structure is empty, false is returned.
--
-- Post Failure:
--   This function can not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   FUNCTION missing_rows
      (p_row_data in translation_row_used)
      return boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------<     new_display_key     >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used when appending a template.  If the template has two
--   rows with translation display row indices 1 and 2, and the timecard
--   already has rows 1 and 2 used, then the appended detail blocks can not
--   be placed on rows 1 and 2.  Instead, the row index of the appended
--   is incremented by the number of rows in the timecard, becoming
--   3 and 4 in the example above.  So this function returns a display key
--   with the row index incremented by the number of rows specified.
--
-- Prerequisites:
--   The function should be sent a valid translation display key, and a valid
--   number of rows.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_existing_display_key            Y varchar2 Display key e.g. from
--                                                template.
--   p_existing_row_count              Y number   The number of rows to
--                                                increment the row
--                                                index in the display key
--
-- Post Success:
--   The new display key is constructed.
--
-- Post Failure:
--   An invalid display key will be returned, and the detail building block
--   will not appear on the self service timecard screen.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   FUNCTION new_display_key
             (p_existing_display_key in varchar2,
              p_existing_row_count in number)
    return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------<     remove_empty_rows     >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function removes any empty rows, as defined by the translation
--   display keys on the detail building blocks, by adjusting the display
--   keys for details that appear after an empty row such that they all
--   shuffle up the matrix to fill in the empty rows.
--
-- Prerequisites:
--   The row data object must be valid, and have been set properly by
--   the set_row_data procedure in this package, as the detail building
--   blocks have been retrieved from the database.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_row_data                        Y varchar2 Row data object, as built
--                                                when retrieving the
--                                                timecard.
--   p_blocks                          Y BLOCKS   The timecard blocks
--
-- Post Success:
--   The new display keys replace the old ones and there are no empty rows
--   in the timecard display key structure.
--
-- Post Failure:
--   If an invalid row data object is specified, then the display key
--   on the detail building blocks may be corrupted.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   PROCEDURE remove_empty_rows
      (p_row_data in            translation_row_used,
       p_blocks   in out NOCOPY hxc_block_table_type);
--
-- +--------------------------------------------------------------------------+
-- |-------------------<     reset_column_index_to_zero     >-----------------|
-- +--------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This function takes a translation display key and changes the column
--   index to zero, namely, xxxx|r|c, is transformed to xxxx|r|0.  This is
--   used by the zero hours template functionality.
--
-- Prerequisites:
--   A vaild translation display key.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_key                             Y varchar2 A tranlsation display key
--
-- Post Success:
--   The new display key, with a column index of zero is returned.
--
-- Post Failure:
--   Return value is undefined if sent an invalid translation display key.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   FUNCTION reset_column_index_to_zero
      (p_key in varchar2)
      return varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------<     set_row_data     >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function maintains the row data for a timecard, while the its
--   corresponding detail building blocks are being retrieved.  If the
--   passed display translation key contains a valid row index, and the
--   row data object does not yet contain that index, it is created.
--
-- Prerequisites:
--   The function should be passed a valid translation display key, of the
--   form defined above.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_key                             Y varchar2 Translation display key
--   p_row_data                        Y varchar2 Row data object, as built
--                                                when retrieving the
--                                                timecard.
--
-- Post Success:
--   The row data (row use) structure is updated appropriately.
--
-- Post Failure:
--   This function can not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   PROCEDURE set_row_data
      (p_key      in     varchar2,
       p_row_data in out NOCOPY translation_row_used);
--
-- ----------------------------------------------------------------------------
-- |---------------------<     timecard_row_count     >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function counts the number of rows used in a timecard, based on the
--   translation display keys.  I.e. this function will return the number of
--   rows used by the self service timecard matrix when displaying this
--   timecard.  This function is typically called when applying a template
--   to a timecard in append mode, and the template detail block translation
--   keys must be adjusted.
--
-- Prerequisites:
--   The function should be sent a valid timecard block table type.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_blocks                          Y BLOCKS   Usual timecard block table
--
-- Post Success:
--   The number of rows, as specified by the translation display key in
--   structure, 0 if no rows or unable to determine the number of rows.
--
-- Post Failure:
--   This procedure can not fail.  If the translation display key is
--   invalid, it will not be counted to the row count.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   FUNCTION timecard_row_count
              (p_blocks in hxc_block_table_type)
    return NUMBER;

-- Added for DA Enhancement
-- +--------------------------------------------------------------------------+
-- |---------------------<     alter_translation_key     >-----------------------|
-- +--------------------------------------------------------------------------+
--

 PROCEDURE alter_translation_key
   	    (p_g_deposit_blocks in out nocopy hxc_block_table_type,
   	     p_actual_blocks in hxc_block_table_type
   	    );


END hxc_trans_display_key_utils;

/
