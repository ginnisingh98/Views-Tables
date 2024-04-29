--------------------------------------------------------
--  DDL for Package Body IBY_FACTOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FACTOR_PKG" AS
/*$Header: ibyfactb.pls 115.15 2002/11/18 23:02:25 jleybovi ship $*/

  /*
  ** Procedure: save_PaymentAmount
  ** Purpose: Saves the PaymentAmount factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_PaymentAmount( i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_count in integer,
                                i_amountRanges in AmountRange_table )
  is

    i  int;
    l_lowerLimit number;
    l_upperLimit number;
    l_score      varchar2(100);
    l_seq        int;

  begin

       -- Assumption, Ranges are verified in Java Code it self.


       -- initialize the values.

       -- if payeeid is not null check if payee has any entries in
       -- table or not. If not present then create insert statment
       -- else update statement.

       -- loop through the list of ranges passed and update
       -- the database.
       -- delete all the entries first.

      delete from iby_irf_pmt_amount
      where ((payeeid = i_payeeid)
             or (i_payeeid is null and payeeid is null));


       i := 1;
       while ( i <= i_count ) loop

         -- extract the values fromt the database.
         l_lowerLimit := i_amountRanges(i).LowAmtLmt;
         l_upperLimit := i_amountRanges(i).UprAmtLmt;
         l_seq        := i_amountRanges(i).Seq;
         l_score      := i_amountRanges(i).score;
         i            := i+1;

         insert into iby_irf_pmt_amount
               (lower_limit, upper_limit, score, seq,
                payeeid, object_version_number,
                last_update_date, last_updated_by, creation_date, created_by)
         values ( l_lowerLimit, l_upperLimit, l_score, l_seq,
                i_payeeid,1,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id);

         /*
         -- if no rows were created then raise the exception.
         if ( SQL%ROWCOUNT = 0 ) then
               -- raise application error for the range it has failed.
               raise_application_error(-20000, 'IBY_204200#' ||
                    'LOWERLIMIT='|| l_lowerLimit ||
                    '#UPPERLIMIT='||l_upperLimit|| '#');
         end if;
         */
       end loop;

     -- commit the changes;
     commit;

  end;

  /*
  ** Procedure: load_PaymentAmount
  ** Purpose: loads  the PaymentAmount factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          creates new entries.
  */
  procedure load_PaymentAmount( i_payeeid in VARCHAR2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_amountRanges out nocopy AmountRange_table )
  is

  l_cnt int;
  l_payeeid varchar2(80);

  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'PMTAMOUNT' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);

  cursor c_load_ranges(ci_payeeid VARCHAR2) is
    select lower_limit, upper_limit, seq, score
    from iby_irf_pmt_amount
    where (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid))
    order by seq;

  cursor c_payee_range_count(ci_payeeid VARCHAR2) is
    select count(*)
    from iby_irf_pmt_amount
    where  payeeid = ci_payeeid;

  begin

    -- if payeeid is not null and there are no rows for the
    -- payeeid passed in the database for this factor then
    -- need to load the default values. Default value rows
    -- will be identified by null payeeid values.

    l_payeeid := i_payeeid;
    if ( i_payeeid is not null ) then
        if ( c_payee_range_count%isopen ) then
             close c_payee_range_count;
        end if;
        open c_payee_range_count(i_payeeid);
        fetch c_payee_range_count into l_cnt;
        close c_payee_range_count;
        -- payee does not have any configured information.
        -- default values must be retrieved.
        if ( l_cnt = 0) then
            l_payeeid := null;
        end if;
    end if;

    -- close the cursors, if they are already open.
    if ( c_load_factor%isopen ) then
        close c_load_factor;
    end if;

    if ( c_load_ranges%isopen ) then
        close c_load_ranges;
    end if;

    open c_load_factor;

    -- load the factor information.
    fetch c_load_factor into o_name, o_description;

    -- if no factor found then raise the application error.
    if ( c_load_factor%notfound ) then
       raise_application_error(-20000,'IBY_204201#');
    end if;

    l_cnt := 1;

    -- load all the ranges for this factor.

    for i in c_load_ranges(l_payeeid) loop
      o_amountRanges(l_cnt).lowAmtLmt := i.lower_limit;
      o_amountRanges(l_cnt).uprAmtLmt := i.upper_limit;
      o_amountRanges(l_cnt).score     := i.score;
      o_amountRanges(l_cnt).seq       := i.seq;
      l_cnt := l_cnt + 1;
    end loop;

    close c_load_factor;

  end;

  /*
  ** Procedure: save_TimeOfPurchase
  ** Purpose: Saves the TimeOfPurchase factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_TimeOfPurchase( i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_count in integer,
                                i_timeRanges in TimeRange_table )
  is

    i  int;
    l_lowerlimit integer;
    l_upperlimit integer;
    l_score      varchar2(100);
    l_seq        int;

  begin

       -- Assumption, Ranges are verified in Java Code it self.


       -- initialize the values.
       i := 1;

       -- loop through the list of ranges passed and update
       -- the database.

       -- delete all the ranges
       delete from iby_irf_timeof_purchase
       where ( ( payeeid = i_payeeid ) or
               ( i_payeeid is null and payeeid is null ) );

       while ( i <= i_count ) loop

         -- extract the values fromt the database.
         l_lowerLimit := i_timeRanges(i).LowTimeLmt;
         l_upperLimit := i_timeRanges(i).UprTimeLmt;
         l_seq        := i_timeRanges(i).Seq;
         l_score      := i_timeRanges(i).score;
         i            := i+1;

         -- insert the ranges into database based on the sequence.
         insert into iby_irf_timeof_purchase
              ( duration_from ,duration_to, score, seq,
                payeeid , object_version_number,
                last_update_date, last_updated_by, creation_date, created_by)
         values ( l_lowerLimit, l_upperLimit, l_score, l_seq,
                i_payeeid,1,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id);

         -- if inserted number of rows is zero then raise an exception.
         /*
         if ( SQL%ROWCOUNT = 0 ) then
               -- raise application error
               raise_application_error(-20000, 'IBY_204202#' ||
                   'LOWERLIMIT=' || l_lowerLimit ||
                   '#UPPERLIMIT='|| l_upperLimit || '#');
         end if;
         */
       end loop;
     -- commit the changes;
     commit;

  end;

  /*
  ** Procedure: load_TimeOfPurchase
  ** Purpose: loads  the TimeOfPurchase factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the site level entries.
  */
  procedure load_TimeOfPurchase( i_payeeid in VARCHAR2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_timeRanges out nocopy TimeRange_table )
  is

  l_cnt integer;
  l_duration_to integer;
  l_duration_from integer;
  l_score varchar2(100);
  l_payeeid varchar2(80);

  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'TIMEOFPURCHASE' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);



  cursor c_load_ranges(ci_payeeid VARCHAR2) is
    select duration_from, duration_to, seq, score
    from iby_irf_timeof_purchase
    where (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid))
    order by seq;

  cursor c_ranges_count(ci_payeeid VARCHAR2) is
    select count(*)
    from iby_irf_timeof_purchase
    where payeeid = ci_payeeid;

  begin

    -- check whether payee id is not null or not. If payeeid is
    -- not null then check whether the payeeid has any information
    -- configured. if not then default values should be loaded.
    -- For default values payeeid will be null.
    l_payeeid := i_payeeid;
    if ( i_payeeid  is not null ) then
        if ( c_ranges_count%isopen ) then
             close c_ranges_count;
        end if;
        open c_ranges_count(i_payeeid);
        fetch c_ranges_count into l_cnt;
        close c_ranges_count;
        -- if no rows are present, to load default values set payeeid
        -- to null.
        if ( l_cnt = 0) then
            l_payeeid := null;
        end if;
    end if;

    -- close all cursors if they are open.
    if ( c_load_factor%isopen ) then
        close c_load_factor;
    end if;

    if ( c_load_ranges%isopen ) then
        close c_load_ranges;
    end if;

    -- load factor information.
    open c_load_factor;

    fetch c_load_factor into o_name, o_description;

    -- if factor information is not present then raise the
    -- exception.
    if ( c_load_factor%notfound ) then
       raise_application_error(-20000,'IBY_204201#');
    end if;

    l_cnt := 1;

    -- load time ranges.
    for i in c_load_ranges(l_payeeid) loop
      o_timeranges(l_cnt).lowTimeLmt := i.duration_from;
      o_timeranges(l_cnt).uprTimeLmt := i.duration_to;
      o_timeranges(l_cnt).score     := i.score;
      o_timeranges(l_cnt).seq       := i.seq;
      l_cnt := l_cnt + 1;
    end loop;

    -- close the cursors.
    close c_load_factor;

  end;

  /*
  ** Procedure: save_TrxnAmountLimit
  ** Purpose: Saves the TrxnAmountLimit factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_TrxnAmountLimit( i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_duration in integer,
                                i_durationType in VARCHAR2,
                                i_amount in number )
  is
  begin

      -- update the transaction amount table.
      -- this will be successful either payeeid is
      -- null or the payeeid was configured some information.
      update iby_irf_trxn_amt_limit
           set duration = i_duration,
               duration_type = i_durationType,
               amount = i_amount,
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id
           where (( payeeid is null and i_payeeid is null ) or
                  ( payeeid = i_payeeid));

      -- if there are no rows present insert rows into database.
      -- this happens when save is called first time for certain
      -- payeeid.
      if ( SQL%ROWCOUNT = 0 ) then
          -- insert the information.
          insert into iby_irf_trxn_amt_limit
              ( duration, duration_type, amount,
                payeeid, object_version_number,
                last_update_date, last_updated_by, creation_date, created_by)
          values (i_duration, i_durationType, i_amount,
                i_payeeid,1,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id);

	  /*
          -- if information could not be saved then raise
          -- application error.
          if ( SQL%ROWCOUNT = 0 ) then
            -- raise application error
            raise_application_error(-20000, 'IBY_204204#');
          end if;
	  */
      end if;

     -- commit the changes;
     commit;
  end;

  /*
  ** Procedure: load_TrxnAmountLimit
  ** Purpose: loads  the TrxnAmountLimit factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the site level entries.
  */
  procedure load_TrxnAmountLimit( i_payeeid in varchar2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_duration out nocopy integer,
                                o_durationType out nocopy VARCHAR2,
                                o_amount out nocopy number )
  is

  l_cnt integer;
  l_payeeid varchar2(80);

  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'TRXNAMOUNT' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);


  cursor c_trxn_amount_limit(ci_payeeid varchar2) is
    select duration, duration_type, amount
    from iby_irf_trxn_amt_limit
    where (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid));

  cursor c_trxn_amount_count(ci_payeeid varchar2) is
    select count(*)
    from iby_irf_trxn_amt_limit
    where  payeeid = ci_payeeid;

  begin

    -- check whether payee id is not null or not. If payeeid is
    -- not null then check whether the payeeid has any information
    -- configured. if not then default values should be loaded.
    -- For default values payeeid will be null.
    l_payeeid := i_payeeid;
    if ( i_payeeid is not null  ) then
        if ( c_trxn_amount_count%isopen ) then
             close c_trxn_amount_count;
        end if;
        open c_trxn_amount_count(i_payeeid);
        fetch c_trxn_amount_count into l_cnt;
        close c_trxn_amount_count;
        -- payee does not have any configured information.
        -- to retrieve defaule information set payeeid to null.
        if ( l_cnt = 0) then
            l_payeeid := null;
        end if;
    end if;

    -- close all the cursors.
    if ( c_load_factor%isopen )then
      close c_load_factor;
    end if;

    if ( c_trxn_amount_limit%isopen )then
      close c_trxn_amount_limit;
    end if;

    open c_load_factor;
    open c_trxn_amount_limit(l_payeeid);

    fetch c_load_factor into o_name, o_description;

    -- if factor information is not found then
    -- raise the exception.
    if ( c_load_factor%notfound ) then
       raise_application_error(-20000,'IBY_204201#');
    end if;

    fetch c_trxn_amount_limit into o_duration, o_durationType, o_amount;

    close c_trxn_amount_limit;
    close c_load_factor;

  end;

  /*
  ** Procedure: save_PaymentHistory
  ** Purpose: Saves the PaymentHistory factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_PaymentHistory(i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_duration in integer,
                                i_durationType in VARCHAR2,
                                i_count in integer,
                                i_freqRanges in FreqRange_table )
  is

    i  int;
    l_lowerLimit int;
    l_upperLimit int;
    l_score      varchar2(100);
    l_seq        int;
    l_pmt_hist_id  int;

  cursor c_pmtHistId(ci_payeeid varchar2) is
    select id
    from iby_irf_pmt_history
    where (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid));


  begin

       -- Assumption, Ranges are verified in Java Code it self.

       -- Update the master table. If there are no rows to update
       -- then insert the information. This happens only when
       -- payeeid id is not null.

       update iby_irf_pmt_history
       set duration = i_duration,
           duration_type = i_durationType,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id
       where (( payeeid is null and i_payeeid is null) or
                 ( payeeid = i_payeeid));

       if ( SQL%ROWCOUNT = 0 ) then

           -- insert a row in master table.
           SELECT iby_irf_pmt_history_s.nextval into l_pmt_hist_id
           FROM dual;

           insert into iby_irf_pmt_history (id, duration, duration_type,
                payeeid, object_version_number,
                last_update_date, last_updated_by, creation_date, created_by)
           values ( l_pmt_hist_id, i_duration, i_durationType, i_payeeid,
                1, sysdate, fnd_global.user_id, sysdate, fnd_global.user_id);

       else
           open c_pmtHistId(i_payeeId);
           fetch c_pmtHistId into l_pmt_hist_id;
           close c_pmtHistId;

       end if;

       -- initialize the values.
       i := 1;

       -- loop through the list of ranges passed and update
       -- the database.
       -- delete all the entries corresoonding to
       -- l_pmt_hist_id and then insert the new ranges.

       delete from iby_irf_pmt_hist_range
       where payment_hist_id = l_pmt_hist_id;

       while ( i <= i_count ) loop

         -- extract the values fromt the database.
         l_lowerLimit := i_freqRanges(i).LowFreqLmt;
         l_upperLimit := i_freqRanges(i).UprFreqLmt;
         l_seq        := i_freqRanges(i).Seq;
         l_score      := i_freqRanges(i).score;
         i            := i+1;

         -- insert the ranges into database based on the sequence.
         insert into iby_irf_pmt_hist_range
                ( payment_hist_id, frequency_low_range,
                  frequency_high_range, score, seq,
                  object_version_number,
                  last_update_date, last_updated_by,
                  creation_date, created_by)

         values ( l_pmt_hist_id, l_lowerlimit, l_upperlimit,
                     l_score, l_seq,
                     1,
                     sysdate, fnd_global.user_id,
                     sysdate, fnd_global.user_id);

	 /*
         -- if no data was inserted then raise the exceotion.
         if ( SQL%ROWCOUNT = 0 ) then
                -- raise application error
                raise_application_error(-20000, 'IBY_204206#'
                          || 'LOWERLIMIT=' || l_lowerlimit
                          || '#UPPERLIMIT=' || l_upperLimit || '#');
         end if;
	 */
       end loop;

     -- commit the changes;
     commit;
  end;

  /*
  ** Procedure: load_PaymentHistory
  ** Purpose: loads  the PaymentHistory factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the site level Payemnet History values.
  */
  procedure load_PaymentHistory(i_payeeid in VARCHAR2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_duration out nocopy integer,
                                o_durationType out nocopy VARCHAR2,
                                o_freqRanges out nocopy FreqRange_table )
  is

    l_cnt int;
    l_pmt_hist_id int;
    l_lowerLimit int;
    l_upperLimit int;
    l_score      varchar2(100);
    l_seq        int;
  l_payeeid varchar2(80);

  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'PMTHISTORY' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);


  cursor c_load_pmt_history(ci_payeeid varchar2) is
    select id, duration, duration_type
    from iby_irf_pmt_history
    where (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid));

  cursor c_load_ranges(ci_id integer)  is
    select frequency_low_range, frequency_high_range, score, seq
    from iby_irf_pmt_hist_range
    where payment_hist_id = ci_id
    order by seq;

  cursor c_pmt_history_count(ci_payeeid varchar2) is
    select count(*)
    from iby_irf_pmt_history
    where payeeid = ci_payeeid;

  begin

    -- check whether payee id is not null or not. If payeeid is
    -- not null then check whether the payeeid has any information
    -- configured. if not then default values should be loaded.
    -- For default values payeeid will be null.
    l_payeeid := i_payeeid;
    if ( i_payeeid is not null ) then
        if ( c_pmt_history_count%isopen ) then
             close c_pmt_history_count;
        end if;
        open c_pmt_history_count(i_payeeid);
        fetch c_pmt_history_count into l_cnt;
        close c_pmt_history_count;
        if ( l_cnt = 0) then
            l_payeeid := null;
        end if;
    end if;

    -- close all the cursors if they are already open
    if ( c_load_factor%isopen ) then
        close c_load_factor;
    end if;

    if ( c_load_pmt_history%isopen ) then
        close c_load_pmt_history;
    end if;

    if ( c_load_ranges%isopen ) then
        close c_load_ranges;
    end if;

    open c_load_factor;
    open c_load_pmt_history(l_payeeid);

    fetch c_load_factor into o_name, o_description;

    -- if factor information is not found then raise an exception.
    --
    if ( c_load_factor%notfound ) then
       raise_application_error(-20000,'IBY_204201#');
    end if;

    -- fetch the master level payment history information.
    fetch c_load_pmt_History into l_pmt_hist_id, o_duration, o_durationType;
    l_cnt := 1;
    -- load the purchase frequency ranges form payment history.
    for i in c_load_ranges(l_pmt_hist_id) loop
      o_freqRanges(l_cnt).lowFreqLmt := i.frequency_low_range;
      o_freqRanges(l_cnt).uprFreqLmt := i.frequency_high_range;
      o_freqRanges(l_cnt).score     := i.score;
      o_freqRanges(l_cnt).seq       := i.seq;
      l_cnt := l_cnt + 1;
    end loop;

    -- close all the cursors.
    close c_load_factor;
    close c_load_pmt_history;

  end;

  /*
  ** Procedure: save_AVSCodes
  ** Purpose: Saves the AVSCodes factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_AVSCodes( i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                           i_description in VARCHAR2,
                           i_count in integer,
                           i_codes in codes_table )
  is
    i  int;
    l_score      varchar2(100);
    l_code       IBY_MAPPINGS.MAPPING_CODE%TYPE;

  begin

       -- Assumption, Ranges are verified in Java Code it self.

       -- initialize the values.
       i := 1;
       -- loop through the list of ranges passed and update
       -- the database.
       delete from iby_mappings
       where (( payeeid = i_payeeid) or
              ( payeeid is null and i_payeeid is null ))
          and mapping_type = 'AVS_CODE_TYPE';

       while ( i <= i_count ) loop

         -- extract the values from the input and insert in database.
         l_code  := i_codes(i).code;
         l_score := i_codes(i).score;
         i       := i+1;

         insert into iby_mappings ( payeeid, mapping_type, mapping_code,
                value, object_version_number,
                last_update_date, last_updated_by, creation_date, created_by)
         values ( i_payeeid, 'AVS_CODE_TYPE', l_code,
                l_score,1,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id);

	 /*
         -- if no of rows inserted is zero then raise an
         -- exception.
         if ( SQL%ROWCOUNT = 0 ) then
               -- raise application error
               raise_application_error(-20000, 'IBY_204208#'||
                                      'AVSCODE=' || l_code || '#');
         end if;
	 */
       end loop;

     -- commit the changes;
     commit;
  end;

  /*
  ** Procedure: load_AVSCodes
  ** Purpose: loads  the AVSCodes factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads AVSCodes of the site level.
  */
  procedure load_AVSCodes( i_payeeid in varchar2,
                           o_name out nocopy VARCHAR2,
                           o_description out nocopy VARCHAR2,
                           o_codes out nocopy codes_table )
  is

  l_cnt int;
  l_payeeid varchar2(80);

  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'AVSCODES' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);


  cursor c_avs_codes(ci_payeeid varchar2) is
    select mapping_code, value
    from iby_mappings
    where mapping_type = 'AVS_CODE_TYPE'
      and (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid));

  cursor c_avs_codes_count(ci_payeeid varchar2) is
    select count(*)
    from iby_mappings
    where mapping_type = 'AVS_CODE_TYPE'
      and payeeid = ci_payeeid;

  begin

    -- check whether payee id is not null or not. If payeeid is
    -- not null then check whether the payeeid has any information
    -- configured. if not then default values should be loaded.
    -- For default values payeeid will be null.
    l_payeeid := i_payeeid;
    if ( l_payeeid is not null ) then
        if ( c_avs_codes_count%isopen ) then
             close c_avs_codes_count;
        end if;
        open c_avs_codes_count(i_payeeid);
        fetch c_avs_codes_count into l_cnt;
        close c_avs_codes_count;
        -- if there are no AVS codes set then
        -- to load default codes set payeeid to null.
        if ( l_cnt = 0) then
            l_payeeid := null;
        end if;
    end if;

    if ( c_load_factor%isopen ) then
        close c_load_factor;
    end if;

    if ( c_avs_codes%isopen ) then
        close c_avs_codes;
    end if;

    open c_load_factor;

    fetch c_load_factor into o_name, o_description;

    -- if factor information is not found then raise
    -- the exception.
    if ( c_load_factor%notfound ) then
       raise_application_error(-20000,'IBY_204201#');
    end if;

    l_cnt := 1;

    -- load avs codes.
    for i in c_avs_codes(l_payeeid) loop
      o_codes(l_cnt).code := i.mapping_code;
      o_codes(l_cnt).score := i.value;
      l_cnt := l_cnt + 1;
    end loop;

    close c_load_factor;
    -- close c_avs_codes;

  end;

  /*
  ** Procedure: save_RiskCodes
  ** Purpose: Saves the RiskCodes factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_RiskCodes( i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                            i_description in VARCHAR2,
                            i_count in integer,
                            i_codes in codes_table )
  is
    i  int;
    l_score      varchar2(100);
    l_code       IBY_MAPPINGS.MAPPING_CODE%TYPE;

  begin

       -- initialize the values.
       i := 1;

       -- loop through the list of ranges passed and update
       -- the database.
       -- delete the risk scodes and then insert;
       delete from iby_mappings
       where (( payeeid = i_payeeid) or
              ( payeeid is null and i_payeeid is null ))
          and mapping_type = 'RISK_CODE_TYPE';

       while ( i <= i_count ) loop
         -- extract the values from the input and insert in database.
         l_code  := i_codes(i).code;
         l_score := i_codes(i).score;
         i       := i+1;

         insert into iby_mappings ( payeeid, mapping_type, mapping_code, value,
                    last_update_date, last_updated_by, creation_date, created_by,object_version_number)
         values ( i_payeeid, 'RISK_CODE_TYPE', l_code, l_score,
                    sysdate, fnd_global.user_id, sysdate, fnd_global.user_id,1);

	 /*
         if ( SQL%ROWCOUNT = 0 ) then
            -- raise application error
            raise_application_error(-20000, 'Unable insert RISK CODES ');
         end if;
	 */
       end loop;
       commit;

  end save_riskcodes;

  /*
  ** Procedure: load_RiskCodes
  ** Purpose: loads  the RiskCodes factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads the sitelevel  entries.
  */
  procedure load_RiskCodes( i_payeeid in VARCHAR2,
                                o_name out nocopy VARCHAR2,
                            o_description out nocopy VARCHAR2,
                            o_codes out nocopy codes_table )
  is
  l_cnt int;

  l_payeeid varchar2(80);

  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'RISKCODES' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);


  cursor c_risk_codes(ci_payeeid varchar2) is
    select mapping_code lookup_code,value
    from iby_mappings
    where mapping_type = 'RISK_CODE_TYPE' and
          payeeid = ci_payeeid
    UNION
    select lookup_code,null
    from fnd_lookup_values
    where lookup_type = 'RISK_CODE' and
          enabled_flag = 'Y' and
          language = userenv('LANG') and

