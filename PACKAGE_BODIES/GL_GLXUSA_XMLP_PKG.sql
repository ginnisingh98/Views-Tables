--------------------------------------------------------
--  DDL for Package Body GL_GLXUSA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXUSA_XMLP_PKG" AS
/* $Header: GLXUSAB.pls 120.1 2007/12/28 10:48:37 vijranga noship $ */

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;


DECLARE

 t_ledger_id                      NUMBER;
 t_chart_of_accounts_id           NUMBER;
 t_currency_code                  VARCHAR2(15);
 t_ledger_name                    VARCHAR2(30);

 t_to_ledger_id                   NUMBER;
 t_to_ledger_name                 VARCHAR2(30);
 t_to_chart_of_accounts_id        NUMBER;
 t_to_currency_code               VARCHAR2(15);

 t_from_ledger_id                 NUMBER;
 t_from_ledger_name               VARCHAR2(30);
 t_from_chart_of_accounts_id      NUMBER;
 t_from_currency_code             VARCHAR2(15);

 t_consolidation_id               NUMBER;
 t_consolidation_name             VARCHAR2(33);
 t_consolidation_method           VARCHAR2(30);
 t_consolidation_currency_code    VARCHAR2(15);
 t_consolidation_description      VARCHAR2(240);
 t_consolidation_start_date       DATE;
 t_consolidation_end_date         DATE;

 t_error_buffer                   VARCHAR2(400);
 t_records_present                VARCHAR2(1);

 P1             VARCHAR2(500);
 P2             VARCHAR2(500);
 P3             VARCHAR2(500);
 P4             VARCHAR2(500);
 P5             VARCHAR2(500);
 P6             VARCHAR2(500);
 P6_ADB         VARCHAR2(500);
 P7             VARCHAR2(500);
 P8             VARCHAR2(500);
 P9             VARCHAR2(500);
 P10_1          VARCHAR2(500);
 P10_2          VARCHAR2(500);
 P10_3          VARCHAR2(500);
 P10_4          VARCHAR2(500);
 P10_5          VARCHAR2(500);
 P10_6          VARCHAR2(500);
 P10_7          VARCHAR2(500);
 P11            VARCHAR2(500);
 P12            VARCHAR2(500);
 P13            VARCHAR2(500);
 P14            VARCHAR2(500);
 P15            VARCHAR2(500);
 P16            VARCHAR2(500);
 P17            VARCHAR2(500);
 P18            VARCHAR2(500);
 P19            VARCHAR2(500);
 P20            VARCHAR2(500);
 P21            VARCHAR2(500);
 P22            VARCHAR2(500);
 P23            VARCHAR2(500);
 P24            VARCHAR2(500);
 P25            VARCHAR2(500);
 P26            VARCHAR2(500);
 P27            VARCHAR2(500);
 P28            VARCHAR2(500);
 P29            VARCHAR2(500);
 P30            VARCHAR2(500);
 P31            VARCHAR2(500);
 P32            VARCHAR2(500);
 P33            VARCHAR2(500);
 P34            VARCHAR2(500);
 P35            VARCHAR2(500);
 P36            VARCHAR2(500);
 P37            VARCHAR2(500);
 P38            VARCHAR2(500);
 P39            VARCHAR2(500);
 P40            VARCHAR2(500);


