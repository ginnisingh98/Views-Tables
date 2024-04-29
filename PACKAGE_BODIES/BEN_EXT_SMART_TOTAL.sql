--------------------------------------------------------
--  DDL for Package Body BEN_EXT_SMART_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_SMART_TOTAL" as
/* $Header: benxsttl.pkb 120.1 2006/10/10 20:28:27 tjesumic noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation              |
|              Redwood Shores, California, USA             |
|                   All rights reserved.                   |
+==============================================================================+
--
Name
        Benefit Extract Smart Totals
Purpose
        This package is for totals in the header/trailer
History
        Date      Version      Who                   What?
        11/16/98  115.0        YRathman/PDas         Created.
        12/09/98  115.1        PDas                  Modified Calc_Smart_Total
                                                     Procedure
        12/28/98  115.2        PDas                  Added get_value procedure
        02/03/99  115.3        PDas                  Deleted date and
                                                     enabled_flag check for hr_lookups
        02/08/99  115.4        PDas                  Moved function get_value to benxutil.pkb
        02/10/99  115.5        PDas                  Modified Calc_Smart_Total
                                                     Procedure
                                                     - added p_frmt_mask_cd paramater
        02/16/99  115.6        PDas                  Modified Calc_Smart_Total
        08/06/99  115.7        ASen                  Added messages : Entering, Exiting.
        10/03/99  115.8        Thayden               Rewrote to handle multiple conditions.
        01/04/99  115.9        Thayden               Fixed format mask bugs.
        02/24/00  115.10       Shdas                 changed the dynamic sql for calculating
                                                     smart totals.
        01/30/01  115.11       tilak                 error message is changed , the messages is
                                                     sent instead of the name
        08/10/01  115.12       ikasire               Bug 1928211 changed the l_smart_ttl_string
                                                     as per the details in bug resolution
        02/10/02  115.13       tjesumic              Fraction Amount is not taken care in
                                                     SUM function . added in translation - 2012562
        02/10/02  115.14       tjesumic              dbdrv fixed
        03/13/02  115.15       ikasire               UTF8 Changes
        12/23/02  115.16       lakrish               NOCOPY changes
        12/23/02  115.17       tjesumic              closing ')' moved below the lop
                                                       # 2729093
        06/14/04  115.18       tjesumic              3691826 fixed by creating str with format mask
        06/15/04  115.19       tjesumic              3691826
        03/22/05  115.20        tjesumic              new parameter group_val_01,02 added for
                                                     sub grouping calcaultion for subheader
        10/10/06  115.21       tjesumic              ben_Ext_frmt,format_mask function called to
                                                     apply the format maks so {} format are taken care
*/
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_where_params >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure finds the necessary column in ben_ext_rslt_dtl
-- for where clause
--
Procedure get_where_params(p_ext_rcd_id                        in number,
                           p_cond_ext_data_elmt_id             in number,
                           p_data_elmt_seq_num                 out nocopy varchar2
                           ) IS
--
  l_proc               varchar2(72) := g_package||'.get_where_params';
--
  l_seq_num            number(9);
  l_seq_num_char       varchar2(2);
--
  cursor where_c is
  SELECT xdr.seq_num
  FROM   ben_ext_data_elmt_in_rcd xdr
  WHERE  xdr.ext_data_elmt_id = p_cond_ext_data_elmt_id
   and   xdr.ext_rcd_id = p_ext_rcd_id;
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
  open where_c;
  fetch where_c into l_seq_num;
  if where_c%found then
    close where_c;
--
    if l_seq_num <= 0 or l_seq_num > 99 then
      ben_ext_thread.g_err_name := 'BEN_92081_EXT_DATA_ELMT_SEQ';
      raise ben_ext_thread.g_ht_error;
    end if;
--
    if l_seq_num > 9 then
      l_seq_num_char := to_char(l_seq_num);
    else
      l_seq_num_char := '0'||to_char(l_seq_num);
    end if;
    p_data_elmt_seq_num := l_seq_num_char;
--
  else
    ben_ext_thread.g_err_name := 'BEN_92082_EXT_COND_DATA_ELMT';
    raise ben_ext_thread.g_ht_error;
  end if;
--
  hr_utility.set_location('Exiting'||l_proc, 15);
--
Exception
  when ben_ext_thread.g_ht_error then
--
    raise ben_ext_thread.g_ht_error;
--
End get_where_params;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_sum_params >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure finds the necessary column in ben_ext_rslt_dtl
-- for sum
--
Procedure get_sum_params(p_ttl_sum_ext_data_elmt_id         in number,
                         p_ext_file_id                      in number,
                         p_business_group_id                in number,
                         p_ext_rcd_id                       in number,
                         p_sum_column                       out nocopy varchar2,
                         p_frmt_mask                        out nocopy varchar2
                        ) IS