--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id) and

          lookup_code not in ( select mapping_code
                               from iby_mappings
                               where mapping_type = 'RISK_CODE_TYPE' and
                                     payeeid = ci_payeeid);


  cursor c_risk_codes2 is
    select lookup_code
    from
         fnd_lookup_values
    where
          lookup_type = 'RISK_CODE' and
          enabled_flag = 'Y' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);



  cursor c_del_risk_codes is
    select lookup_code
    from iby_mappings a,
         fnd_lookup_values b
    where b.lookup_type = 'RISK_CODE' and
          b.enabled_flag = 'N' and
          b.lookup_code = a.mapping_code and
          b.language = userenv('LANG');
--and
--b.security_group_id = fnd_global.lookup_security_group
--(b.lookup_type,b.view_application_id);

  --del_code c_del_risk_codes%ROWTYPE;

  cursor c_risk_codes_count(ci_payeeid varchar2) is
    select count(*)
    from iby_mappings
    where mapping_type = 'RISK_CODE_TYPE' and
          payeeid = ci_payeeid;
  begin
      --dbms_output.put_line(i_payeeid);

      l_payeeid := i_payeeid;
      if (c_del_risk_codes%isopen) then
            close c_del_risk_codes;
      end if;


      for i in c_del_risk_codes
        loop
          --dbms_output.put_line('inside delete loop');
             delete from iby_mappings
             where mapping_type = 'RISK_CODE_TYPE' and
                   mapping_code = i.lookup_code;
         end loop;
      if (l_payeeid is not null) then

         if (c_risk_codes_count%isopen) then
            close c_risk_codes_count;
         end if;
         open c_risk_codes_count(i_payeeid);
         fetch c_risk_codes_count into l_cnt;
         close c_risk_codes_count;
         if (l_cnt = 0) then
            l_payeeid := null;
         end if;

      end if;

      if (c_load_factor%isopen) then
         close c_load_factor;
      end if;

      if (c_risk_codes%isopen) then
          close c_risk_codes;
      end if;

      open c_load_factor;

      fetch c_load_factor into o_name, o_description;

      if (c_load_factor%notfound) then
         raise_application_error(-20000,'IBY_204201#');
      end if;
   if (l_payeeid is not null) then
      l_cnt := 1;

      for i in c_risk_codes(l_payeeid) loop
          o_codes(l_cnt).code := i.lookup_code;
          o_codes(l_cnt).score := i.value;
          l_cnt := l_cnt + 1;
      end loop;
  else
          l_cnt := 1;

      for i in c_risk_codes2 loop
          o_codes(l_cnt).code := i.lookup_code;
          o_codes(l_cnt).score := 'NR';
          l_cnt := l_cnt + 1;
      end loop;
 end if;
      --dbms_output.put_line('l_cnt = '||to_char(l_cnt));
      close c_load_factor;
      --close c_risk_codes;

  end;

  /*
  ** Procedure: save_CreditRatingCodes
  ** Purpose: Saves the CreditRatingCodes factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_CreditRatingCodes( i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_count in integer,
                                i_codes in codes_table )
  is
    i  int;
    l_score      varchar2(100);
    l_code       IBY_MAPPINGS.MAPPING_CODE%TYPE;

  begin

       -- Assumption, Ranges are verified in Java Code it self.

       -- initialize the values.
       i := 1;

       -- loop through the list of ranges passed and update
       -- the database.
       -- delete the existing config and insert new data.
       delete from iby_mappings
       where (( payeeid = i_payeeid) or
              ( payeeid is null and i_payeeid is null ))
          and mapping_type = 'CREDIT_CODE_TYPE';

       while ( i <= i_count ) loop

         -- extract the values from the input and insert in database.
         l_code  := i_codes(i).code;
         l_score := i_codes(i).score;
         i       := i+1;
         insert into iby_mappings ( payeeid, mapping_type, mapping_code, value,
                   last_update_date, last_updated_by, creation_date, created_by,object_version_number)
         values ( i_payeeid, 'CREDIT_CODE_TYPE', l_code, l_score,
                   sysdate, fnd_global.user_id, sysdate, fnd_global.user_id,1);

	 /*
         if ( SQL%ROWCOUNT = 0 ) then
            -- raise application error
            raise_application_error(-20000, 'Unable insert Credit Codes');
         end if;
	 */
       end loop;
    commit;
  end;

  /*
  ** Procedure: load_CreditRatingCodes
  ** Purpose: loads  the CreditRatingCodes factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          loads new entries.
  */
  procedure load_CreditRatingCodes( i_payeeid in VARCHAR2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_codes out nocopy codes_table )
  is

  l_cnt int;
  l_payeeid varchar2(80);


  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'CREDITRATINGCODES' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);


  cursor c_creditrating_codes(ci_payeeid varchar2) is
    select mapping_code lookup_code,value
    from iby_mappings
    where mapping_type = 'CREDIT_CODE_TYPE' and
          payeeid = ci_payeeid
    UNION
    select lookup_code,null
    from fnd_lookup_values
    where lookup_type = 'CREDIT_RATING' and
          enabled_flag = 'Y' and
          language = userenv('LANG') and