BEGIN

  t_consolidation_id := to_number(P_CONSOLIDATION_ID);
  gl_get_consolidation_info(t_consolidation_id,
                            t_consolidation_name,
                            t_consolidation_method,
                            t_consolidation_currency_code,
                            t_from_ledger_id,
                            t_to_ledger_id,
                            t_consolidation_description,
                            t_error_buffer);

 if (t_error_buffer is not NULL) then
   /*SRW.MESSAGE(0, t_error_buffer);*/null;

   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

 else
   CONSOLIDATION_NAME   := t_consolidation_name;
   SubsidLedgerId   := t_from_ledger_id;
 end if;

    begin
  SELECT glr.target_ledger_name
  INTO SubsidLedgerName
  FROM gl_ledger_relationships glr, gl_consolidation gcs
  WHERE glr.target_currency_code = gcs.from_currency_code
  AND glr.source_ledger_id = gcs.from_ledger_id
  AND glr.target_ledger_id = gcs.from_ledger_id
  AND gcs.consolidation_id = P_CONSOLIDATION_ID;
  exception
    when NO_DATA_FOUND then
    t_error_buffer := SQLERRM;
    /*srw.message(0, t_error_buffer);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;


 gl_info.gl_get_ledger_info(t_from_ledger_id,
                          t_from_chart_of_accounts_id,
                          t_from_ledger_name,
                          t_from_currency_code,
                          t_error_buffer);

 if (t_error_buffer is not NULL) then
   /*SRW.MESSAGE(0, t_error_buffer);*/null;

   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

 else
   STRUCT_NUM            := to_char(t_from_chart_of_accounts_id);
   FromCurrencyCode := t_from_currency_code;
 end if;

 gl_info.gl_get_ledger_info(t_to_ledger_id,
                          t_to_chart_of_accounts_id,
                          t_to_ledger_name,
                          t_to_currency_code,
                          t_error_buffer);

 if (t_error_buffer is not NULL) then
   /*SRW.MESSAGE(0, t_error_buffer);*/null;

   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

 else
   ParentLedgerName    := t_to_ledger_name;
   ConsCurrencyCode := t_consolidation_currency_code;
 end if;



