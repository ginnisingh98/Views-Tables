--------------------------------------------------------
--  DDL for Package FA_RX_SHARED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_SHARED_PKG" AUTHID CURRENT_USER as
/* $Header: farxs.pls 120.7.12010000.4 2009/10/30 11:33:36 pmadas ship $ */


TYPE Seg_Array IS TABLE OF VARCHAR2(30)
        INDEX BY BINARY_INTEGER;

type varchar2table  is  table of varchar2(50)
        index by binary_integer;
type smallvarchar2table is table of varchar2(1)
        index by binary_integer;
type largevarchar2table is table of varchar2(250)
        index by binary_integer;
type numbertable    is  table of number
        index by binary_integer;




PROCEDURE GET_ACCT_SEGMENT_NUMBERS (
   BOOK                         IN      VARCHAR2,
   BALANCING_SEGNUM      OUT NOCOPY NUMBER,
   ACCOUNT_SEGNUM        OUT NOCOPY NUMBER,
   CC_SEGNUM             OUT NOCOPY NUMBER,
   CALLING_FN                   IN      VARCHAR2);

PROCEDURE GET_ACCT_SEGMENT_INDEX (                      /* StatReq */
   BOOK                         IN      VARCHAR2,
   BALANCING_SEGNUM             OUT NOCOPY     NUMBER,
   ACCOUNT_SEGNUM               OUT NOCOPY     NUMBER,
   CC_SEGNUM                    OUT NOCOPY     NUMBER,
   CALLING_FN                   IN      VARCHAR2);

PROCEDURE GET_ACCT_SEGMENTS (
   combination_id               IN      NUMBER,
   n_segments                   IN OUT NOCOPY NUMBER,
   segments                     IN OUT NOCOPY  Seg_Array,
   CALLING_FN                   IN      VARCHAR2);

procedure fadolif (
   life                 in   number default null,
   adj_rate             in   number default null,
   bonus_rate           in   number default null,
   prod                 in   number default null,
   retval        out nocopy  varchar2);


procedure fa_rsvldg (
   book                 in  varchar2,
   period               in  varchar2,
   report_style         in  varchar2 default 'S',
   sob_id               in  number default NULL,   -- MRC: Set of books id
   errbuf        out nocopy varchar2,
   retcode       out nocopy number);


procedure concat_general (
   table_id             in      number,
   table_name           in      varchar2,
   ccid_col_name        in      varchar2,
   struct_id            in      number,
   flex_code            in      varchar2,
   ccid                 in      number,
   appl_id              in      number,
   appl_short_name      in      varchar2,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy  Seg_Array);



procedure concat_category (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy Seg_Array);


procedure concat_location (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy  Seg_Array);


procedure concat_asset_key (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy  Seg_Array);


procedure concat_acct (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy  Seg_Array);



procedure get_request_info (
        userid                in  number,
        prog_name_template    in  varchar2,
        max_requests          in  number,
        dateform              in  varchar2,
        applid                in  number,
        user_conc_prog_names  out nocopy largevarchar2table,
        conc_prog_names       out nocopy varchar2table,
        arg_texts             out nocopy largevarchar2table,
        request_ids           out nocopy numbertable,
        phases                out nocopy varchar2table,
        statuses              out nocopy varchar2table,
        dev_phases            out nocopy smallvarchar2table,
        dev_statuses          out nocopy smallvarchar2table,
        timestamps            out nocopy varchar2table,
        num_requests          out nocopy number);

procedure get_arguments (
        req_id      in  number,
        arg1       out nocopy varchar2,
        arg2       out nocopy varchar2,
        arg3       out nocopy varchar2,
        arg4       out nocopy varchar2,
        arg5       out nocopy varchar2,
        arg6       out nocopy varchar2,
        arg7       out nocopy varchar2,
        arg8       out nocopy varchar2,
        arg9       out nocopy varchar2,
        arg10       out nocopy varchar2,
        arg11       out nocopy varchar2,
        arg12       out nocopy varchar2,
        arg13       out nocopy varchar2,
        arg14       out nocopy varchar2,
        arg15       out nocopy varchar2,
        arg16       out nocopy varchar2,
        arg17       out nocopy varchar2,
        arg18       out nocopy varchar2,
        arg19       out nocopy varchar2,
        arg20       out nocopy varchar2,
        arg21       out nocopy varchar2,
        arg22       out nocopy varchar2,
        arg23       out nocopy varchar2,
        arg24       out nocopy varchar2,
        arg25       out nocopy varchar2);


  procedure add_dynamic_column (
        X_request_id  in      number,
        X_attribute_name      in varchar2,
        X_column_name         in varchar2,
        X_ordering            in varchar2,
        X_BREAK                  in VARCHAR2,
        X_DISPLAY_LENGTH         in NUMBER,
        X_DISPLAY_FORMAT         in VARCHAR2,
        X_DISPLAY_STATUS         in VARCHAR2,
        calling_fn            in varchar2);

  /* StatReq - The following two function specs have been added for statutory reporting requirements */

  FUNCTION get_flex_val_meaning (
        v_flex_value_set_id     IN NUMBER,
        v_flex_value_set_name   IN VARCHAR2,
        v_flex_value            IN VARCHAR2)
  return VARCHAR2;

--* bug#2991482, rravunny
--* parent value feature added.
--* overridden function
--*
  FUNCTION get_flex_val_meaning (
        v_flex_value_set_id     IN NUMBER,
        v_flex_value_set_name   IN VARCHAR2,
        v_flex_value            IN VARCHAR2,
        v_parent_flex_val       IN VARCHAR2) --* new parameter added.
  return VARCHAR2;

  FUNCTION get_asset_info (
        v_info_type             IN VARCHAR2,
        v_asset_id              IN NUMBER,
        v_from_date             IN DATE,
        v_to_date               IN DATE,
        v_book_type_code        IN VARCHAR2,
        v_balancing_segment     IN VARCHAR2)
  return VARCHAR2;



  PROCEDURE clear_flex_val_cache;

  /* StatReq - Global Variables */

--* bug#2991482, rravunny
--* parent value feature added.
--*
  TYPE g_value_rec_type is RECORD (
        parent_flex_value_low  fnd_flex_values.parent_flex_value_low%TYPE default null,
        value           VARCHAR2(150),
        meaning         VARCHAR2(240));

--*  TYPE g_value_rec_type is RECORD (
--*     value           VARCHAR2(150),
--*     meaning         VARCHAR2(240));

  TYPE g_value_tab_type is TABLE of g_value_rec_type
       index by BINARY_INTEGER;

  TYPE g_value_set_rec_type is RECORD  (
        value_set_name  VARCHAR2(150),
        from_counter    NUMBER,
        to_counter      NUMBER);

  TYPE g_value_set_tab_type is TABLE of g_value_set_rec_type
       index by BINARY_INTEGER;

  g_values_tab          g_value_tab_type;

  g_value_set_tab       g_value_set_tab_type;

  g_value_set_counter   NUMBER := 0;
  g_value_counter       NUMBER := 0;

  g_loc_flex_struct             NUMBER;



TYPE g_seg_data is RECORD (
tabname         VARCHAR2(30),
table_id        NUMBER(15),
colname         VARCHAR2(30),
segment_num     NUMBER(3),
delimiter       VARCHAR2(1) );

-- Needed for multirow selects.
TYPE g_seg_data_tbl is TABLE of g_seg_data
        INDEX BY BINARY_INTEGER;

 g_seg_struct   g_seg_data;
 g_seg_table            g_seg_data_tbl;
 g_seg_count   NUMBER := 0;



END FA_RX_SHARED_PKG;

/