--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id) and

          lookup_code not in ( select mapping_code
                               from iby_mappings
                               where mapping_type = 'CREDIT_CODE_TYPE' and
                                     payeeid = ci_payeeid);


  cursor c_creditrating_codes2 is
    select lookup_code
    from
         fnd_lookup_values
    where
          lookup_type = 'CREDIT_RATING' and
          enabled_flag = 'Y' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);

  cursor c_del_creditrating_codes is
    select lookup_code
    from iby_mappings a,
         fnd_lookup_values b
    where b.lookup_type = 'CREDIT_RATING' and
          b.enabled_flag = 'N' and
          b.lookup_code = a.mapping_code and
          b.language = userenv('LANG');
--and
--b.security_group_id = fnd_global.lookup_security_group
--(b.lookup_type,b.view_application_id);


  cursor c_creditrating_codes_count(ci_payeeid varchar2) is
    select count(*)
    from iby_mappings
    where mapping_type = 'CREDIT_CODE_TYPE' and
          payeeid = ci_payeeid;

  begin
      --dbms_output.put_line(i_payeeid);
      l_payeeid := i_payeeid;
      if (c_del_creditrating_codes%isopen) then
            close c_del_creditrating_codes;
      end if;

      for i in c_del_creditrating_codes
        loop
             delete from iby_mappings
             where mapping_type = 'CREDIT_CODE_TYPE' and
                   mapping_code = i.lookup_code;
         end loop;
      if (l_payeeid is not null) then

         if (c_creditrating_codes_count%isopen) then
            close c_creditrating_codes_count;
         end if;
         open c_creditrating_codes_count(i_payeeid);
         fetch c_creditrating_codes_count into l_cnt;
         close c_creditrating_codes_count;
         if (l_cnt = 0) then
            l_payeeid := null;
         end if;
      end if;

      if (c_load_factor%isopen) then
         close c_load_factor;
      end if;

      if (c_creditrating_codes%isopen) then
          close c_creditrating_codes;
      end if;

      open c_load_factor;

      fetch c_load_factor into o_name, o_description;

      if (c_load_factor%notfound) then
         raise_application_error(-20000,'IBY_204201#');
      end if;
    if (l_payeeid is not null) then
      l_cnt := 1;

      for i in c_creditrating_codes(l_payeeid) loop
          o_codes(l_cnt).code := i.lookup_code;
          o_codes(l_cnt).score := i.value;
          l_cnt := l_cnt + 1;
      end loop;
    else
           l_cnt := 1;

      for i in c_creditrating_codes2 loop
          o_codes(l_cnt).code := i.lookup_code;
          o_codes(l_cnt).score := 'S';
          l_cnt := l_cnt + 1;
      end loop;
     end if;
      close c_load_factor;
    --  close c_creditrating_codes;

  end;

  /*
  ** Procedure: save_FreqOfPurchase
  ** Purpose: Saves the FreqOfPurchase factor configuration into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_FreqOfPurchase(i_payeeid in VARCHAR2,
                                i_name in VARCHAR2,
                                i_description in VARCHAR2,
                                i_duration in integer,
                                i_durationType in VARCHAR2,
                                i_frequency in integer )
  is
  begin

    -- update the FreqOfPurchase information. If payeeid is not null
    -- and payeeid does not have configured information then
    -- insert the configuration information.
    update iby_irf_pmt_frequency
        set duration = i_duration,
            duration_type = i_durationType,
            frequency = i_frequency,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id
        where ( ( payeeid is null and i_payeeid is null ) or
                   ( payeeid = i_payeeid ));

    -- if no data configured.
    if ( SQL%ROWCOUNT = 0 ) then
        -- insert the data.
        insert into iby_irf_pmt_frequency ( duration, duration_type,
                frequency, payeeid, object_version_number,
                last_update_date, last_updated_by, creation_date, created_by)
        values ( i_duration, i_durationType, i_frequency, i_payeeid,1,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id);
	/*
        -- if it could not insert the rows.
        if ( SQL%ROWCOUNT = 0 ) then
            -- raise application error
            raise_application_error(-20000, 'IBY_204215#');
        end if;
	*/
    end if;

     -- commit the changes;
     commit;

  end;

  /*
  ** Procedure: load_FreqOfPurchase
  ** Purpose: loads  the FreqOfPurchase factor configuration into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level configuration values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          creates new entries.
  */
  procedure load_FreqOfPurchase(i_payeeid in VARCHAR2,
                                o_name out nocopy VARCHAR2,
                                o_description out nocopy VARCHAR2,
                                o_duration out nocopy integer,
                                o_durationType out nocopy VARCHAR2,
                                o_frequency out nocopy integer )
  is

    l_payeeid varchar2(80);
    l_cnt integer;

  cursor c_load_factor is
    select meaning, description
    from FND_LOOKUP_VALUES
    where
          lookup_code  = 'FREQOFPURCHASE' and
          lookup_type = 'IBY_RISK_FACTOR_NAME' and
          language = userenv('LANG');