P1  := ' EXISTS ( SELECT	sysdate ' ;
P2  := '          FROM	 gl_consolidation_accounts	CONS_ACCT, ';
P3  := '                 gl_consolidation_history	GLH ';
P4  := ' WHERE	GLH.consolidation_id = :P_CONSOLIDATION_ID  ' ;
P5  := ' AND	GLH.from_period_name = :P_PERIOD_NAME  ';
P6  := ' AND	GLH.average_consolidation_flag = :P_N  ';
P7  := ' AND	GLH.actual_flag = :P_A  ';
P8  := ' AND	GLH.amount_type = :P_PERIOD_TYPE ';
P9  := ' AND	GLH.consolidation_run_id = CONS_ACCT.consolidation_run_id  ';
P10_1:=' AND    GLH.consolidation_run_id = ';
P10_2:='        (SELECT MAX(glh2.consolidation_run_id) ';
P10_3:='         FROM   GL_CONSOLIDATION_HISTORY GLH2 ';
P10_4:='         WHERE  glh2.consolidation_id = GLH.consolidation_id ';
P10_5:='         AND    glh2.from_period_name = GLH.from_period_name ';
P10_6:='         AND    glh2.actual_flag = GLH.actual_flag ';
P10_7:='         AND    glh2.amount_type = GLH.amount_type) ';
P11 := 'and nvl(GLCC.SEGMENT1,:PZ) between nvl(cons_acct.SEGMENT1_low,:PZ) and nvl(cons_acct.SEGMENT1_high,:PZ) ';
P12 := 'and nvl(GLCC.SEGMENT2,:PZ) between nvl(cons_acct.SEGMENT2_low,:PZ) and nvl(cons_acct.SEGMENT2_high,:PZ) ';
P13 := 'and nvl(GLCC.SEGMENT3,:PZ) between nvl(cons_acct.SEGMENT3_low,:PZ) and nvl(cons_acct.SEGMENT3_high,:PZ) ';
P14 := 'and nvl(GLCC.SEGMENT4,:PZ) between nvl(cons_acct.SEGMENT4_low,:PZ) and nvl(cons_acct.SEGMENT4_high,:PZ) ';
P15 := 'and nvl(GLCC.SEGMENT5,:PZ) between nvl(cons_acct.SEGMENT5_low,:PZ) and nvl(cons_acct.SEGMENT5_high,:PZ) ';
P16 := 'and nvl(GLCC.SEGMENT6,:PZ) between nvl(cons_acct.SEGMENT6_low,:PZ) and nvl(cons_acct.SEGMENT6_high,:PZ) ';
P17 := 'and nvl(GLCC.SEGMENT7,:PZ) between nvl(cons_acct.SEGMENT7_low,:PZ) and nvl(cons_acct.SEGMENT7_high,:PZ) ';
P18 := 'and nvl(GLCC.SEGMENT8,:PZ) between nvl(cons_acct.SEGMENT8_low,:PZ) and nvl(cons_acct.SEGMENT8_high,:PZ) ';
P19 := 'and nvl(GLCC.SEGMENT9,:PZ) between nvl(cons_acct.SEGMENT9_low,:PZ) and nvl(cons_acct.SEGMENT9_high,:PZ) ';
P20 := 'and nvl(GLCC.SEGMENT10,:PZ) between nvl(cons_acct.SEGMENT10_low,:PZ) and nvl(cons_acct.SEGMENT10_high,:PZ) ';
P21 := 'and nvl(GLCC.SEGMENT11,:PZ) between nvl(cons_acct.SEGMENT11_low,:PZ) and nvl(cons_acct.SEGMENT11_high,:PZ) ';
P22 := 'and nvl(GLCC.SEGMENT12,:PZ) between nvl(cons_acct.SEGMENT12_low,:PZ) and nvl(cons_acct.SEGMENT12_high,:PZ) ';
P23 := 'and nvl(GLCC.SEGMENT13,:PZ) between nvl(cons_acct.SEGMENT13_low,:PZ) and nvl(cons_acct.SEGMENT13_high,:PZ) ';
P24 := 'and nvl(GLCC.SEGMENT14,:PZ) between nvl(cons_acct.SEGMENT14_low,:PZ) and nvl(cons_acct.SEGMENT14_high,:PZ) ';
P25 := 'and nvl(GLCC.SEGMENT15,:PZ) between nvl(cons_acct.SEGMENT15_low,:PZ) and nvl(cons_acct.SEGMENT15_high,:PZ) ';
P26 := 'and nvl(GLCC.SEGMENT16,:PZ) between nvl(cons_acct.SEGMENT16_low,:PZ) and nvl(cons_acct.SEGMENT16_high,:PZ) ';
P27 := 'and nvl(GLCC.SEGMENT17,:PZ) between nvl(cons_acct.SEGMENT17_low,:PZ) and nvl(cons_acct.SEGMENT17_high,:PZ) ';
P28 := 'and nvl(GLCC.SEGMENT18,:PZ) between nvl(cons_acct.SEGMENT18_low,:PZ) and nvl(cons_acct.SEGMENT18_high,:PZ) ';
P29 := 'and nvl(GLCC.SEGMENT19,:PZ) between nvl(cons_acct.SEGMENT19_low,:PZ) and nvl(cons_acct.SEGMENT19_high,:PZ) ';
P30 := 'and nvl(GLCC.SEGMENT20,:PZ) between nvl(cons_acct.SEGMENT20_low,:PZ) and nvl(cons_acct.SEGMENT20_high,:PZ) ';
P31 := 'and nvl(GLCC.SEGMENT21,:PZ) between nvl(cons_acct.SEGMENT21_low,:PZ) and nvl(cons_acct.SEGMENT21_high,:PZ) ';
P32 := 'and nvl(GLCC.SEGMENT22,:PZ) between nvl(cons_acct.SEGMENT22_low,:PZ) and nvl(cons_acct.SEGMENT22_high,:PZ) ';
P33 := 'and nvl(GLCC.SEGMENT23,:PZ) between nvl(cons_acct.SEGMENT23_low,:PZ) and nvl(cons_acct.SEGMENT23_high,:PZ) ';
P34 := 'and nvl(GLCC.SEGMENT24,:PZ) between nvl(cons_acct.SEGMENT24_low,:PZ) and nvl(cons_acct.SEGMENT24_high,:PZ) ';
P35 := 'and nvl(GLCC.SEGMENT25,:PZ) between nvl(cons_acct.SEGMENT25_low,:PZ) and nvl(cons_acct.SEGMENT25_high,:PZ) ';
P36 := 'and nvl(GLCC.SEGMENT26,:PZ) between nvl(cons_acct.SEGMENT26_low,:PZ) and nvl(cons_acct.SEGMENT26_high,:PZ) ';
P37 := 'and nvl(GLCC.SEGMENT27,:PZ) between nvl(cons_acct.SEGMENT27_low,:PZ) and nvl(cons_acct.SEGMENT27_high,:PZ) ';
P38 := 'and nvl(GLCC.SEGMENT28,:PZ) between nvl(cons_acct.SEGMENT28_low,:PZ) and nvl(cons_acct.SEGMENT28_high,:PZ) ';
P39 := 'and nvl(GLCC.SEGMENT29,:PZ) between nvl(cons_acct.SEGMENT29_low,:PZ) and nvl(cons_acct.SEGMENT29_high,:PZ) ';
P40 := 'and nvl(GLCC.SEGMENT30,:PZ) between nvl(cons_acct.SEGMENT30_low,:PZ) and nvl(cons_acct.SEGMENT30_high,:PZ)) ';

   P_Accounts_Clause := 'N';

   gl_check_cons_accounts(P_CONSOLIDATION_ID,
                          'N',
                          P_A,
                          P_PERIOD_TYPE,
                          t_records_present);

   if ( P_Accounts_Clause = 'Y' ) then
     P_Accounts := P1 || P2 || P3 || P4 || P5 || P6 || P7 || P8 || P9 ||
                   P10_1 || P10_2 || P10_3 || P10_4 || P10_5 || P10_6 || P10_7 ||
                   P11 || P12 || P13 || P14 || P15 || P16 || P17 || P18 || P19 ||
                   P20 || P21 || P22 || P23 || P24 || P25 || P26 || P27 || P28 || P29 ||
                   P30 || P31 || P32 || P33 || P34 || P35 || P36 || P37 || P38 || P39 || P40;
   else
     P_Accounts := ' 1 = 1 ' ;
   end if;
	IF (P_Accounts IS NULL) then
		P_Accounts := '1=1';
	END IF;
   P_Accounts_Clause := 'N';
   gl_check_cons_accounts(P_CONSOLIDATION_ID,
                          'Y',
                          P_A,
                          P_PERIOD_TYPE,
                          t_records_present);
  if (P_Accounts_Clause = 'Y') then
    P6_ADB  := ' AND	GLH.average_consolidation_flag = :P_Y ';
    P_Accounts_ADB := P1 || P2 || P3 || P4 || P5 || P6_ADB || P7 || P8 || P9 ||
               P10_1 || P10_2 || P10_3 || P10_4 || P10_5 || P10_6 || P10_7 ||
               P11 || P12 || P13 || P14 || P15 || P16 || P17 || P18 || P19 ||
               P20 || P21 || P22 || P23 || P24 || P25 || P26 || P27 || P28 || P29 ||
               P30 || P31 || P32 || P33 || P34 || P35 || P36 || P37 || P38 || P39 || P40;
  else
    P_Accounts_ADB := ' 1 = 1 ' ;
  end if;
	IF (P_Accounts_Clause IS NULL) then
		P_Accounts_Clause := '1=1';
	END IF;
   if ( ConsCurrencyCode = FromCurrencyCode) then
     if (P_PERIOD_TYPE = 'PTD' ) then
       P_BALJOIN := '(nvl(glb.period_net_dr,0) <> 0 or nvl(glb.period_net_cr,0) <> 0)';
     elsif (P_PERIOD_TYPE = 'YTD' ) then
       P_BALJOIN := '(nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0) <> 0 or nvl(glb.begin_balance_cr,0) + nvl(glb.period_net_cr,0) <> 0)';
     elsif (P_PERIOD_TYPE = 'QTD' ) then
       P_BALJOIN := '(nvl(glb.quarter_to_date_dr,0) + nvl(glb.period_net_dr,0) <> 0 or nvl(glb.quarter_to_date_cr,0) + nvl(glb.period_net_cr,0) <> 0)';
     elsif  (P_PERIOD_TYPE = 'PJTD' ) then
       P_BALJOIN := '(nvl(glb.project_to_date_dr,0) + nvl(glb.period_net_dr,0) <> 0 or nvl(glb.project_to_date_cr,0) + nvl(glb.period_net_cr,0) <> 0)';
      end if;

   else
      if (P_PERIOD_TYPE = 'PTD' ) then
       P_BALJOIN := 'nvl(glb.period_net_dr,0) - nvl(glb.period_net_cr,0) <> 0';
      elsif (P_PERIOD_TYPE = 'YTD' ) then
       P_BALJOIN := '(nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0)) - (nvl(glb.begin_balance_cr,0) + nvl(glb.period_net_cr,0)) <> 0';
      elsif (P_PERIOD_TYPE = 'QTD' ) then
       P_BALJOIN := '(nvl(glb.quarter_to_date_dr,0) + nvl(glb.period_net_dr,0)) - (nvl(glb.quarter_to_date_cr,0) + nvl(glb.period_net_cr,0)) <> 0';
      elsif (P_PERIOD_TYPE = 'PJTD' ) then
       P_BALJOIN := '(nvl(glb.project_to_date_dr,0) + nvl(glb.period_net_dr,0)) - (nvl(glb.project_to_date_cr,0) + nvl(glb.period_net_cr,0)) <> 0';
       end if;
   end if;

	IF (P_BALJOIN IS NULL) then
		P_BALJOIN := '1=1';
	END IF;

      if (P_PERIOD_TYPE = 'PATD') then
	P_BALJOINAB := '(nvl(gdb.period_average_to_date_num, 0) <> 0)';
   elsif (P_PERIOD_TYPE = 'QATD') then
	P_BALJOINAB := '(nvl(gdb.quarter_average_to_date_num, 0) <> 0)';
   elsif (P_PERIOD_TYPE = 'YATD') then
	P_BALJOINAB := '(nvl(gdb.year_average_to_date_num, 0) <> 0)';
   elsif (P_PERIOD_TYPE = 'EOD') then
	P_BALJOINAB := '(nvl(gdb.end_of_date_balance_num, 0) <> 0)';
   end if;
	  IF (P_BALJOINAB IS NULL) then
		P_BALJOINAB := '1=1';
	END IF;
      if (P_PERIOD_TYPE = 'PATD' OR P_PERIOD_TYPE = 'QATD' OR
       P_PERIOD_TYPE = 'YATD' OR P_PERIOD_TYPE = 'EOD') then
	SELECT period_set_name INTO PeriodSetName
	FROM   GL_LEDGERS
	WHERE  ledger_id = SubsidLedgerID;
   end if;

