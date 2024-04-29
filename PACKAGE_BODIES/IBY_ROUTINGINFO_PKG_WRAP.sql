--------------------------------------------------------
--  DDL for Package Body IBY_ROUTINGINFO_PKG_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ROUTINGINFO_PKG_WRAP" as
/*$Header: ibyrutwb.pls 115.11 2002/11/21 20:15:00 jleybovi ship $*/

  procedure createroutinginfo(i_rules_ruleid  NUMBER,
    i_rules_rulename  VARCHAR2,
    i_rules_bepinstrtype  VARCHAR2,
    i_rules_priority  NUMBER,
    i_rules_bepid  NUMBER,
    i_rules_bepsuffix  VARCHAR2,
    i_rules_activestatus  NUMBER,
    i_rules_payeeid  VARCHAR2,
    i_rules_merchantaccount VARCHAR2,
    i_rules_hitcounter NUMBER,
    i_rules_object_version  NUMBER,
    i_conditions_rulename JTF_VARCHAR2_TABLE_100,
    i_conditions_ruleid JTF_NUMBER_TABLE,
    i_conditions_condition_name JTF_VARCHAR2_TABLE_100,
    i_conditions_parameter JTF_VARCHAR2_TABLE_100,
    i_conditions_operation JTF_VARCHAR2_TABLE_100,
    i_conditions_value JTF_VARCHAR2_TABLE_100,
    i_conditions_is_value_string JTF_VARCHAR2_TABLE_100,
    i_conditions_entry_seq JTF_NUMBER_TABLE,
    i_conditions_object_version JTF_NUMBER_TABLE)

  is
    ddi_rules iby_routinginfo_pkg.t_rulesrec;
    ddi_conditions iby_routinginfo_pkg.t_condtrecvec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddi_rules.ruleid := i_rules_ruleid;
    ddi_rules.rulename := i_rules_rulename;
    ddi_rules.bepinstrtype := i_rules_bepinstrtype;
    ddi_rules.priority := i_rules_priority;
    ddi_rules.bepid := i_rules_bepid;
    ddi_rules.bepsuffix := i_rules_bepsuffix;
    ddi_rules.activestatus := i_rules_activestatus;
    ddi_rules.hitcounter := i_rules_hitcounter;
    ddi_rules.payeeid := i_rules_payeeid;
    ddi_rules.merchantAccount := i_rules_merchantaccount;
    ddi_rules.object_version := i_rules_object_version;

    if i_conditions_rulename is not null and i_conditions_rulename.count > 0 then
        if i_conditions_rulename.count > 0 then
          indx := i_conditions_rulename.first;
          ddindx := 1;
          while true loop
            ddi_conditions(ddindx).rulename := i_conditions_rulename(indx);
            ddi_conditions(ddindx).ruleid := i_conditions_ruleid(indx);
            ddi_conditions(ddindx).condition_name := i_conditions_condition_name(indx);
            ddi_conditions(ddindx).parameter := i_conditions_parameter(indx);
            ddi_conditions(ddindx).operation := i_conditions_operation(indx);
            ddi_conditions(ddindx).value := i_conditions_value(indx);
            ddi_conditions(ddindx).is_value_string := i_conditions_is_value_string(indx);
            ddi_conditions(ddindx).entry_seq := i_conditions_entry_seq(indx);
            ddi_conditions(ddindx).object_version := i_conditions_object_version(indx);
            ddindx := ddindx+1;
            if i_conditions_rulename.last =indx
              then exit;
            end if;
            indx := i_conditions_rulename.next(indx);
          end loop;
        end if;
     end if;

    -- here's the delegated call to the old PL/SQL routine
    iby_routinginfo_pkg.createroutinginfo(ddi_rules,
      ddi_conditions);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure modifyroutinginfo(i_rules_ruleid  NUMBER,
    i_rules_rulename  VARCHAR2,
    i_rules_bepinstrtype  VARCHAR2,
    i_rules_priority  NUMBER,
    i_rules_bepid  NUMBER,
    i_rules_bepsuffix  VARCHAR2,
    i_rules_activestatus  NUMBER,
    i_rules_payeeid  VARCHAR2,
    i_rules_merchantaccount VARCHAR2,
    i_rules_hitcounter NUMBER,
    i_rules_object_version  NUMBER,
    i_conditions_rulename JTF_VARCHAR2_TABLE_100,
    i_conditions_ruleid JTF_NUMBER_TABLE,
    i_conditions_condition_name JTF_VARCHAR2_TABLE_100,
    i_conditions_parameter JTF_VARCHAR2_TABLE_100,
    i_conditions_operation JTF_VARCHAR2_TABLE_100,
    i_conditions_value JTF_VARCHAR2_TABLE_100,
    i_conditions_is_value_string JTF_VARCHAR2_TABLE_100,
    i_conditions_entry_seq JTF_NUMBER_TABLE,
    i_conditions_object_version JTF_NUMBER_TABLE)

  is
    ddi_rules iby_routinginfo_pkg.t_rulesrec;
    ddi_conditions iby_routinginfo_pkg.t_condtrecvec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddi_rules.ruleid := i_rules_ruleid;
    ddi_rules.rulename := i_rules_rulename;
    ddi_rules.bepinstrtype := i_rules_bepinstrtype;
    ddi_rules.priority := i_rules_priority;
    ddi_rules.bepid := i_rules_bepid;
    ddi_rules.bepsuffix := i_rules_bepsuffix;
    ddi_rules.activestatus := i_rules_activestatus;
    ddi_rules.payeeid := i_rules_payeeid;
    ddi_rules.merchantAccount := i_rules_merchantaccount;
    ddi_rules.hitcounter := i_rules_hitcounter;
    ddi_rules.object_version := i_rules_object_version;

    if i_conditions_rulename is not null and i_conditions_rulename.count > 0 then
        if i_conditions_rulename.count > 0 then
          indx := i_conditions_rulename.first;
          ddindx := 1;
          while true loop
            ddi_conditions(ddindx).rulename := i_conditions_rulename(indx);
            ddi_conditions(ddindx).ruleid := i_conditions_ruleid(indx);
            ddi_conditions(ddindx).condition_name := i_conditions_condition_name(indx);
            ddi_conditions(ddindx).parameter := i_conditions_parameter(indx);
            ddi_conditions(ddindx).operation := i_conditions_operation(indx);
            ddi_conditions(ddindx).value := i_conditions_value(indx);
            ddi_conditions(ddindx).is_value_string := i_conditions_is_value_string(indx);
            ddi_conditions(ddindx).entry_seq := i_conditions_entry_seq(indx);
            ddi_conditions(ddindx).object_version := i_conditions_object_version(indx);
            ddindx := ddindx+1;
            if i_conditions_rulename.last =indx
              then exit;
            end if;
            indx := i_conditions_rulename.next(indx);
          end loop;
        end if;
     end if;

    -- here's the delegated call to the old PL/SQL routine
    iby_routinginfo_pkg.modifyroutinginfo(ddi_rules,
      ddi_conditions);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

end iby_routinginfo_pkg_wrap;

/
