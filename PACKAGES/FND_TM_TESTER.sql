--------------------------------------------------------
--  DDL for Package FND_TM_TESTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TM_TESTER" AUTHID CURRENT_USER as
/* $Header: AFCPTMXS.pls 115.3 99/07/16 23:16:00 porting ship  $ */

PROCEDURE EXECUTE_TEST(
	timeout	in 	number,
        program in      varchar2,
	outcome out 	varchar2,
        outmesg out 	varchar2,
        outstat out 	number,
        valstat out 	number,
        errmsg1 out	varchar2,
        errmsg2 out     varchar2,
        p1	in out  varchar2,
        p2	in out  varchar2,
        p3	in out  varchar2,
        p4	in out  varchar2,
        p5	in out  varchar2,
        p6	in out  varchar2,
        p7	in out  varchar2,
        p8	in out  varchar2,
        p9	in out  varchar2,
        p10	in out  varchar2,
        p11	in out  varchar2,
        p12	in out  varchar2,
        p13	in out  varchar2,
        p14	in out  varchar2,
        p15	in out  varchar2,
        p16	in out  varchar2,
        p17	in out  varchar2,
        p18	in out  varchar2,
        p19	in out  varchar2,
        p20	in out  varchar2);


function run_succeed return varchar2;
function run_prenv(lognam in varchar2) return varchar2;
function run_clock return varchar2;
function run_flip return varchar2;
function run_short_sleep return varchar2;
function run_long_sleep return varchar2;
function run_fail return varchar2;
function run_crash return varchar2;
function run_suite return varchar2;

end;

 

/