END;

/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;
/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;  return (TRUE);
end;

procedure gl_get_consolidation_info(
                           cons_id number, cons_name out nocopy varchar2,
                           method out varchar2, curr_code out nocopy varchar2,
                           from_ledid out number, to_ledid out nocopy number,
                           description out nocopy varchar2,
                           errbuf out nocopy varchar2) is
  begin
    select glc.name, glc.method, glc.from_currency_code,
           glc.from_ledger_id, glc.to_ledger_id,
           glc.description
    into cons_name, method, curr_code, from_ledid, to_ledid,
         description
    from gl_consolidation glc
    where glc.consolidation_id = cons_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message('GL_PLL_INVALID_CONSOLID_ID', 'Y',
                                   'CID', to_char(cons_id));
  end;

procedure gl_check_cons_accounts(
                           cons_id  number,
                           avg_flag varchar2,
                           actual_flag varchar2,
                           amount_type varchar2,
                           records_present out nocopy varchar2
                           ) is
  begin
    SELECT 'Y' INTO P_Accounts_Clause
    FROM   GL_CONSOLIDATION_ACCOUNTS CA
    WHERE  CA.consolidation_id = cons_id
    AND    CA.consolidation_run_id =
           ( SELECT max(CH.consolidation_run_id)
             FROM   GL_CONSOLIDATION_HISTORY CH
             WHERE  CH.consolidation_id = cons_id
             AND    CH.average_consolidation_flag = avg_flag
             AND    CH.actual_flag = actual_flag
             AND    CH.amount_type = amount_type )
    AND ROWNUM < 2;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_Accounts_Clause := 'N';
  end;

--Functions to refer Oracle report placeholders--

 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function CONSOLIDATION_NAME_p return varchar2 is
	Begin
	 return CONSOLIDATION_NAME;
	 END;
 Function ParentLedgerName_p return varchar2 is
	Begin
	 return ParentLedgerName;
	 END;
 Function SubsidLedgerName_p return varchar2 is
	Begin
	 return SubsidLedgerName;
	 END;
 Function ConsCurrencyCode_p return varchar2 is
	Begin
	 return ConsCurrencyCode;
	 END;
 Function SubsidLedgerId_p return number is
	Begin
	 return SubsidLedgerId;
	 END;
 Function FromCurrencyCode_p return varchar2 is
	Begin
	 return FromCurrencyCode;
	 END;
 Function PeriodSetName_p return varchar2 is
	Begin
	 return PeriodSetName;
	 END;
END GL_GLXUSA_XMLP_PKG ;



/
