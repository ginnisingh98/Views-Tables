--------------------------------------------------------
--  DDL for Package Body FND_IMP_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_IMP_CONV_PKG" AS
/* $Header: afimpconvb.pls 120.2 2005/07/15 04:18:48 pchallag noship $ */

/*  0 - new
    1 - nice upgrade
    2 - hard upgrade
    3 - not applied
*/
FUNCTION compare_rcsid(rcsname1 varchar2, rcsname2 varchar2)
RETURN INTEGER IS
  x INTEGER := 0;
  rcsid1 FND_IMP_RCSID;
  rcsid2 FND_IMP_RCSID;
BEGIN
  if(rcsname1 IS NULL) then
    return 0;
  end if;
  rcsid1 := get_rcsid(rcsname1);
  rcsid2 := get_rcsid(rcsname2);
  x := compare_rcsid(rcsid1, rcsid2);
  if(x = 0 or x = -1) then return 3; end if;
  if(rcsid1(1) = 2) then return 1; end if;
  return 2;
END compare_rcsid;

FUNCTION get_rcsname(rcsname varchar2)
RETURN VARCHAR2 IS
  ret varchar2(300);
  rcsid FND_IMP_RCSID;
BEGIN
  rcsid := get_rcsid(rcsname);
  ret := rcsid(1) || '> ';
  for i in 2..11 loop
    ret := ret || rcsid(i) || '_';
  end loop;
  return ret;
END get_rcsname;

FUNCTION get_rcsid(rcsname varchar2)
RETURN FND_IMP_RCSID IS
  x INTEGER := 0;
  prev INTEGER;
  ret FND_IMP_RCSID := FND_IMP_RCSID(0,0,0,0,0,0,0,0,0,0,0);
BEGIN
  for i in 1..10 loop
    prev := x+1;
    x := instr(rcsname, '.', prev);
    if(x = 0) then
      ret(1) := i;
      ret(i+1) := substr(rcsname, prev);
      return ret;
    end if;
    ret(i+1) := to_number(substr(rcsname, prev, x-prev));
  end loop;
  ret(1) := 10;
  return ret;
END get_rcsid;

FUNCTION compare_rcsid(rcsid1 fnd_imp_rcsid, rcsid2 fnd_imp_rcsid)
RETURN INTEGER IS
  commonSz INTEGER;
  maxSz INTEGER;
  diff INTEGER;
BEGIN
  commonSz := LEAST(rcsid1(1), rcsid2(1)) + 1;
  maxSz := GREATEST(rcsid1(1), rcsid2(1)) + 1;
  for i in 2..commonSz loop
    diff := SIGN(rcsid2(i) - rcsid1(i));
    if(diff <> 0) then
      return diff;
    end if;
  end loop;
  return SIGN(rcsid2(maxSz) - rcsid1(maxSz));
END compare_rcsid;

/*
  -1 - new file
  0 - mainline file overwritten by mainline file
  1 - branched file overwritten by branched file in the same branch
  2 - branched file overwritten by branched file in a different branch
  3 - mainline file overwritten by a branched file
  4 - branched file overwritten by a mainline file
  5 - branched file overwritten by branched file in a different branch (different rcsid size altogether)
*/
FUNCTION check_branching(rcsname1 varchar2, rcsname2 varchar2)
RETURN INTEGER IS
  x INTEGER;
  rcsid1 FND_IMP_RCSID;
  rcsid2 FND_IMP_RCSID;
BEGIN
  if(rcsname1 IS NULL) then
    return -1;
  end if;
  rcsid1 := get_rcsid(rcsname1);
  rcsid2 := get_rcsid(rcsname2);
  x := check_branching(rcsid1, rcsid2);
  return x;
END check_branching;

FUNCTION check_branching(rcsid1 fnd_imp_rcsid, rcsid2 fnd_imp_rcsid)
RETURN INTEGER IS
  commonSz INTEGER;
  maxSz INTEGER;
BEGIN
  if (rcsid1(1) = rcsid2(1) and rcsid1(1) = 2) then
    return 0;
  end if;
  if (rcsid1(1) = rcsid2(1)) then
    for i in 2..rcsid1(1) loop
      if (rcsid1(i) <> rcsid2(i)) then
        return 2;
      end if;
    end loop;
    return 1;
  else
    if (rcsid1(1) = 2) then
      return 3;
    end if;
    if (rcsid2(1) = 2) then
      return 4;
    end if;
    return 5;
  end if;
END check_branching;

PROCEDURE uninstall IS
  CURSOR drop_lst IS
        select 'drop '||object_type||' '||owner||'.'||object_name
                from all_objects
                where object_name like 'FND_IMP_%'
                  and object_type IN ('TABLE', 'VIEW', 'SYNONYM')
                  and owner IN ('APPS', 'APPLSYS');
        clean_cmd VARCHAR2(300);
BEGIN
        OPEN drop_lst;
        LOOP
                FETCH drop_lst into clean_cmd;
                EXIT WHEN drop_lst%NOTFOUND;
                -- dbms_output.put_line(''||clean_cmd);
                execute immediate ''||clean_cmd;
        END LOOP;
        CLOSE drop_lst;
END uninstall;

END FND_IMP_CONV_PKG;

/
