--------------------------------------------------------
--  DDL for Package Body JTF_PRIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PRIME" AS
/*$Header: JTFPRMB.pls 120.2 2005/11/28 22:21:23 skothe ship $ */

  procedure proc1(t OUT NOCOPY /* file.sql.39 change */ tab01) is
    retval tab01;
    r rec01;
  begin
    r.n :=7; r.d := sysdate;
    r.vc01 := 'a';
    r.vc02 := 'a';
    r.vc03 := 'a';
    r.vc04 := 'a';
    r.vc10 := 'a';
    r.vc20 := 'a';
    r.vc30 := 'a';
    r.vc40 := 'a';

    t(1) := r;
  end;
  procedure proc2(t IN OUT NOCOPY /* file.sql.39 change */ tab01) is
  begin
    null;
  end;
end JTF_PRIME;

/
