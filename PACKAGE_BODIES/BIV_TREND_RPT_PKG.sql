--------------------------------------------------------
--  DDL for Package Body BIV_TREND_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_TREND_RPT_PKG" as
/* $Header: bivsrvctrdb.pls 115.0 2003/10/06 01:20:39 kreardon noship $ */

procedure load
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2 ) is

  cursor c_tab is
    select
      sum(decode(current_ind,1,1,0)) cur_rows
    , min(decode(current_ind,1,offset,null)) cur_min
    , max(decode(current_ind,1,offset,null)) cur_max
    , sum(decode(current_ind,1,offset,null)) cur_sum
    , sum(decode(current_ind,2,1,0)) prior_rows
    , min(decode(current_ind,2,offset,null)) prior_min
    , max(decode(current_ind,2,offset,null)) prior_max
    , sum(decode(current_ind,2,offset,null)) prior_sum
    , sum(decode(current_ind,4,1,0)) opening_rows
    , min(decode(current_ind,4,offset,null)) opening_min
    , max(decode(current_ind,4,offset,null)) opening_max
    , sum(decode(current_ind,4,offset,null)) opening_sum
    from biv_trend_rpt;

  l_rec c_tab%rowtype;
  l_invalid number := 1;

begin

  open c_tab;
  fetch c_tab into l_rec;
  if l_rec.cur_rows = 13 and
     l_rec.cur_min = -12 and
     l_rec.cur_max = 0 and
     l_rec.cur_sum = -78 and
     l_rec.prior_rows = 13 and
     l_rec.prior_min = -12 and
     l_rec.prior_max = 0 and
     l_rec.prior_sum = -78 and
     l_rec.opening_rows = 13 and
     l_rec.opening_min = -12 and
     l_rec.opening_max = 0 and
     l_rec.opening_sum = -78 then
    l_invalid := 0;
  end if;
  close c_tab;

  if l_invalid = 0 then

    bis_collection_utilities.log('Table has valid row set');

  else

    bis_collection_utilities.log('Table contains invalid row set, resetting table');

    delete from biv_trend_rpt;

    for o in 0..12 loop
      for c in 1..4 loop
        if c <> 3 then
          insert into biv_trend_rpt
          ( current_ind
          , offset
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login )
          values
          ( c
          , 0-o
          , sysdate
          , fnd_global.user_id
          , sysdate
          , fnd_global.user_id
          , fnd_global.login_id );
        end if;
      end loop;
    end loop;

    commit;

  end if;

end load;

end biv_trend_rpt_pkg;

/