--
  l_proc               varchar2(72) := g_package||'.get_sum_params';
--
  l_seq_num            number(9);
  l_frmt_mask_cd       hr_lookups.lookup_code%type;
--
  cursor sum_c is
  SELECT c.seq_num,
         d.frmt_mask_cd
  FROM   ben_ext_data_elmt_in_rcd c,
         ben_ext_data_elmt        d
  WHERE  c.ext_rcd_id = p_ext_rcd_id
  AND    c.ext_data_elmt_id = p_ttl_sum_ext_data_elmt_id
  AND    d.ext_data_elmt_id = c.ext_data_elmt_id;
--
  cursor mask_c is
  SELECT meaning
  FROM   hr_lookups
  WHERE  lookup_type = 'BEN_EXT_FRMT_MASK'
  AND    lookup_code = l_frmt_mask_cd;
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
  open sum_c;
  fetch sum_c into l_seq_num, l_frmt_mask_cd;
  if sum_c%found then
    close sum_c;
--
    if l_seq_num <= 0 then
      ben_ext_thread.g_err_name := 'BEN_92081_EXT_DATA_ELMT_SEQ';
      raise ben_ext_thread.g_ht_error;
    end if;
--
    if l_seq_num > 9 then
      p_sum_column := to_char(l_seq_num);
    else
      p_sum_column := '0'||to_char(l_seq_num);
    end if;
--
    if l_frmt_mask_cd is not null then
      open mask_c;
      fetch mask_c into p_frmt_mask;
      if mask_c%notfound then
        close mask_c;
        ben_ext_thread.g_err_name := 'BEN_92088_EXT_CORRUPT';
        raise ben_ext_thread.g_ht_error;
      else
        close mask_c;
        if p_frmt_mask is null then
          ben_ext_thread.g_err_name := 'BEN_92088_EXT_CORRUPT';
          raise ben_ext_thread.g_ht_error;
        end if;
      end if;
    end if;
--
  else
--
    ben_ext_thread.g_err_name := 'BEN_92083_EXT_SUM_DATA_ELMT';
    raise ben_ext_thread.g_ht_error;
--
  end if;
--
  hr_utility.set_location('Exiting'||l_proc, 15);
--
End get_sum_params;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< build_where_string >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure builds the where clause for dynamic sql.
--
Procedure build_where_string(p_ext_rslt_id            in number,
                           p_ext_rcd_id             in  number,
                           p_ext_data_elmt_id       in  number,
                           p_group_val_01           in varchar2 default null ,
                           p_group_val_02           in varchar2 default null,
                           p_where_string           out nocopy varchar2
                           ) IS
--
l_proc                varchar2(72) := g_package||'.build_where_string';
l_data_elmt_seq_num varchar2(2);
l_where_string varchar2(2000);
l_cnt number := 0;
--
cursor c_xwc(p_ext_data_elmt_id in number)  is
  select xwc.oper_cd,
         xwc.val,
         xwc.and_or_cd,
         xwc.cond_ext_data_elmt_id
  from ben_ext_where_clause xwc
  where xwc.ext_data_elmt_id = p_ext_data_elmt_id
  order by xwc.seq_num;
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
  l_where_string := ' where ext_rslt_id = ' || to_char(p_ext_rslt_id);
--
  if p_ext_rcd_id is not null then
    l_where_string := l_where_string ||
      ' and ext_rcd_id = ' || to_char(p_ext_rcd_id);
--
    for xwc in c_xwc(p_ext_data_elmt_id) loop
      l_cnt := l_cnt +1;
      if l_cnt = 1 then
        l_where_string := l_where_string || ' and (';
      end if;
--
      if xwc.oper_cd is null then
        ben_ext_thread.g_err_name := 'BEN_92084_EXT_COND_OPER';
        raise ben_ext_thread.g_ht_error;
      end if;
--
--    need to get the sequence number of the data element in record so we know
--    which bucket (val_XX) to look in.
--
      get_where_params(
                     p_ext_rcd_id                 => p_ext_rcd_id,
                     p_cond_ext_data_elmt_id      => xwc.cond_ext_data_elmt_id,
                     p_data_elmt_seq_num          => l_data_elmt_seq_num
                     );
--
      l_where_string := l_where_string ||
                      ' upper(val_' || l_data_elmt_seq_num || ') ' ||
                      xwc.oper_cd || ' ' || upper(xwc.val) || ' ' || xwc.and_or_cd ;
