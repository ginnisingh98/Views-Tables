--------------------------------------------------------
--  DDL for Package Body IBY_FACTOR_PKG_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FACTOR_PKG_WRAP" AS
/*$Header: ibywfacb.pls 115.9 2002/11/18 23:15:01 jleybovi ship $*/

/*
** Wrapper package generated by Rosette for iby_fact_pkg.
*/

  /*
  ** Name : save_paymentAmount
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure save_paymentamount(i_payeeid varchar2,
    i_name  varchar2,
    i_description  varchar2,
    i_count  integer,
    i_amountranges_lowamtlmt JTF_NUMBER_TABLE,
    i_amountranges_upramtlmt JTF_NUMBER_TABLE,
    i_amountranges_seq JTF_NUMBER_TABLE,
    i_amountranges_score JTF_VARCHAR2_TABLE_100)

  is
    ddi_amountranges iby_factor_pkg.amountrange_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    --dbms_output.put_line('Entered the procedure PAyment amount');


    if i_amountranges_lowamtlmt is not null and
        i_amountranges_lowamtlmt.count > 0 then
        if i_amountranges_lowamtlmt.count > 0 then
            indx := i_amountranges_lowamtlmt.first;
            ddindx := 1;
            while true loop
                ddi_amountranges(ddindx).lowamtlmt := i_amountranges_lowamtlmt(indx);
                ddi_amountranges(ddindx).upramtlmt := i_amountranges_upramtlmt(indx);
                ddi_amountranges(ddindx).seq := i_amountranges_seq(indx);
                ddi_amountranges(ddindx).score := i_amountranges_score(indx);
                ddindx := ddindx+1;
                if i_amountranges_lowamtlmt.last =indx then
                    exit;
                end if;
                indx := i_amountranges_lowamtlmt.next(indx);
             end loop;
         end if;
     end if;

    --dbms_output.put_line('index is '|| indx);
    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.save_paymentamount(i_payeeid, i_name,
      i_description,
      i_count,
      ddi_amountranges);

    -- copy data back from the local OUT or IN-OUT args, if any


  end save_paymentamount;

  /*
  ** Name : load_paymentAmount
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure load_paymentamount(i_payeeid varchar2,
    o_name out nocopy varchar2,
    o_description out nocopy varchar2,
    o_amountranges_lowamtlmt out nocopy JTF_NUMBER_TABLE,
    o_amountranges_upramtlmt out nocopy JTF_NUMBER_TABLE,
    o_amountranges_seq out nocopy JTF_NUMBER_TABLE,
    o_amountranges_score out nocopy JTF_VARCHAR2_TABLE_100)

  is
    ddo_amountranges iby_factor_pkg.amountrange_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.load_paymentamount(i_payeeid, o_name,
      o_description, ddo_amountranges);

    -- copy data back from the local OUT or IN-OUT args, if any

    if ddo_amountranges is null or ddo_amountranges.count = 0 then
      o_amountranges_lowamtlmt := JTF_NUMBER_TABLE();
      o_amountranges_upramtlmt := JTF_NUMBER_TABLE();
      o_amountranges_seq := JTF_NUMBER_TABLE();
      o_amountranges_score := JTF_VARCHAR2_TABLE_100();
    else
        o_amountranges_lowamtlmt := JTF_NUMBER_TABLE();
        o_amountranges_upramtlmt := JTF_NUMBER_TABLE();
        o_amountranges_seq := JTF_NUMBER_TABLE();
        o_amountranges_score := JTF_VARCHAR2_TABLE_100();
        if ddo_amountranges.count > 0 then
          o_amountranges_lowamtlmt.extend(ddo_amountranges.count);
          o_amountranges_upramtlmt.extend(ddo_amountranges.count);
          o_amountranges_seq.extend(ddo_amountranges.count);
          o_amountranges_score.extend(ddo_amountranges.count);
          ddindx := ddo_amountranges.first;
          indx := 1;
          while true loop
            o_amountranges_lowamtlmt(indx) := ddo_amountranges(ddindx).lowamtlmt;
            o_amountranges_upramtlmt(indx) := ddo_amountranges(ddindx).upramtlmt;
            o_amountranges_seq(indx) := ddo_amountranges(ddindx).seq;
            o_amountranges_score(indx) := ddo_amountranges(ddindx).score;
            indx := indx+1;
            if ddo_amountranges.last =ddindx
              then exit;
            end if;
            ddindx := ddo_amountranges.next(ddindx);
            --dbms_output.put_line('index is ' || indx );
            --dbms_output.put_line('ddindex is ' || ddindx );
          end loop;
        end if;
     end if;
  end load_paymentamount;

  /*
  ** Name : save_timeofpurchase
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure save_timeofpurchase(i_payeeid varchar2,
    i_name  varchar2,
    i_description  varchar2,
    i_count  integer,
    i_timeranges_lowtimelmt JTF_NUMBER_TABLE,
    i_timeranges_uprtimelmt JTF_NUMBER_TABLE,
    i_timeranges_seq JTF_NUMBER_TABLE,
    i_timeranges_score JTF_VARCHAR2_TABLE_100)

  is
    ddi_timeranges iby_factor_pkg.timerange_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if i_timeranges_lowtimelmt is not null and
       i_timeranges_lowtimelmt.count > 0 then
        if i_timeranges_lowtimelmt.count > 0 then
          indx := i_timeranges_lowtimelmt.first;
          ddindx := 1;
          while true loop
            ddi_timeranges(ddindx).lowtimelmt := i_timeranges_lowtimelmt(indx);
            ddi_timeranges(ddindx).uprtimelmt := i_timeranges_uprtimelmt(indx);
            ddi_timeranges(ddindx).seq := i_timeranges_seq(indx);
            ddi_timeranges(ddindx).score := i_timeranges_score(indx);
            ddindx := ddindx+1;
            if i_timeranges_lowtimelmt.last =indx
              then exit;
            end if;
            indx := i_timeranges_lowtimelmt.next(indx);
          end loop;
        end if;
     end if;

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.save_timeofpurchase(i_payeeid, i_name,
      i_description,
      i_count,
      ddi_timeranges);

    -- copy data back from the local OUT or IN-OUT args, if any

  end save_timeofpurchase;

  /*
  ** Name : load_timeofpurchase
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure load_timeofpurchase(i_payeeid varchar2,
    o_name out nocopy varchar2,
    o_description out nocopy varchar2,
    o_timeranges_lowtimelmt out nocopy JTF_NUMBER_TABLE,
    o_timeranges_uprtimelmt out nocopy JTF_NUMBER_TABLE,
    o_timeranges_seq out nocopy JTF_NUMBER_TABLE,
    o_timeranges_score out nocopy JTF_VARCHAR2_TABLE_100)

  is
    ddo_timeranges iby_factor_pkg.timerange_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.load_timeofpurchase(i_payeeid, o_name,
      o_description,
      ddo_timeranges);

    -- copy data back from the local OUT or IN-OUT args, if any


    if ddo_timeranges is null or ddo_timeranges.count = 0 then
      o_timeranges_lowtimelmt := JTF_NUMBER_TABLE();
      o_timeranges_uprtimelmt := JTF_NUMBER_TABLE();
      o_timeranges_seq := JTF_NUMBER_TABLE();
      o_timeranges_score := JTF_VARCHAR2_TABLE_100();
    else
        o_timeranges_lowtimelmt := JTF_NUMBER_TABLE();
        o_timeranges_uprtimelmt := JTF_NUMBER_TABLE();
        o_timeranges_seq := JTF_NUMBER_TABLE();
        o_timeranges_score := JTF_VARCHAR2_TABLE_100();
        if ddo_timeranges.count > 0 then
          o_timeranges_lowtimelmt.extend(ddo_timeranges.count);
          o_timeranges_uprtimelmt.extend(ddo_timeranges.count);
          o_timeranges_seq.extend(ddo_timeranges.count);
          o_timeranges_score.extend(ddo_timeranges.count);
          ddindx := ddo_timeranges.first;
          indx := 1;
          while true loop
            o_timeranges_lowtimelmt(indx) := ddo_timeranges(ddindx).lowtimelmt;
            o_timeranges_uprtimelmt(indx) := ddo_timeranges(ddindx).uprtimelmt;
            o_timeranges_seq(indx) := ddo_timeranges(ddindx).seq;
            o_timeranges_score(indx) := ddo_timeranges(ddindx).score;
            indx := indx+1;
            if ddo_timeranges.last =ddindx
              then exit;
            end if;
            ddindx := ddo_timeranges.next(ddindx);
          end loop;
        end if;
     end if;
  end load_timeofpurchase;

  /*
  ** Name : save_paymenthistory
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure save_paymenthistory(i_payeeid varchar2,
    i_name  varchar2,
    i_description  varchar2,
    i_duration  number,
    i_durationtype  varchar2,
    i_count  integer,
    i_freqranges_lowfreqlmt JTF_NUMBER_TABLE,
    i_freqranges_uprfreqlmt JTF_NUMBER_TABLE,
    i_freqranges_seq JTF_NUMBER_TABLE,
    i_freqranges_score JTF_VARCHAR2_TABLE_100)

  is
    ddi_freqranges iby_factor_pkg.freqrange_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if i_freqranges_lowfreqlmt is not null and
       i_freqranges_lowfreqlmt.count > 0 then
        if i_freqranges_lowfreqlmt.count > 0 then
          indx := i_freqranges_lowfreqlmt.first;
          ddindx := 1;
          while true loop
            ddi_freqranges(ddindx).lowfreqlmt := i_freqranges_lowfreqlmt(indx);
            ddi_freqranges(ddindx).uprfreqlmt := i_freqranges_uprfreqlmt(indx);
            ddi_freqranges(ddindx).seq := i_freqranges_seq(indx);
            ddi_freqranges(ddindx).score := i_freqranges_score(indx);
            ddindx := ddindx+1;
            if i_freqranges_lowfreqlmt.last =indx
              then exit;
            end if;
            indx := i_freqranges_lowfreqlmt.next(indx);
          end loop;
        end if;
     end if;

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.save_paymenthistory(i_payeeid, i_name,
      i_description,
      i_duration,
      i_durationtype,
      i_count,
      ddi_freqranges);

    -- copy data back from the local OUT or IN-OUT args, if any

  end save_paymenthistory;

  /*
  ** Name : load_paymenthistory
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure load_paymenthistory(i_payeeid varchar2,
    o_name out nocopy varchar2,
    o_description out nocopy varchar2,
    o_duration out nocopy number,
    o_durationtype out nocopy varchar2,
    o_freqranges_lowfreqlmt out nocopy JTF_NUMBER_TABLE,
    o_freqranges_uprfreqlmt out nocopy JTF_NUMBER_TABLE,
    o_freqranges_seq out nocopy JTF_NUMBER_TABLE,
    o_freqranges_score out nocopy JTF_VARCHAR2_TABLE_100)

  is
    ddo_freqranges iby_factor_pkg.freqrange_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.load_paymenthistory(i_payeeid, o_name,
      o_description,
      o_duration,
      o_durationtype,
      ddo_freqranges);

    -- copy data back from the local OUT or IN-OUT args, if any

    if ddo_freqranges is null or ddo_freqranges.count = 0 then
      o_freqranges_lowfreqlmt := JTF_NUMBER_TABLE();
      o_freqranges_uprfreqlmt := JTF_NUMBER_TABLE();
      o_freqranges_seq := JTF_NUMBER_TABLE();
      o_freqranges_score := JTF_VARCHAR2_TABLE_100();
    else
        o_freqranges_lowfreqlmt := JTF_NUMBER_TABLE();
        o_freqranges_uprfreqlmt := JTF_NUMBER_TABLE();
        o_freqranges_seq := JTF_NUMBER_TABLE();
        o_freqranges_score := JTF_VARCHAR2_TABLE_100();
        if ddo_freqranges.count > 0 then
          o_freqranges_lowfreqlmt.extend(ddo_freqranges.count);
          o_freqranges_uprfreqlmt.extend(ddo_freqranges.count);
          o_freqranges_seq.extend(ddo_freqranges.count);
          o_freqranges_score.extend(ddo_freqranges.count);
          ddindx := ddo_freqranges.first;
          indx := 1;
          while true loop
            o_freqranges_lowfreqlmt(indx) := ddo_freqranges(ddindx).lowfreqlmt;
            o_freqranges_uprfreqlmt(indx) := ddo_freqranges(ddindx).uprfreqlmt;
            o_freqranges_seq(indx) := ddo_freqranges(ddindx).seq;
            o_freqranges_score(indx) := ddo_freqranges(ddindx).score;
            indx := indx+1;
            if ddo_freqranges.last =ddindx
              then exit;
            end if;
            ddindx := ddo_freqranges.next(ddindx);
          end loop;
        end if;
     end if;
  end load_paymenthistory;

  /*
  ** Name : save_avsCodes
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure save_avscodes(i_payeeid varchar2,
    i_name  varchar2,
    i_description  varchar2,
    i_count  integer,
    i_codes_code JTF_VARCHAR2_TABLE_100,
    i_codes_score JTF_VARCHAR2_TABLE_100)

  is
    ddi_codes iby_factor_pkg.codes_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if i_codes_code is not null and i_codes_code.count > 0 then
        if i_codes_code.count > 0 then
          indx := i_codes_code.first;
          ddindx := 1;
          while true loop
            ddi_codes(ddindx).code := i_codes_code(indx);
            ddi_codes(ddindx).score := i_codes_score(indx);
            ddindx := ddindx+1;
            if i_codes_code.last =indx
              then exit;
            end if;
            indx := i_codes_code.next(indx);
          end loop;
        end if;
     end if;

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.save_avscodes(i_payeeid, i_name,
      i_description,
      i_count,
      ddi_codes);

    -- copy data back from the local OUT or IN-OUT args, if any

  end save_avscodes;

  /*
  ** Name : load_avsCodes
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure load_avscodes(i_payeeid varchar2,
    o_name out nocopy varchar2,
    o_description out nocopy varchar2,
    o_codes_code out nocopy JTF_VARCHAR2_TABLE_100,
    o_codes_score out nocopy JTF_VARCHAR2_TABLE_100)

  is
    ddo_codes iby_factor_pkg.codes_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.load_avscodes(i_payeeid, o_name,
      o_description,
      ddo_codes);

    -- copy data back from the local OUT or IN-OUT args, if any


    if ddo_codes is null or ddo_codes.count = 0 then
      o_codes_code := JTF_VARCHAR2_TABLE_100();
      o_codes_score := JTF_VARCHAR2_TABLE_100();
    else
       o_codes_code := JTF_VARCHAR2_TABLE_100();
       o_codes_score := JTF_VARCHAR2_TABLE_100();
       if ddo_codes.count > 0 then
          o_codes_code.extend(ddo_codes.count);
          o_codes_score.extend(ddo_codes.count);
          ddindx := ddo_codes.first;
          indx := 1;
          while true loop
            o_codes_code(indx) := ddo_codes(ddindx).code;
            o_codes_score(indx) := ddo_codes(ddindx).score;
            indx := indx+1;
            if ddo_codes.last =ddindx
              then exit;
            end if;
            ddindx := ddo_codes.next(ddindx);
          end loop;
        end if;
     end if;
  end load_avscodes;

  /*
  ** Name : save_riskCodes
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure save_riskcodes(i_payeeid varchar2,
    i_name  varchar2,
    i_description  varchar2,
    i_count  integer,
    i_codes_code JTF_VARCHAR2_TABLE_100,
    i_codes_score JTF_VARCHAR2_TABLE_100)

  is
    ddi_codes iby_factor_pkg.codes_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if i_codes_code is not null and i_codes_code.count > 0 then
        if i_codes_code.count > 0 then
          indx := i_codes_code.first;
          ddindx := 1;
          while true loop
            ddi_codes(ddindx).code := i_codes_code(indx);
            ddi_codes(ddindx).score := i_codes_score(indx);
            ddindx := ddindx+1;
            if i_codes_code.last =indx
              then exit;
            end if;
            indx := i_codes_code.next(indx);
          end loop;
        end if;
     end if;

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.save_riskcodes(i_payeeid, i_name,
      i_description,
      i_count,
      ddi_codes);

    -- copy data back from the local OUT or IN-OUT args, if any

  end save_riskcodes;

  /*
  ** Name : load_riskCodes
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure load_riskcodes(i_payeeid varchar2,
    o_name out nocopy varchar2,
    o_description out nocopy varchar2,
    o_codes_code out nocopy JTF_VARCHAR2_TABLE_100,
    o_codes_score out nocopy JTF_VARCHAR2_TABLE_100)

  is
    ddo_codes iby_factor_pkg.codes_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.load_riskcodes(i_payeeid, o_name,
      o_description,
      ddo_codes);

    -- copy data back from the local OUT or IN-OUT args, if any


    if ddo_codes is null or ddo_codes.count = 0 then
      o_codes_code := JTF_VARCHAR2_TABLE_100();
      o_codes_score := JTF_VARCHAR2_TABLE_100();
    else
        o_codes_code := JTF_VARCHAR2_TABLE_100();
        o_codes_score := JTF_VARCHAR2_TABLE_100();
        if ddo_codes.count > 0 then
          o_codes_code.extend(ddo_codes.count);
          o_codes_score.extend(ddo_codes.count);
          ddindx := ddo_codes.first;
          indx := 1;
          while true loop
            o_codes_code(indx) := ddo_codes(ddindx).code;
            o_codes_score(indx) := ddo_codes(ddindx).score;
            indx := indx+1;
            if ddo_codes.last =ddindx
              then exit;
            end if;
            ddindx := ddo_codes.next(ddindx);
          end loop;
        end if;
     end if;
  end load_riskcodes;

  /*
  ** Name : save_creditratingcodes
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure save_creditratingcodes(i_payeeid varchar2,
    i_name  varchar2,
    i_description  varchar2,
    i_count  integer,
    i_codes_code JTF_VARCHAR2_TABLE_100,
    i_codes_score JTF_VARCHAR2_TABLE_100)

  is
    ddi_codes iby_factor_pkg.codes_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if i_codes_code is not null and i_codes_code.count > 0 then
        if i_codes_code.count > 0 then
          indx := i_codes_code.first;
          ddindx := 1;
          while true loop
            ddi_codes(ddindx).code := i_codes_code(indx);
            ddi_codes(ddindx).score := i_codes_score(indx);
            ddindx := ddindx+1;
            if i_codes_code.last =indx
              then exit;
            end if;
            indx := i_codes_code.next(indx);
          end loop;
        end if;
     end if;

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.save_creditratingcodes(i_payeeid, i_name,
      i_description,
      i_count,
      ddi_codes);

    -- copy data back from the local OUT or IN-OUT args, if any

  end save_creditratingcodes;

  /*
  ** Name : load_creditratingcodes
  ** Purpose : Wrapper function generated by Rosette to call the actual ]
  **           function in iby_fact_pkg. This wrapper constructs actual
  **           structure from the flatten structure and flattens the
  **           response from the original procedure.
  */
  procedure load_creditratingcodes(i_payeeid varchar2,
    o_name out nocopy varchar2,
    o_description out nocopy varchar2,
    o_codes_code out nocopy JTF_VARCHAR2_TABLE_100,
    o_codes_score out nocopy JTF_VARCHAR2_TABLE_100)

  is
    ddo_codes iby_factor_pkg.codes_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    iby_factor_pkg.load_creditratingcodes(i_payeeid, o_name,
      o_description,
      ddo_codes);

    -- copy data back from the local OUT or IN-OUT args, if any


    if ddo_codes is null or ddo_codes.count = 0 then
      o_codes_code := JTF_VARCHAR2_TABLE_100();
      o_codes_score := JTF_VARCHAR2_TABLE_100();
    else
      o_codes_code := JTF_VARCHAR2_TABLE_100();
      o_codes_score := JTF_VARCHAR2_TABLE_100();
      if ddo_codes.count > 0 then
          o_codes_code.extend(ddo_codes.count);
          o_codes_score.extend(ddo_codes.count);
          ddindx := ddo_codes.first;
          indx := 1;
          while true loop
            o_codes_code(indx) := ddo_codes(ddindx).code;
            o_codes_score(indx) := ddo_codes(ddindx).score;
            indx := indx+1;
            if ddo_codes.last =ddindx
              then exit;
            end if;
            ddindx := ddo_codes.next(ddindx);
          end loop;
       end if;
     end if;
  end  load_creditratingcodes;

end iby_factor_pkg_wrap;


/
