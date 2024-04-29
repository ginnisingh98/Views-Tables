--------------------------------------------------------
--  DDL for Package Body IBY_RISKYINSTR_PKG_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_RISKYINSTR_PKG_WRAP" as
/*$Header: ibyrkwrb.pls 115.4 2002/11/20 00:00:26 jleybovi ship $*/

  procedure add_riskyinstr(i_count  integer,
    i_riskyinstr_payeeid JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_instrtype JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_routing_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_account_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_creditcard_num JTF_VARCHAR2_TABLE_100,
    o_results_success out nocopy JTF_NUMBER_TABLE,
    o_results_errmsg out nocopy JTF_VARCHAR2_TABLE_100)

  is

   ddi_riskyinstr iby_riskyinstr_pkg.riskyinstr_table;
   ddo_results iby_riskyinstr_pkg.result_table;
   ddindx binary_integer;
   indx binary_integer;

  begin

    -- copy data to the local IN or IN-OUT args, if any

    if i_riskyinstr_payeeid is not null and i_riskyinstr_payeeid.count > 0 then
        if i_riskyinstr_payeeid.count > 0 then
          indx := i_riskyinstr_payeeid.first;
          ddindx := 1;
          while true loop
            ddi_riskyinstr(ddindx).payeeid := i_riskyinstr_payeeid(indx);
            ddi_riskyinstr(ddindx).instrtype := i_riskyinstr_instrtype(indx);
            ddi_riskyinstr(ddindx).routing_num := i_riskyinstr_routing_num(indx);
            ddi_riskyinstr(ddindx).account_num := i_riskyinstr_account_num(indx);
            ddi_riskyinstr(ddindx).creditcard_num := i_riskyinstr_creditcard_num(indx);
            ddindx := ddindx+1;
            if i_riskyinstr_payeeid.last =indx
              then exit;
            end if;
            indx := i_riskyinstr_payeeid.next(indx);
          end loop;
        end if;
     end if;


    -- here's the delegated call to the old PL/SQL routine
    iby_riskyinstr_pkg.add_riskyinstr(i_count,
      ddi_riskyinstr,
      ddo_results);

    -- copy data back from the local OUT or IN-OUT args, if any


    if ddo_results is null or ddo_results.count = 0 then
      o_results_success := JTF_NUMBER_TABLE();
      o_results_errmsg := JTF_VARCHAR2_TABLE_100();
    else
        o_results_success := JTF_NUMBER_TABLE();
        o_results_errmsg := JTF_VARCHAR2_TABLE_100();
        if ddo_results.count > 0 then
          o_results_success.extend(ddo_results.count);
          o_results_errmsg.extend(ddo_results.count);
          ddindx := ddo_results.first;
          indx := 1;
          while true loop
            o_results_success(indx) := ddo_results(ddindx).success;
            o_results_errmsg(indx) := ddo_results(ddindx).errmsg;
            indx := indx+1;
            if ddo_results.last =ddindx
              then exit;
            end if;
            ddindx := ddo_results.next(ddindx);
          end loop;
        end if;
     end if;
  end;

  procedure delete_riskyinstr(i_count  integer,
    i_riskyinstr_payeeid JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_instrtype JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_routing_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_account_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_creditcard_num JTF_VARCHAR2_TABLE_100,
    o_results_success out nocopy JTF_NUMBER_TABLE,
    o_results_errmsg out nocopy JTF_VARCHAR2_TABLE_100)

  is
    ddi_riskyinstr iby_riskyinstr_pkg.riskyinstr_table;
    ddo_results iby_riskyinstr_pkg.result_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if i_riskyinstr_payeeid is not null and i_riskyinstr_payeeid.count > 0 then
        if i_riskyinstr_payeeid.count > 0 then
          indx := i_riskyinstr_payeeid.first;
          ddindx := 1;
          while true loop
            ddi_riskyinstr(ddindx).payeeid := i_riskyinstr_payeeid(indx);
            ddi_riskyinstr(ddindx).instrtype := i_riskyinstr_instrtype(indx);
            ddi_riskyinstr(ddindx).routing_num := i_riskyinstr_routing_num(indx);
            ddi_riskyinstr(ddindx).account_num := i_riskyinstr_account_num(indx);
            ddi_riskyinstr(ddindx).creditcard_num := i_riskyinstr_creditcard_num(indx);
            ddindx := ddindx+1;
            if i_riskyinstr_payeeid.last =indx
              then exit;
            end if;
            indx := i_riskyinstr_payeeid.next(indx);
          end loop;
        end if;
     end if;


    -- here's the delegated call to the old PL/SQL routine
    iby_riskyinstr_pkg.delete_riskyinstr(i_count,
      ddi_riskyinstr,
      ddo_results);

    -- copy data back from the local OUT or IN-OUT args, if any


    if ddo_results is null or ddo_results.count = 0 then
      o_results_success := JTF_NUMBER_TABLE();
      o_results_errmsg := JTF_VARCHAR2_TABLE_100();
    else
        o_results_success := JTF_NUMBER_TABLE();
        o_results_errmsg := JTF_VARCHAR2_TABLE_100();
        if ddo_results.count > 0 then
          o_results_success.extend(ddo_results.count);
          o_results_errmsg.extend(ddo_results.count);
          ddindx := ddo_results.first;
          indx := 1;
          while true loop
            o_results_success(indx) := ddo_results(ddindx).success;
            o_results_errmsg(indx) := ddo_results(ddindx).errmsg;
            indx := indx+1;
            if ddo_results.last =ddindx
              then exit;
            end if;
            ddindx := ddo_results.next(ddindx);
          end loop;
        end if;
     end if;
  end;

end iby_riskyinstr_pkg_wrap;

/
