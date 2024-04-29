--------------------------------------------------------
--  DDL for Package Body FND_TM_TESTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TM_TESTER" as
/* $Header: AFCPTMXB.pls 115.2 99/07/16 23:15:54 porting ship $ */

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
        p20	in out  varchar2)

as

respid number;
appid number;
userid number;

begin

  SELECT -1, fr.application_id, fr.responsibility_id
        into userid, appid, respid
        from fnd_concurrent_queues fcq,
             fnd_conc_processor_programs fcpp,
             fnd_concurrent_programs fcp,
             fnd_responsibility fr
        where fcq.processor_application_id = fcpp.processor_application_id
         and fcq.concurrent_processor_id =  fcpp.concurrent_processor_id
         and fcpp.concurrent_program_id = fcp.concurrent_program_id
         and fcpp.program_application_id = fcp.application_id
         and fcp.concurrent_program_name = 'FNDTMSUCCEED'
         and fr.data_group_id = fcq.data_group_id
         and fcq.manager_type = '3'
         and rownum < 2;

  FND_GLOBAL.APPS_INITIALIZE(userid,respid,appid);

  outstat := FND_TRANSACTION.synchronous(timeout,outcome,outmesg,'FND', program,
    p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);
  errmsg1 := fnd_message.get;
  valstat := FND_TRANSACTION.get_values(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,
                p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);
  errmsg2 := fnd_message.get;
end;


function run_succeed return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
        p1      varchar2(250);
	p2      varchar2(250);
	p3      varchar2(250);
        p4      varchar2(250);
	p5      varchar2(250);
	p6      varchar2(250);
        p7      varchar2(250);
	p8      varchar2(250);
	p9      varchar2(250);
        p10     varchar2(250);
	p11     varchar2(250);
	p12     varchar2(250);
        p13     varchar2(250);
	p14     varchar2(250);
	p15     varchar2(250);
        p16     varchar2(250);
	p17     varchar2(250);
	p18     varchar2(250);
        p19     varchar2(250);
	p20     varchar2(250);

