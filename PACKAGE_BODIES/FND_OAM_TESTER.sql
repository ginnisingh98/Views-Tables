--------------------------------------------------------
--  DDL for Package Body FND_OAM_TESTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_TESTER" AS
/* $Header: AFOAMTESTERB.pls 115.1 2002/12/25 01:48:48 rmohan noship $ */

---Common Constants
   procedure run_succeed(oerr1 out NOCOPY varchar2
      , oerr2 out NOCOPY varchar2 )
   is
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

  FND_TM_TESTER.EXECUTE_TEST(30, 'FNDTMSUCCEED', outcome, outmesg,
	outstat, valstat, errmsg1, errmsg2,
	p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20);

  if ((outcome = 'SUCCESS') AND (outmesg = 'SUCCESS') AND
	(outstat = 0) AND (valstat = 0) AND (errmsg1 is null)
	AND (errmsg2 is null)) then
    fnd_file.put_line( fnd_file.log, 'FNDTMSUCCEED ran correctly.');
    oerr1 := null;
    oerr2 := null;
  else
    oerr1 := errmsg1;
    oerr2 := errmsg2;
    fnd_file.put_line( fnd_file.log,
        'FNDTMSUCCEED failed: Outcome = ''' || outcome  ||
		''', Outmesg = ''' ||  outmesg ||
		''', Outstat = ''' ||  to_char(outstat) ||
		''', Valstat = ''' ||  to_char(valstat) ||
		''', Errmsg1 = ''' ||  errmsg1 ||
		''', Errmsg2 = ''' ||  errmsg2 || '''.');

  end if;

end;



   procedure test_tm_debug(oSessionId out NOCOPY number
      , oTestDuration out NOCOPY number, oerr1 out NOCOPY varchar2
      , oerr2 out NOCOPY varchar2 )
  is
      ltime_start number;
      ltime_end number;
      begin
        ltime_start  := dbms_utility.get_time;
        run_succeed(oerr1, oerr2);
        ltime_end  := dbms_utility.get_time;
        oTestDuration := ltime_end - ltime_start;
        select userenv('SESSIONID') into oSessionId from sys.dual;
      exception
         when others then
            raise;

   end test_tm_debug;





 END FND_OAM_TESTER;

/