--and
--security_group_id = fnd_global.lookup_security_group
--(lookup_type,view_application_id);


  cursor c_pmt_freq(ci_payeeid varchar2) is
    select duration, duration_type, frequency
    from iby_irf_pmt_frequency
    where (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid));

  cursor c_pmt_freq_count(ci_payeeid varchar2) is
    select count(*)
    from iby_irf_pmt_frequency
    where payeeid = ci_payeeid;

  begin

    -- check whether payee id is not null or not. If payeeid is
    -- not null then check whether the payeeid has any information
    -- configured. if not then default values should be loaded.
    -- For default values payeeid will be null.
    l_payeeid := i_payeeid;
    if ( l_payeeid is not null ) then
        if ( c_pmt_freq_count%isopen ) then
             close c_pmt_freq;
        end if;
        open c_pmt_freq_count(i_payeeid);
        fetch c_pmt_freq_count into l_cnt;
        close c_pmt_freq_count;
        -- set it to null if payeeid does not have any configured
        -- information.
        if ( l_cnt = 0) then
            l_payeeid := null;
        end if;
    end if;


    -- close all the open cursors, if any.
    if ( c_load_factor%isopen )then
      close c_load_factor;
    end if;

    if ( c_pmt_freq%isopen )then
      close c_pmt_freq;
    end if;

    -- open cursors.
    open c_load_factor;
    open c_pmt_freq(l_payeeid);

    -- load the factor information.
    fetch c_load_factor into o_name, o_description;
    -- if factor information is not present then raise exception.
    if ( c_load_factor%notfound ) then
       raise_application_error(-20000,'IBY_204201#');
    end if;
    -- load the factor configured data.
    fetch c_pmt_freq into o_duration, o_durationType, o_frequency;

    -- close the cursors.
    close c_pmt_freq;
    close c_load_factor;

  end;

  /*
  ** Procedure: save_RiskScores
  ** Purpose: Saves the RiskScores information into
  **          database. Checks if payeeid is null or not, if it is
  **          null then updates the site level RiskScores values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then updates them otherwise
  **          creates new entries.
  */
  procedure save_RiskScores(    i_payeeid in VARCHAR2,
                                i_lowval in integer,
                                i_lowMedVal in integer,
                                i_medVal in integer,
                                i_medHighVal in integer,
                                i_highVal in integer )
  is
  begin

    -- update the risk scores based on the payeeid.
    update iby_mappings
      set value = i_lowVal,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      where mapping_code = 'L'
        and mapping_type = 'IBY_RISK_SCORE_TYPE'
        and (( payeeid is null and i_payeeid is null ) or
            (payeeid = i_payeeid) );

    -- if count is zero then insert new rows for all the scores.
    -- otherwise update the other risk Score rows.
    if ( SQL%ROWCOUNT = 0 ) then
        insert into iby_mappings( value, mapping_code, mapping_type, payeeid,
                last_update_date, last_updated_by, creation_date, created_by, object_version_number)
        values( 0, 'S', 'IBY_RISK_SCORE_TYPE', i_payeeid,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, 1);

        insert into iby_mappings( value, mapping_code, mapping_type, payeeid,
                last_update_date, last_updated_by, creation_date, created_by, object_version_number)
        values( 0, 'NR', 'IBY_RISK_SCORE_TYPE', i_payeeid,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, 1);

        insert into iby_mappings( value, mapping_code, mapping_type, payeeid,
                last_update_date, last_updated_by, creation_date, created_by, object_version_number)
        values( i_lowVal, 'L', 'IBY_RISK_SCORE_TYPE', i_payeeid,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, 1);

        insert into iby_mappings( value, mapping_code, mapping_type, payeeid,
                last_update_date, last_updated_by, creation_date, created_by, object_version_number)
        values( i_lowMedVal, 'LM', 'IBY_RISK_SCORE_TYPE', i_payeeid,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, 1);

        insert into iby_mappings( value, mapping_code, mapping_type, payeeid,
                last_update_date, last_updated_by, creation_date, created_by, object_version_number)
        values( i_medVal, 'M', 'IBY_RISK_SCORE_TYPE', i_payeeid,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, 1);

        insert into iby_mappings( value, mapping_code, mapping_type, payeeid,
                last_update_date, last_updated_by, creation_date, created_by, object_version_number)
        values( i_medHighVal, 'MH', 'IBY_RISK_SCORE_TYPE', i_payeeid,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, 1);

        insert into iby_mappings( value, mapping_code, mapping_type, payeeid,
                last_update_date, last_updated_by, creation_date, created_by, object_version_number)
        values( i_highVal, 'H', 'IBY_RISK_SCORE_TYPE', i_payeeid,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, 1);
    else

      update iby_mappings
      set value = i_lowMedVal,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      where mapping_code = 'LM'
        and mapping_type = 'IBY_RISK_SCORE_TYPE'
        and (( payeeid is null and i_payeeid is null ) or
            (payeeid = i_payeeid) );

      update iby_mappings
      set value = i_medVal,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      where mapping_code = 'M'
        and mapping_type = 'IBY_RISK_SCORE_TYPE'
        and (( payeeid is null and i_payeeid is null ) or
            (payeeid = i_payeeid) );

      update iby_mappings
      set value = i_medHighVal,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      where mapping_code = 'MH'
        and mapping_type = 'IBY_RISK_SCORE_TYPE'
        and (( payeeid is null and i_payeeid is null ) or
            (payeeid = i_payeeid) );

      update iby_mappings
      set value = i_highVal,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      where mapping_code = 'H'
        and mapping_type = 'IBY_RISK_SCORE_TYPE'
        and (( payeeid is null and i_payeeid is null ) or
            (payeeid = i_payeeid) );
    end if;

     -- commit the changes;
     commit;
  end;

  /*
  ** Procedure: load_RiskScores
  ** Purpose: loads  the RiskScores information into
  **          output parameters. Checks if payeeid is null or not, if it is
  **          null then loads the site level RiskScore values
  **          otherwise checks if payee already has some entries.
  **          if payee has entries then loads them otherwise
  **          retrieves new entries.
  */
  procedure load_RiskScores(    i_payeeid in VARCHAR2,
                                o_lowval out nocopy integer,
                                o_lowMedVal out nocopy integer,
                                o_medVal out nocopy integer,
                                o_medHighVal out nocopy integer,
                                o_highVal out nocopy integer )
  is

    l_payeeid varchar2(80);
    l_cnt integer;

  cursor c_insert_scores( ci_code in iby_mappings.mapping_code%type,
                          ci_payeeid varchar2)
  is
    select value
    from iby_mappings
    where mapping_code = ci_code
      and mapping_type = 'IBY_RISK_SCORE_TYPE'
      and (( payeeid is null and ci_payeeid is null ) or
          ( payeeid = ci_payeeid));

  cursor c_payee_scores_count(ci_payeeid varchar2)
  is
    select count(*)
    from iby_mappings
    where mapping_type = 'IBY_RISK_SCORE_TYPE'
      and  payeeid = ci_payeeid;

  begin

    -- check whether payee id is not null or not. If payeeid is
    -- not null then check whether the payeeid has any information
    -- configured. if not then default values should be loaded.
    -- For default values payeeid will be null.
    l_payeeid := i_payeeid;
    if ( i_payeeid is not null ) then
        if ( c_payee_scores_count%isopen ) then
             close c_payee_scores_count;
        end if;
        open c_payee_scores_count(i_payeeid);
        fetch c_payee_scores_count into l_cnt;
        close c_payee_scores_count;
        if ( l_cnt = 0) then
            l_payeeid := null;
        end if;
    end if;

    if ( c_insert_scores%isopen ) then
      close c_insert_scores;
    end if;

    -- retrieve risk scores for each different type.
    open c_insert_scores('L', l_payeeid);
    fetch c_insert_scores into o_lowVal;
    close c_insert_scores;

    open c_insert_scores('LM', l_payeeid);
    fetch c_insert_scores into o_lowMedVal;
    close c_insert_scores;

    open c_insert_scores('M', l_payeeid);
    fetch c_insert_scores into o_medVal;
    close c_insert_scores;

    open c_insert_scores('MH', l_payeeid);
    fetch c_insert_scores into o_medHighVal;
    close c_insert_scores;

    open c_insert_scores('H', l_payeeid);
    fetch c_insert_scores into o_highVal;
    close c_insert_scores;

  end;


end iby_factor_pkg;



/