begin
  p1 := chr(0);

  EXECUTE_TEST(30, 'FNDTMSUCCEED', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if ((outcome = 'SUCCESS') AND (outmesg = 'SUCCESS') AND
	(outstat = 0) AND (valstat = 0) AND (errmsg1 is null)
	AND (errmsg2 is null)) then
		return ('FNDTMSUCCEED ran correctly.');
  else
        Return('FNDTMSUCCEED failed: Outcome = ''' || outcome  ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;


function run_prenv(lognam in varchar2) return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
	p1      varchar2(250);
	p2      varchar2(250);
	p3      varchar2(250);
        p4      varchar2(250);
	p5      varchar2(250);
	p6      varchar2(250);
        p7      varchar2(250);
	p8      varchar2(250);
	p9      varchar2(250);
        p10     varchar2(250);
	p11     varchar2(250);
	p12     varchar2(250);
        p13     varchar2(250);
	p14     varchar2(250);
	p15     varchar2(250);
        p16     varchar2(250);
	p17     varchar2(250);
	p18     varchar2(250);
        p19     varchar2(250);
	p20     varchar2(250);

begin
  p1 := lognam;
  p2 := chr(0);

  EXECUTE_TEST(30, 'FNDTMPRENV', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if ((outcome = 'SUCCESS') AND (outmesg = 'SUCCESS') AND
	(outstat = 0) AND (valstat = 0) AND (errmsg1 is null)
	AND (errmsg2 is null)) then
		return ('FNDTMPRENV ran correctly: ''' || lognam || ''' => '''
			|| p1 || '''.');
  else
        Return('FNDTMPRENV failed: Outcome = ''' || outcome  ||
		''', Logname = ''' ||  lognam ||
		''', Value = ''' ||  p1 ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;


function run_clock return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
	p1      varchar2(250);
	p2      varchar2(250);
	p3      varchar2(250);
        p4      varchar2(250);
	p5      varchar2(250);
	p6      varchar2(250);
        p7      varchar2(250);
	p8      varchar2(250);
	p9      varchar2(250);
        p10     varchar2(250);
	p11     varchar2(250);
	p12     varchar2(250);
        p13     varchar2(250);
	p14     varchar2(250);
	p15     varchar2(250);
        p16     varchar2(250);
	p17     varchar2(250);
	p18     varchar2(250);
        p19     varchar2(250);
	p20     varchar2(250);

begin
  p1 := chr(0);

  EXECUTE_TEST(30, 'FNDTMCLOCK', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if ((outcome = 'SUCCESS') AND (outmesg = 'SUCCESS') AND
	(outstat = 0) AND (valstat = 0) AND (errmsg1 is null)
	AND (errmsg2 is null)) then
		return ('FNDTMCLOCK ran correctly: OS Time = ''' ||  p2 ||
			''', DB Time = ''' ||  p1 || '''.');
  else
        Return('FNDTMCLOCK failed: Outcome = ''' || outcome  ||
		''', OS Time = ''' ||  p2 ||
		''', DB Time = ''' ||  p1 ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;

function run_flip return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
	p1      varchar2(250) := 'A';
	p2      varchar2(250) := 'B';
	p3      varchar2(250) := 'C';
        p4      varchar2(250) := 'D';
	p5      varchar2(250) := 'E';
	p6      varchar2(250) := 'F';
        p7      varchar2(250) := 'G';
	p8      varchar2(250) := 'H';
	p9      varchar2(250) := 'I';
        p10     varchar2(250) := 'J';
	p11     varchar2(250) := 'K';
	p12     varchar2(250) := 'L';
        p13     varchar2(250) := 'M';
	p14     varchar2(250) := 'N';
	p15     varchar2(250) := 'O';
        p16     varchar2(250) := 'P';
	p17     varchar2(250) := 'Q';
	p18     varchar2(250) := 'R';
        p19     varchar2(250) := 'S';
	p20     varchar2(250) := 'T';

begin

  EXECUTE_TEST(30, 'FNDTMFLIP', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if ((outcome = 'SUCCESS') AND (outmesg = 'SUCCESS') AND
	(outstat = 0) AND (valstat = 0) AND (errmsg1 is null)
	AND (errmsg2 is null))
        AND (p20 = 'A') AND (p19 = 'B') AND (p18 = 'C') AND (p17 = 'D')
        AND (p16 = 'E') AND (p15 = 'F') AND (p14 = 'G') AND (p13 = 'H')
        AND (p12 = 'I') AND (p11 = 'J') AND (p10 = 'K') AND (p9 = 'L')
        AND (p8 = 'M') AND (p7 = 'N') AND (p6 = 'O') AND (p5 = 'P')
        AND (p4 = 'Q') AND (p3 = 'R') AND (p2 = 'S') AND (p1 = 'T') then
		return ('FNDTMFLIP ran correctly.'  );
  else
        Return('FNDTMFLIP failed: Outcome = ''' || outcome  ||
		''', P1 = ''' ||  p1 || ''', P2 = ''' ||  p2 ||
		''', P3 = ''' ||  p3 || ''', P4 = ''' ||  p4 ||
		''', P5 = ''' ||  p5 || ''', P6 = ''' ||  p6 ||
		''', P7 = ''' ||  p7 || ''', P8 = ''' ||  p8 ||
		''', P9 = ''' ||  p9 || ''', P10 = ''' ||  p10 ||
		''', P11 = ''' ||  p11 || ''', P12 = ''' ||  p12 ||
		''', P13 = ''' ||  p13 || ''', P14 = ''' ||  p14 ||
		''', P15 = ''' ||  p15 || ''', P16 = ''' ||  p16 ||
		''', P17 = ''' ||  p17 || ''', P18 = ''' ||  p18 ||
		''', P19 = ''' ||  p19 || ''', P20 = ''' ||  p20 ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;


function  run_short_sleep return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
        p1      varchar2(250);
	p2      varchar2(250);
	p3      varchar2(250);
        p4      varchar2(250);
	p5      varchar2(250);
	p6      varchar2(250);
        p7      varchar2(250);
	p8      varchar2(250);
	p9      varchar2(250);
        p10     varchar2(250);
	p11     varchar2(250);
	p12     varchar2(250);
        p13     varchar2(250);
	p14     varchar2(250);
	p15     varchar2(250);
        p16     varchar2(250);
	p17     varchar2(250);
	p18     varchar2(250);
        p19     varchar2(250);
	p20     varchar2(250);

begin
  p2 := chr(0);
  p1 := '5';

  EXECUTE_TEST(30, 'FNDTMSLEEP', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if ((outcome = 'SUCCESS') AND (outmesg = 'SUCCESS') AND
	(outstat = 0) AND (valstat = 0) AND (errmsg1 is null)
	AND (errmsg2 is null)) then
		return ('FNDTMSLEEP (short) ran correctly.');
  else
        Return('FNDTMSSLEEP (short) failed: Outcome = ''' || outcome  ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;


function run_long_sleep return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
        p1      varchar2(250);
	p2      varchar2(250);
	p3      varchar2(250);
        p4      varchar2(250);
	p5      varchar2(250);
	p6      varchar2(250);
        p7      varchar2(250);
	p8      varchar2(250);
	p9      varchar2(250);
        p10     varchar2(250);
	p11     varchar2(250);
	p12     varchar2(250);
        p13     varchar2(250);
	p14     varchar2(250);
	p15     varchar2(250);
        p16     varchar2(250);
	p17     varchar2(250);
	p18     varchar2(250);
        p19     varchar2(250);
	p20     varchar2(250);

begin
  p2 := chr(0);
  p1 := '11';

  EXECUTE_TEST(10, 'FNDTMSLEEP', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if (outstat = 1) then
		return ('FNDTMSLEEP (long) ran correctly.');
  else
        Return('FNDTMSLEEP (long) failed: Outcome = ''' || outcome  ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;


function run_fail return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
        p1      varchar2(250);
	p2      varchar2(250);
	p3      varchar2(250);
        p4      varchar2(250);
	p5      varchar2(250);
	p6      varchar2(250);
        p7      varchar2(250);
	p8      varchar2(250);
	p9      varchar2(250);
        p10     varchar2(250);
	p11     varchar2(250);
	p12     varchar2(250);
        p13     varchar2(250);
	p14     varchar2(250);
	p15     varchar2(250);
        p16     varchar2(250);
	p17     varchar2(250);
	p18     varchar2(250);
        p19     varchar2(250);
	p20     varchar2(250);

begin
  p1 := chr(0);

  EXECUTE_TEST(30, 'FNDTMFAIL', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if ((outcome = 'ERROR') AND (outmesg = 'FAILURE') AND
	(outstat = 0) AND (valstat = 0) AND (errmsg1 is null)
	AND (errmsg2 is null)) then
		return ('FNDTMFAIL ran correctly.');
  else
        Return('FNDTMFAIL failed: Outcome = ''' || outcome  ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;


function run_crash return varchar2 as

        outcome varchar2(250);
        outmesg varchar2(250);
        outstat number;
        valstat number;
        errmsg1 varchar2(250);
        errmsg2 varchar2(250);
        p1      varchar2(250);
	p2      varchar2(250);
	p3      varchar2(250);
        p4      varchar2(250);
	p5      varchar2(250);
	p6      varchar2(250);
        p7      varchar2(250);
	p8      varchar2(250);
	p9      varchar2(250);
        p10     varchar2(250);
	p11     varchar2(250);
	p12     varchar2(250);
        p13     varchar2(250);
	p14     varchar2(250);
	p15     varchar2(250);
        p16     varchar2(250);
	p17     varchar2(250);
	p18     varchar2(250);
        p19     varchar2(250);
	p20     varchar2(250);

begin
  p1 := chr(0);

  EXECUTE_TEST(30, 'FNDTMCRASH', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if (outstat = 1) then
		return ('FNDTMCRASH ran correctly.');
  else
        Return('FNDTMFAIL failed: Outcome = ''' || outcome  ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');
  end if;

end;

function run_suite return varchar2 is

Total_msg varchar2(4000);
Prog_msg varchar2(4000);

begin
   Total_msg := null;

   Prog_msg := run_succeed;
   if (INSTR(Prog_msg,'correctly') = 0) then
	Total_msg := Total_msg || Prog_msg ||  '  ';
   end if;

   Prog_msg := run_fail;
   if (INSTR(Prog_msg,'correctly') = 0) then
	Total_msg := Total_msg || Prog_msg ||  '  ';
   end if;

   Prog_msg := run_flip;
   if (INSTR(Prog_msg,'correctly') = 0) then
	Total_msg := Total_msg || Prog_msg ||  '  ';
   end if;

   Prog_msg := run_clock;
   if (INSTR(Prog_msg,'correctly') = 0) then
	Total_msg := Total_msg || Prog_msg ||  '  ';
   end if;

   Prog_msg := run_prenv('APPLOUT');
   if (INSTR(Prog_msg,'correctly') = 0) then
	Total_msg := Total_msg || Prog_msg ||  '  ';
   end if;

   Prog_msg := run_short_sleep;
   if (INSTR(Prog_msg,'correctly') = 0) then
	Total_msg := Total_msg || Prog_msg ||  '  ';
   end if;

   Prog_msg := run_long_sleep;
   if (INSTR(Prog_msg,'correctly') = 0) then
	Total_msg := Total_msg || Prog_msg ||  '  ';
   end if;

   if (Total_msg is null) then return('FNDTMTST Suite ran correctly.');
   else return(Total_msg);
   end if;

end;

end;

/
