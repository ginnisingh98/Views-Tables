--------------------------------------------------------
--  DDL for Package JTF_PRIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PRIME" AUTHID CURRENT_USER AS
/*$Header: JTFPRMS.pls 120.2 2005/11/28 22:22:18 skothe ship $ */


  type rec01 is record(n number, d date,
    vc01 varchar2(100),
    vc02 varchar2(200),
    vc03 varchar2(300),
    vc04 varchar2(400),
    vc10 varchar2(1000),
    vc20 varchar2(2000),
    vc30 varchar2(3000),
    vc40 varchar2(4000));

  type tab01 is table of rec01 index by binary_integer;
  procedure proc1(t OUT NOCOPY /* file.sql.39 change */ tab01);
  procedure proc2(t IN OUT NOCOPY /* file.sql.39 change */ tab01);
END JTF_PRIME;

 

/