--                      xwc.oper_cd || ' ' || upper(xwc.val) || ' ' || xwc.and_or_cd || ')';
--
        hr_utility.set_location(upper(xwc.val) || ' '|| xwc.and_or_cd  ,999);
    end loop;


    if  ltrim(rtrim(p_group_val_01))  is not null then

       l_where_string := l_where_string ||  ' and   group_val_01 = ''' ||  p_group_val_01 || ''' ' ;
       if ltrim(rtrim(p_group_val_02)) is not null then
          l_where_string := l_where_string ||  ' and   group_val_02 = ''' ||  p_group_val_02 || ''' ' ;
       end if ;

    end if ;
    --- closing is moved out of loop  2729093
    if l_cnt >  0 then
        hr_utility.set_location(' adding closing '  ,999);
       l_where_string := l_where_string ||  ') ' ;
    end if ;

--
  end if;
    p_where_string := l_where_string;
--
 --   hr_utility.set_location(l_where_string,99999);
--
    hr_utility.set_location('Exiting'||l_proc, 15);
--
End build_where_string;
--
-- ----------------------------------------------------------------------------
-- |--------------------< calc_smart_total >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure calculate smart total
--
Procedure calc_smart_total(p_ext_rslt_id                   in number,
                           p_ttl_fnctn_cd                  in varchar2,
                           p_ttl_sum_ext_data_elmt_id      in number,
                           p_ttl_cond_ext_data_elmt_id     in number,  --ext_rcd_id
                           p_ext_data_elmt_id              in number,
                           p_frmt_mask_cd                  in varchar2,  --contains mask, not the cd.
                           p_ext_file_id                   in number,
                           p_business_group_id             in number,
                           p_group_val_01                  in varchar2 default null ,
                           p_group_val_02                  in varchar2 default null,
                           p_smart_total                  out nocopy varchar2
                           ) IS
--
  l_proc                varchar2(72) := g_package||'.calc_smart_total';
--
  l_cond_rcd_id         number(15);
  l_cond_column         varchar2(30);
--
  l_sum_rcd_id          number(15);
  l_sum_column          varchar2(30);
  l_frmt_mask           hr_lookups.meaning%TYPE; -- UTF8 varchar2(80);
  l_sum_col_frmt_mask   hr_lookups.meaning%TYPE; -- UTF8 varchar2(80);
  l_smart_total         varchar2(200);
--
  l_where_string        varchar2(2000);
  l_smart_ttl_string    varchar2(2000);
  l_ttl_cond_val        varchar2(200);
  l_oper                hr_lookups.meaning%type;
--
  cid                   integer;
  res                   integer;
  l_ext_rcd_id          number;
  l_err_message         varchar2(2000);
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
  l_smart_ttl_string := null;
--
-- note: for smart totals, we are now using field p_ttl_cond_ext_data_elmt_id
-- for ext_rcd_id.  Due to last minute change, it was too late to rename.
--
   l_ext_rcd_id := p_ttl_cond_ext_data_elmt_id;
--
  if p_ext_data_elmt_id is null then
    ben_ext_thread.g_err_name := 'BEN_92088_EXT_CORRUPT';
    raise ben_ext_thread.g_ht_error;
  end if;
--
    build_where_string(
       p_ext_rslt_id => p_ext_rslt_id, --in
       p_ext_rcd_id => l_ext_rcd_id, --in
       p_ext_data_elmt_id => p_ext_data_elmt_id,  --in
       p_group_val_01     => p_group_val_01 ,
       p_group_val_02     => p_group_val_02,
       p_where_string => l_where_string);  --out

--
  if p_ttl_fnctn_cd = 'SUM' then
--
    get_sum_params(p_ttl_sum_ext_data_elmt_id     => p_ttl_sum_ext_data_elmt_id, --in
                   p_ext_file_id                  => p_ext_file_id, --in
                   p_business_group_id            => p_business_group_id,  --in
                   p_ext_rcd_id                   => l_ext_rcd_id, --in
                   p_sum_column                   => l_sum_column, --out
                   p_frmt_mask                    => l_sum_col_frmt_mask --out
                   );
--
        /* what the following dynamic sql does is just strip out nocopy from the
        data element(for which we are calculating total) all the characters
        that are not between 0 and 9 and then sum them.
        So  it first translates all characters of the data element(say $123v30)
        between 0 and 9 with ;.So we have now $;;;v;;.
        Now applying a replace we replace all ; with null.So we have $v.
        Then applying a translate on the data element(i.e $123v30) with 0123456789
        for 0123456789$v will give us the desired result(i.e 12330).*/

/*
        l_smart_ttl_string := 'select to_char(sum(to_number(
                              translate(replace(val_'||l_sum_column||',
                              '';'',''''),''0123456789''||replace(translate(val_'||
                              l_sum_column||',''0123456789'','';''),'';'',''''),
                              ''0123456789''))))'||
                              ' from ben_ext_rslt_dtl'
                              || l_where_string;
*/
       -- Bug 1928211 changed the script are the Ty's note in the Bug resolution.
       --
       Begin
              l_smart_ttl_string := 'select to_char(sum(to_number(
                              translate(replace(val_'||l_sum_column||',
                              '';'',''''),''-0123456789.''||replace(translate(val_'||
                              l_sum_column||',''-0123456789.'','';''),'';'',''''),
                              ''-0123456789.''))))'||
                              ' from ben_ext_rslt_dtl'
                              || l_where_string;

          -- the sum does not work for the value with format mask 0999999999999D99S
          --  - or + signs are added to end of the  value so the sum is not recognising
          -- the sql tested before the sql executed, though it is duplicate it is necdesery for bug 3691826
          -- if the sql errors and the column defined with format , try to convert the colum with theformat to sum
          -- value  3691826

           cid := DBMS_SQL.OPEN_CURSOR;
           DBMS_SQL.PARSE(cid, l_smart_ttl_string, DBMS_SQL.NATIVE);
           DBMS_SQL.DEFINE_COLUMN(cid, 1, l_smart_total, 200);
           res := DBMS_SQL.EXECUTE(cid);
           res := DBMS_SQL.FETCH_ROWS(cid);
           DBMS_SQL.COLUMN_VALUE(cid, 1, l_smart_total);
           DBMS_SQL.CLOSE_CURSOR(cid);


       exception
         when Others then
           hr_utility.set_location('value error ' , 99 );
           if l_sum_col_frmt_mask is not null then

                 l_smart_ttl_string := 'select (sum(to_number(val_'||l_sum_column||', '''||  l_sum_col_frmt_mask|| ''')))'||
                              ' from ben_ext_rslt_dtl'
                              || l_where_string;


           end if ;



       end ;
--
  elsif p_ttl_fnctn_cd = 'CNT' then
--
    l_smart_ttl_string := 'select to_char(count(*)) from ben_ext_rslt_dtl'||
                          l_where_string;
--
  else  -- function is not present or invalid.
    ben_ext_thread.g_err_name := 'BEN_92087_EXT_TTL_FNCTN';
    raise ben_ext_thread.g_ht_error;
  end if;
--
--  dbms_output.put_line(l_smart_ttl_string);
--
-- This is dynamic SQL part
--
  cid := DBMS_SQL.OPEN_CURSOR;
--
  DBMS_SQL.PARSE(cid, l_smart_ttl_string, DBMS_SQL.NATIVE);
--
  DBMS_SQL.DEFINE_COLUMN(cid, 1, l_smart_total, 200);
  res := DBMS_SQL.EXECUTE(cid);
  res := DBMS_SQL.FETCH_ROWS(cid);
  DBMS_SQL.COLUMN_VALUE(cid, 1, l_smart_total);
  DBMS_SQL.CLOSE_CURSOR(cid);
--
  if p_frmt_mask_cd is null then
    p_smart_total := ltrim(l_smart_total);
  else
    begin
    --p_smart_total := ltrim(to_char(to_number(l_smart_total),p_frmt_mask_cd));
    p_smart_total := ben_Ext_fmt.apply_format_mask(p_value      => to_number(l_smart_total),
                                                   p_format_mask =>  p_frmt_mask_cd ) ;
    exception
     when others then
       p_smart_total := ltrim(l_smart_total);
          -- show warning here
          l_err_message :=  ben_ext_fmt.get_error_msg(92065,'BEN_92065_EXT_FRMT_INVALID' );
          ben_ext_util.write_err
         (p_ext_rslt_id => ben_extract.g_ext_rslt_id,
          p_err_num => 92065,
          p_err_name =>l_err_message ,
          p_typ_cd => 'W',
          p_person_id => null,
          p_request_id => ben_extract.g_request_id,
          p_business_group_id => ben_ext_person.g_business_group_id);
    end;
  end if;
--
--dbms_output.put_line(to_char(l_smart_total));
--
  hr_utility.set_location('Exiting'||l_proc, 15);
--
Exception
--
  when ben_ext_thread.g_ht_error then
    raise ben_ext_thread.g_ht_error;
  --
  when others then
      p_smart_total := null;
      -- this needs replaced with a message for translation.
      fnd_file.put_line(fnd_file.log,
        'Error in Smart Totals while processing this dynamic sql statement: ');
      fnd_file.put_line(fnd_file.log, l_smart_ttl_string);
      raise;  -- such that the error processing in ben_ext_thread occurs.

--
End calc_smart_total;
--
End ben_ext_smart_total;

/
