--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK4" as
/* $Header: ghcpdf04.pkb 120.9.12010000.11 2010/02/25 07:05:45 utokachi ship $ */

-- Legal Authority

procedure chk_Legal_Authority
  (p_To_Play_Plan              in varchar2
  ,p_Agency_Sub_Element        in varchar2
  ,p_First_Action_NOA_LA_Code1 in varchar2
  ,p_First_Action_NOA_LA_Code2 in varchar2
  ,p_First_NOAC_Lookup_Code    in varchar2
  ,p_effective_date            in date
  ,p_position_occupied_code    in varchar2
  ) is

begin

-- 250.02.2
    -- renamed this edit from 250.01.2 for the april release
    if (
	  p_First_Action_NOA_LA_Code1 = 'ZVB'
	  or
        p_First_Action_NOA_LA_Code2 = 'ZVB'
	  )
     and
        p_agency_sub_element <>'TD03'
     then
	  hr_utility.set_message(8301, 'GHR_37301_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;

-- 250.03.2
   --
   --            12/8/00   vravikan    From the start          Add UAM
   -- If either legal authority is Z2U, then agency must be AF,AR,DD or NV
   --
    if p_effective_date > fnd_date.canonical_to_date('1998/03/01') then
      if (p_First_Action_NOA_LA_Code1 in ('Z2U','UAM')  or
             p_First_Action_NOA_LA_Code2 in ('Z2U','UAM') ) and
           substr(p_agency_sub_element,1,2) not in ('AF','AR','DD','NV') then
	     hr_utility.set_message(8301, 'GHR_37883_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
    end if;

/* Commented -- Dec 2001 Patch
-- 250.04.2
--  Raju    	  09-Nov-2005	 UPD 43(Bug 4567571) Add Edit
   --
   -- If either legal authority is ZPK, then agency must be PC
   --
    if p_effective_date > fnd_date.canonical_to_date('1998/03/01') then
       if (p_First_Action_NOA_LA_Code1 = 'ZPK'  or
	     p_First_Action_NOA_LA_Code2 = 'ZPK' ) and
           substr(p_agency_sub_element,1,2) <> 'PC' then
	     hr_utility.set_message(8301, 'GHR_37885_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
    end if;
*/
-- Begin Bug 4567571
 if (p_First_Action_NOA_LA_Code1 = 'BAE'  or
	 p_First_Action_NOA_LA_Code2 = 'BAE' ) and
     substr(p_agency_sub_element,1,2) IN('AF','AR','DD','NV') then
	     hr_utility.set_message(8301, 'GHR_38985_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
  end if;
-- End Bug 4567571

--
-- 250.05.2  If either legal authority is Z2W,
--           Then agency must be AF, AR, DD, or NV.
--
    if p_effective_date >= fnd_date.canonical_to_date('1998/09/01') then
       if (p_First_Action_NOA_LA_Code1 = 'Z2W'  or
	     p_First_Action_NOA_LA_Code2 = 'Z2W' ) and
           substr(p_agency_sub_element,1,2) not in ('AF','AR','DD','NV') then
	     hr_utility.set_message(8301, 'GHR_37894_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
    end if;
/* Commented as per December 2000 cpdf changes -- vravikan
--
-- 250.06.2  If either legal authority is ZTA,
--           And position occupied is 1,
--           Then agency/subelement must be DJ03.
--
    if p_effective_date >= fnd_date.canonical_to_date('1998/09/01') then
       if (p_First_Action_NOA_LA_Code1 = 'ZTA'   or
	     p_First_Action_NOA_LA_Code2 = 'ZTA' ) and
           p_position_occupied_code    = '1'     and
           p_agency_sub_element       <> 'DJ03'  then
	     hr_utility.set_message(8301, 'GHR_37895_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
    end if;


*/
-- 250.07.2  If either legal authority is ZVC,
--           Then agency/subelement must be TD19.
--  Updation Date    Updated By     Remarks
--  ============================================
--  19-MAR-2003      vnarasim       Added agency/subelement HSBC.
--  30-OCT-2003      Ashley         Deleted agency/subelement TD19
--
    if p_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
       if (p_First_Action_NOA_LA_Code1 = 'ZVC'   or
	     p_First_Action_NOA_LA_Code2 = 'ZVC' ) and
           p_agency_sub_element   NOT IN ('HSBC')  then
	   hr_utility.set_message(8301, 'GHR_37926_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
    end if;
-- 250.08.2
    -- deleted legal authority M4M and nature of action 117,517,761
    if (
	  p_First_Action_NOA_LA_Code1 in ('M6M','M8M')
  	  or
        p_First_Action_NOA_LA_Code2 in ('M6M','M8M')
        )
     and
        p_First_NOAC_Lookup_Code not in ('115','190','515','590','760')
  	  then
	  hr_utility.set_message(8301, 'GHR_37302_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;

--250.09.2
-- If either (first or second) Legal
-- Authority is UDM, then Agency must be TR.
  --           18-Aug-00    vravikan   01-Jan-2000            New Edit
  if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
    if (
	  p_First_Action_NOA_LA_Code1 = 'UDM'
 	  or
          p_First_Action_NOA_LA_Code2 = 'UDM'
        )
     and
        substr(p_agency_sub_element,1,2) <> 'TR'
     and
        p_agency_sub_element is not null
     then
	  hr_utility.set_message(8301, 'GHR_37418_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  end if;
--250.09.3
-- If either (first or second) Legal
-- Authority is UDM, then Agency must be TR.
  --   11/8     12/14/99    vravikan   01-Nov-1999            New Edit
  if p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if (
	  p_First_Action_NOA_LA_Code1 = 'UDM'
 	  or
          p_First_Action_NOA_LA_Code2 = 'UDM'
        )
     and
        substr(p_agency_sub_element,1,2) <> 'TR'
     and
        p_agency_sub_element is not null
     then
	  hr_utility.set_message(8301, 'GHR_37060_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  end if;
--250.13.2
-- upd50  06-Feb-07	  Raju       From 01-Oct-2006	    Bug#5745356 delete Pay plan FZ
   if p_effective_date < to_date('2006/10/01','yyyy/mm/dd') then
        if ( p_First_Action_NOA_LA_Code1 = 'UFM' or
             p_First_Action_NOA_LA_Code2 = 'UFM'
            ) and
            p_to_play_plan not in ('FA','FE','FO','FP','FZ','GG') and
            p_to_play_plan is not null
         then
          hr_utility.set_message(8301, 'GHR_37303_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','FA, FE, FO, FP, FZ or GG');
          hr_utility.raise_error;
        end if;
    else
       if ( p_First_Action_NOA_LA_Code1 = 'UFM' or
             p_First_Action_NOA_LA_Code2 = 'UFM'
            ) and
            p_to_play_plan not in ('FA','FE','FO','FP','GG') and
            p_to_play_plan is not null
         then
          hr_utility.set_message(8301, 'GHR_37303_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','FA, FE, FO, FP or GG');
          hr_utility.raise_error;
        end if;
    end if;
-- 250.16.2
    if (
	  p_First_Action_NOA_LA_Code1 = 'V8K'
	  or
        p_First_Action_NOA_LA_Code1 = 'V8N'
	  or
        p_First_Action_NOA_LA_Code2 = 'V8K'
	  or
        p_First_Action_NOA_LA_Code2 = 'V8N'
	  )
     and
        p_agency_sub_element not in ('AFNG','AFZG','ARNG')
    then
	  hr_utility.set_message(8301, 'GHR_37304_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;

  --Begin Bug# 5745356
 -- 250.17.2
    if p_effective_date >= to_date('2007/01/01','yyyy/mm/dd') then
        if (p_First_Action_NOA_LA_Code1 = 'Z6H' or  p_First_Action_NOA_LA_Code2 = 'Z6H')
         and substr(p_agency_sub_element,1,2) not in ('AF','AR','DD','NV') then
            hr_utility.set_message(8301, 'GHR_37000_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    end if;
   -- 250.18.2
   if p_effective_date >= to_date('2007/01/01','yyyy/mm/dd') then
        if (p_First_Action_NOA_LA_Code1 = 'Z6J' or  p_First_Action_NOA_LA_Code2 = 'Z6J')
         and substr(p_agency_sub_element,1,2) not in ('AF','AR','DD','NV') then
            hr_utility.set_message(8301, 'GHR_37148_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    end if;
--End Bug# 5745356

--Begin Bug# 8653515
--250.50.2
--8775796 added =
if p_effective_date >= to_date('2009/07/01','yyyy/mm/dd') then
      if (p_First_Action_NOA_LA_Code1 in ('Z5Y','Z6M','Z6N')  or
           p_First_Action_NOA_LA_Code2 in ('Z5Y','Z6M','Z6N')) and
	   p_First_NOAC_Lookup_Code <> '713' and
           substr(p_agency_sub_element,1,2) not in ('AF','AR','DD','NV') then
	     hr_utility.set_message(8301, 'GHR_38224_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
    end if;
--8653515

-- 250.19.2
   -- Award Req  8/15/00   vravikan    30-sep-2000    End date
   --                                                 Add 840-847
   --                      vnarasim    10-MAR-2003    Added 848
   -- upd51  06-Feb-07	  Raju       From 01-Jan-2007 Bug#5745356 add NOAs
   --                                  849,886,887,889
if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
    if ( p_First_NOAC_Lookup_Code <> '350'   and
        p_First_NOAC_Lookup_Code <> '355'  ) and
        ( p_First_Action_NOA_LA_Code1 is null and
        p_First_Action_NOA_LA_Code2 is null)
     then
        hr_utility.set_message(8301, 'GHR_37305_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
elsif p_effective_date < to_date('2007/01/01','yyyy/mm/dd') then
        if  p_First_NOAC_Lookup_Code not in ('350','355','817','840','841','842','843',
                                           '844','845','846','847','848','887','889') and
            ( p_First_Action_NOA_LA_Code1 is null  and
            p_First_Action_NOA_LA_Code2 is null)
        then
            hr_utility.set_message(8301, 'GHR_37419_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
else
   if  p_First_NOAC_Lookup_Code not in ('350','355','817','840','841','842','843',
                                       '844','845','846','847','848','849','886','887','889') and
        ( p_First_Action_NOA_LA_Code1 is null  and
        p_First_Action_NOA_LA_Code2 is null)
    then
        --Bug# 6959477 message number 38591 is duplicated, so created new message with #38157
        hr_utility.set_message(8301, 'GHR_38157_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
end if;

--250.20.2
    if  p_First_NOAC_Lookup_Code <> '356'
     and
       (
	  p_First_Action_NOA_LA_Code1 ='VDK'
	  or
        p_First_Action_NOA_LA_Code2 ='VDK'
	  )
     and
        p_to_play_plan <> 'ES'
     and
        p_to_play_plan is not null
    then
	  hr_utility.set_message(8301, 'GHR_37306_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;

--250.25.2
    -- deleted nature of action 117,517
    if  (
	   p_First_Action_NOA_LA_Code1 = 'WXM'
	   or
         p_First_Action_NOA_LA_Code2 = 'WXM'
   	   )
	and
         p_First_NOAC_Lookup_Code not in ('171','571')
	then
	   hr_utility.set_message(8301, 'GHR_37307_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
    end if;

--250.30.2
    if  (
	   p_First_Action_NOA_LA_Code1 = 'ZSP'
	   or
         p_First_Action_NOA_LA_Code2 = 'ZSP'
         )
      and
         p_First_NOAC_Lookup_Code <>'CM57'
	then
	   hr_utility.set_message(8301, 'GHR_37308_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
    end if;

--250.35.2
    if  (
	   p_First_Action_NOA_LA_Code1 = 'BDN'
	   or
         p_First_Action_NOA_LA_Code1 = 'BYM'
	   or
         p_First_Action_NOA_LA_Code2 = 'BDN'
	   or
         p_First_Action_NOA_LA_Code2 = 'BYM'
	   )
	 and
        (
	   p_agency_sub_element <> 'AG03'
	   and
         p_agency_sub_element <> 'AG11'
	   )
	then
	  hr_utility.set_message(8301, 'GHR_37309_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;

--250.38.2
    if  (
	   p_First_Action_NOA_LA_Code1 = 'V8V'
	   or
         p_First_Action_NOA_LA_Code2 = 'V8V'
	   )
	and
         substr(p_agency_sub_element,1,2) <> 'VA'
	then
	   hr_utility.set_message(8301, 'GHR_37310_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
    end if;

--250.39.2
-- Update Date        By        Effective Date            Comment
   --       18-Aug-00   vravikan   01-Jun-2000               New Edit
/* If either legal authority is V7R,
  Then agency/subelement must be TR93 */
  if p_effective_date >= to_date('2000/06/01','yyyy/mm/dd') then
    if  (
	   p_First_Action_NOA_LA_Code1 = 'V7R' or
         p_First_Action_NOA_LA_Code2 = 'V7R'
	   )
	and
         p_agency_sub_element <> 'TR93'
	then
	   hr_utility.set_message(8301, 'GHR_37420_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
    end if;
  end if;

-- START OF 255.02.2
    -- added 'BNK' and deleted 'VHM' for the april 98 release
    -- added 'Z2U' on 22-jul-1998
    -- added 'ZTA','Z2W' on 9-oct-1998 update 8
   -- Update/Change Date        By        Effective Date            Comment
   --   8        03/09/99    vravikan   01/31/99                  Delete BEA,BMC,BNE,BNW,BRM
   --   10/4     08/15/99    vravikan   01-Jan-99                 Add VGL
   --   11/9     12/13/99    vravikan   01-Nov-99                 Add UDM
   --   11/1     12/13/99    vravikan   01-Dec-99                 Add ZBA
   --            17-Aug-00   vravikan   From Begining             Add ZBA,Delete BNP
   --            08-Dec-00   vravikan   From Begining             Delete ZTA
   --            30-Oct-03   Ashley     From Begining             Added BAB,BAC,BAD,BYO
   --		 30-APR-04   Madhuri    From Beginning            Added LYP for 100
   --  Upd 37    09-NOV-04   Madhuri    From beginning		  Added LAC's - BNR, BNT
   --  Upd 43    09-NOV-05   Raju       From beginning            Added BAE
   --  Upd 39                vnarasim   From Begining             Added BNY
   --  Upd 47	 23-Jun-06   Raju	From Begining		  Added BNZ,ZJK, Z5B, Z5C
   --  upd 49    19-Jan-07   Raju       From Begining	          Bug#5619873 add LAC BAF
   --                                                             delete BNT
   --  Upd 54    12-Jun-07   vmididho   From Begining             delete BAF
   ---            3-Dec-08   Raju       From Begining             Added V8N Bug# 7611040
   --- Upd 56    13-Mar-09   Manish     01-Jan-2009               Added LA code BAG
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

  if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if   p_First_NOAC_Lookup_Code= '100'
      and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C','ZEA')
	   and
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C','ZEA')
		)
      then
	  hr_utility.set_message(8301, 'GHR_37191_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, ALM, AQM, AYM, A2M,BAB,BAC,BAD, BAE, BAG,
      BYO, BBM, BDN,  BKM, BLM,  BNK, BNM, BNN, BNR, BNY, BNZ, BWA, BWM, BYM, HAM, K1M, K4M, K7M, K8M, K9M, LEM,
      LHM, LJM, LKM, LKP, LYP, L3M, PWM, P3M, P5M, P7M, QAK, QBK, QCK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W,
      ZBA, ZEA, ZGM, ZJK, ZJM, ZJR, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, Z5B, Z5C.');
          hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') then
    if   p_First_NOAC_Lookup_Code= '100'
      and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
	   and
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
		)
      then
	  hr_utility.set_message(8301, 'GHR_37191_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, ALM, AQM, AYM, A2M,BAB,BAC,BAD, BAE, BAG,
      BYO, BBM, BDN,  BKM, BLM,  BNK, BNM, BNN, BNR, BNY, BNZ, BWA, BWM, BYM, HAM, K1M, K4M, K7M, K8M, K9M, LEM,
      LHM, LJM, LKM, LKP, LYP, L3M, PWM, P3M, P5M, P7M, QAK, QBK, QCK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W,
      ZBA, ZGM, ZJK, ZJM, ZJR, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, Z5B, Z5C.');
      hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/12/01','yyyy/mm/dd') then
    if   p_First_NOAC_Lookup_Code= '100'
      and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
	   and
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
		)
      then
	  hr_utility.set_message(8301, 'GHR_37191_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, ALM, AQM, AYM, A2M,BAB,BAC,BAD, BAE, BYO,
      BBM, BDN,  BKM, BLM,  BNK, BNM, BNN, BNR, BNY, BNZ, BWA, BWM, BYM, HAM, K1M, K4M, K7M, K8M, K9M, LEM, LHM,
      LJM, LKM, LKP, LYP, L3M, PWM, P3M, P5M, P7M, QAK, QBK, QCK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZBA,
      ZGM, ZJK, ZJM, ZJR, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, Z5B, Z5C.');
        hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if   p_First_NOAC_Lookup_Code= '100'
      and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
	    'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
	   and
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
		)
      then
	    hr_utility.set_message(8301, 'GHR_37190_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  elsif p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then
    if   p_First_NOAC_Lookup_Code= '100'
      and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
	   and
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY','BNZ',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
		)
      then
	    hr_utility.set_message(8301, 'GHR_37039_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if   p_First_NOAC_Lookup_Code= '100'
      and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY','BNZ',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
	   and
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY','BNZ',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
		)
      then
	  hr_utility.set_message(8301, 'GHR_37085_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
   else
    if   p_First_NOAC_Lookup_Code= '100'
      and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY','BNZ',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
	   and
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY','BNZ',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VJM','V1P','V8L','V8N','Z2U','Z2W','ZGM',
        'ZBA','ZJK','ZJM','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','Z5B','Z5C')
		)
      then
	  hr_utility.set_message(8301, 'GHR_37311_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  end if;
-- END IF 255.02.2
--
-- START OF 255.04.2
    -- added 'BNK' for the april 98 release
    -- added 'Z2U' on 22-jul-1998
    -- added 'ZTA','Z2W' on 9-oct-1998 update 8
   -- Update Date        By        Effective Date            Comment
   --   8    03/09/99    vravikan   01/31/99                 Delete BEA,BMC,BNE,BNW,BRM
   --   10/4 08/13/99    vravikan   01-Jan-99                Add VGL
   --   11/1 12/13/99    vravikan   01-Dec-99                Add ZBA
   --   11/9 12/13/99    vravikan   01-Nov-99                Add UDM
   --        17-Aug-00   vravikan   From Begining            Add ZBA,Delete BNP
   --        08-Dec-00   vravikan   From Begining            Delete ZTA
   --        30-Oct-03   Ashley     From Begining            Added BAB,BAC,BAD,BYO
   --  	     30-APR-04   Madhuri    From Beginning           Added LYP for 101
  --  Upd 37 09-NOV-04   Madhuri    From beginning           Added LAC's - BNR, BNT
  --  Upd 43 09-NOV-05   Raju       From beginning           Added BAE
  --  Upd 39             vnarasim   From Begining            Added BNY, V8N
  --upd49    19-Jan-07	 Raju       From Begining	         Bug#5619873 add BAF , delete BNT
  --  Upd 54 12-Jun-07   vmididho   From Begining            delete BAF
-- Upd 56    13-Mar-09   Manish     01-Jan-2009               Added LA code BAG
-- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
-- GPPA U51  14-Aug-09   Raju       11-Sep-2009               Added LAM(8799026)

 --Begin Bug# 8799026
 if p_effective_date >= to_date('2009/09/11','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LAM','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZEA')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LAM','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZEA')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37193_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, ALM, AQM, AYM, A2M, BAB,BAC,BAD, BAE, BAG,
      BYO,BBM, BDN, BKM, BLM, BNK, BNM, BNN, BNR, BNY, BWA, BWM, BYM, HAM, K1M, K4M, K7M, K8M, K9M, LAM, LEM, LHM, LJM,
      LKM, LKP, LYP, L3M, PWM, P3M, P5M, P7M, QAK, QBK, QCK, UDM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZBA, ZEA, ZGM,
      ZJK, ZJM, ZJR, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU.');
          hr_utility.raise_error;
    end if;
    --End Bug# 8799026
  elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZEA')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZEA')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37193_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, ALM, AQM, AYM, A2M, BAB,BAC,BAD, BAE, BAG,
      BYO,BBM, BDN, BKM, BLM, BNK, BNM, BNN, BNR, BNY, BWA, BWM, BYM, HAM, K1M, K4M, K7M, K8M, K9M, LEM, LHM, LJM,
      LKM, LKP, LYP, L3M, PWM, P3M, P5M, P7M, QAK, QBK, QCK, UDM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZBA, ZEA, ZGM,
      ZJK, ZJM, ZJR, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU.');
          hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM','BAG',
        'BLM','BNK','BNM','BNN','BNR','BNY',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37193_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, ALM, AQM, AYM, A2M, BAB,BAC,BAD, BAE, BAG,
      BYO,BBM, BDN, BKM, BLM, BNK, BNM, BNN, BNR, BNY, BWA, BWM, BYM, HAM, K1M, K4M, K7M, K8M, K9M, LEM, LHM, LJM,
      LKM, LKP, LYP, L3M, PWM, P3M, P5M, P7M, QAK, QBK, QCK, UDM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZBA, ZGM, ZJK,
      ZJM, ZJR, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU.');
          hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/12/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37193_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, ALM, AQM, AYM, A2M, BAB,BAC,BAD, BAE,
      BYO,BBM, BDN, BKM, BLM, BNK, BNM, BNN, BNR, BNY, BWA, BWM, BYM, HAM, K1M, K4M, K7M, K8M, K9M, LEM, LHM, LJM,
      LKM, LKP, LYP, L3M, PWM, P3M, P5M, P7M, QAK, QBK, QCK, UDM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZBA, ZGM, ZJK,
      ZJM, ZJR, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU.');
        hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY',
	    'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','UDM','VGL','V1P','V8L','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZJK','ZJM',
        'ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37192_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  elsif p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','V1P','V8L','V8N','Z2U','Z2W','ZGM','ZJK','ZJM',
        'ZBA','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BKM',
        'BLM','BNK','BNM','BNN','BNR','BNY',
        'BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','V1P','V8L','V8N','Z2U','Z2W','ZGM','ZJK','ZJM',
        'ZBA','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37040_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','V1P','V8L','V8N','Z2U','Z2W','ZGM','ZJK','ZJM',
        'ZBA','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','VGL','V1P','V8L','V8N','Z2U','Z2W','ZGM','ZJK','ZJM',
        'ZBA','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37087_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  else
    if  p_First_NOAC_Lookup_Code= '101'
      and
        NOT (
	   p_First_Action_NOA_LA_Code1 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','V1P','V8L','V8N','Z2U','Z2W','ZGM','ZJK','ZJM',
        'ZBA','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	   and
        p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','ALM','AQM',
        'AYM','A2M','BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BKM',
        'BLM','BMC','BNE','BNK','BNM','BNN','BNW','BNR','BNY',
        'BRM','BWA','BWM','BYM','HAM','K1M','K4M',
        'K7M','K8M','K9M','LEM','LHM','LJM','LKM',
        'LKP','L3M','LYP','PWM','P3M','P5M','P7M','QAK',
        'QBK','QCK','V1P','V8L','V8N','Z2U','Z2W','ZGM','ZJK','ZJM',
        'ZBA','ZJR','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU')
	       )
	then
	  hr_utility.set_message(8301, 'GHR_37312_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  end if;
-- END OF 255.04.2
--
--
--265.02.2
    -- the edit is renumbered from 265.01.2 for the april release
    -- added 'Z2U' on 22-jul-1998
   -- Update/Change Date        By        Effective Date            Comment
   --   8/5         03/09/99    vravikan   From the Start            Add BWA
   --   8/5         03/09/99    vravikan   02/27/99                 Delete ACM
   --- Upd 56       13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57       29-Jul-09   Mani       01-Jan-2009               Added LA code BAG

  if p_effective_date < fnd_date.canonical_to_date('19'||'99/02/27') then
    if   p_First_NOAC_Lookup_Code= '107'
       and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ACM','ALM','AQM','BWA',
        'BWM','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK')
	   AND
         p_First_Action_NOA_LA_Code2  in
       ('ABL','ABM','ABR','ABS','ACM','ALM','AQM','BWA',
        'BWM','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK')
		)
	THEN
	  hr_utility.set_message(8301, 'GHR_37313_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    elsif p_effective_date < fnd_date.canonical_to_date('2009/01/01') then
      if   p_First_NOAC_Lookup_Code= '107'
       and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ALM','AQM','BWA',
        'BWM','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK')
	   AND
         p_First_Action_NOA_LA_Code2  in
       ('ABL','ABM','ABR','ABS','ALM','AQM','BWA',
        'BWM','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK')
		)
	THEN
	  hr_utility.set_message(8301, 'GHR_37049_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, ALM, AQM, BWA  BWM, HAM, HDM, HGM, HJM, HLM, NUM, QBK, V1P, V8N, Z2U, ZLM, ZRM, ZSK.');
          hr_utility.raise_error;
       end if;
     elsif p_effective_date < fnd_date.canonical_to_date('2009/02/17') then
      if   p_First_NOAC_Lookup_Code= '107'
       and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ALM','AQM','BWA',
        'BWM','BAG','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK')
	   AND
         p_First_Action_NOA_LA_Code2  in
       ('ABL','ABM','ABR','ABS','ALM','AQM','BWA',
        'BWM','BAG','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK')
		)
	THEN
	  hr_utility.set_message(8301, 'GHR_37049_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, ALM, AQM, BWA  BWM, BAG, HAM, HDM, HGM, HJM, HLM, NUM, QBK, V1P, V8N, Z2U, ZLM, ZRM, ZSK.');
          hr_utility.raise_error;
       end if;
     else
      if   p_First_NOAC_Lookup_Code= '107'
       and
       NOT(
	   p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ALM','AQM','BWA',
        'BWM','BAG','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK','ZEA')
	   AND
         p_First_Action_NOA_LA_Code2  in
       ('ABL','ABM','ABR','ABS','ALM','AQM','BWA',
        'BWM','BAG','HAM','HDM','HGM','HJM','HLM','NUM',
        'QBK','V1P','V8N','Z2U','ZLM','ZRM','ZSK','ZEA')
		)
	THEN
	  hr_utility.set_message(8301, 'GHR_37049_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, ALM, AQM, BWA  BWM, BAG, HAM, HDM, HGM, HJM, HLM, NUM, QBK, V1P, V8N, Z2U, ZEA, ZLM, ZRM, ZSK.');
          hr_utility.raise_error;
       end if;
  end if;

--265.04.2
    -- added 'Z2U' on 22-jul-1998
    -- added 'Z2W' on 9-oct-1998 update 8
    -- fixed bug 738789 by changing HCM to MCM
   -- Update  Date        By        Effective Date            Comment
   --   8     03/09/99    vravikan   01/31/99                  Delete BEA,BMC,BNE,BNW,BRM
   --   8     03/09/99    vravikan                             Add ZTU
   --   8     03/09/99    vravikan   02/27/99                  Delete ACM,MLL,MCM
   --   10/4  08/13/99    vravikan   01-Jan-99                 Add VGL
   --   11/9  12/14/99    vravikan   01-Nov-1999               Add UDM
   --         08-Dec-00   vravikan   From Begining             Add ZJM
   --         10/30/03    Ashley     From Begining             Added BAB,BAC,BAD,BYO
   --  Upd 43 09-NOV-05   Raju       From beginning            Added BAE
   --  Upd 47 23-Jun-06	  Raju		 From beginning            Added BNZ,Z5B, Z5C, Z5F, Z5H, Z5J
   --  upd49  19-Jan-07	  Raju       From beginning	           Bug#5619873 add BAF
   --  Upd 54 12-Jun-07   vmididho   From Begining             delete BAF
   --- Upd 56    13-Mar-09   Manish     01-Jan-2009               Added LA code BAG
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57    29-Jul-09   Mani       01-Mar-2009          Removed BNZ, Z5H
   --- Upd 57    29-Jul-09   Mani       From Begining        Added Z6L
   -- GPPA U51   14-Aug-09   Raju       11-Sep-2009           Added LDM(8799026)

  --Begin Bug# 8799026
  if p_effective_date >= to_date('2009/09/11','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE', 'BAG', 'BYO',
        'BWA','BWM','HAM','LDM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5J','ZEA','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','LDM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5J','ZEA','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37194_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC, BAD, BAE, BAG, BYO,
	BWA, BWM, HAM, LDM, MEM, MGM, MJM, MLK, MLM, MMM, NUM, QAK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZEA, ZJK,
	ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU ,Z5B, Z5C, Z5F, Z5J, Z6L.');
          hr_utility.raise_error;
       end if;
--End Bug# 8799026
  elsif p_effective_date >= to_date('2009/03/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE', 'BAG', 'BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5J','ZEA','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5J','ZEA','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37194_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC, BAD, BAE, BAG, BYO,
      BWA, BWM, HAM, MEM, MGM, MJM, MLK, MLM, MMM, NUM, QAK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZEA, ZJK,
      ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU ,Z5B, Z5C, Z5F, Z5J, Z6L.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE', 'BAG', 'BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','ZEA','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','ZEA','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37194_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC, BAD, BAE, BAG, BNZ, BYO,
      BWA, BWM, HAM, MEM, MGM, MJM, MLK, MLM, MMM, NUM, QAK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZEA, ZJK,
      ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU ,Z5B, Z5C, Z5F, Z5H, Z5J, Z6L.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE', 'BAG', 'BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37194_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC, BAD, BAE, BAG, BNZ, BYO,
      BWA, BWM, HAM, MEM, MGM, MJM, MLK, MLM, MMM, NUM, QAK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZJK, ZJM,
      ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU ,Z5B, Z5C, Z5F, Z5H, Z5J, Z6L.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','UDM','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37194_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC, BAD, BAE, BNZ, BYO, BWA
      , BWM, HAM, MEM, MGM, MJM, MLK, MLM, MMM, NUM, QAK, UDM, VJM, V1P, V8L, V8N, VGL, Z2U, Z2W, ZJK, ZJM, ZLM,
      ZQM, ZRM, ZSK, ZSP, ZTM, ZTU ,Z5B, Z5C, Z5F, Z5H, Z5J, Z6L.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/02/27','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BNZ','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM',
        'MLK','MLM','MMM','NUM','QAK','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37050_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif  p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BNZ','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM',
        'MLK','MLL','MLM','MMM','NUM','QAK','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BNZ','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM',
        'MLK','MLL','MLM','MMM','NUM','QAK','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37041_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BEA','BMC','BNE','BNW','BNZ','BRM',
	    'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM',
        'MLK','MLL','MLM','MMM','NUM','QAK','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','VGL','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BEA','BMC','BNE','BNW','BNZ','BRM',
	    'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM',
        'MLK','MLL','MLM','MMM','NUM','QAK','VGL','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37086_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
if p_First_NOAC_Lookup_Code= '108'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BEA','BMC','BNE','BNW','BNZ','BRM',
	'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM',
        'MLK','MLL','MLM','MMM','NUM','QAK','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BEA','BMC','BNE','BNW','BNZ','BRM',
	'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM',
        'MLK','MLL','MLM','MMM','NUM','QAK','VJM',
        'V1P','V8L','V8N','Z2U','Z2W','ZJK','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','ZJM','Z5B', 'Z5C', 'Z5F', 'Z5H', 'Z5J','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37314_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
   end if;

--265.10.2
    -- added 'Z2U' on 22-jul-1998
    -- added 'Z2W' on 9-oct-1998 update 8
   -- Update  Date        By        Effective Date  Bug       Comment
   --   8    03/09/99    vravikan   01/31/99                  Delete BEA,BMC,BNE,BNW,BRM
   --   8    03/09/99    vravikan   02/27/99                  Delete ACM,NEL,MXM,CTM
   --   8    04/22/99    vravikan   02/27/99        871385    Add MXM,CTM
   --   10/4 08/13/99    vravikan   01-Jan-99                 Add VGL
   --   9/3  09/15/99    vravikan   27-Feb-99       992944    Delete MXM,CTM
   --        11/17/99    AVR        27-Feb-99       1079338   Add MXM
   --   11/9        12/14/99    vravikan   01-Nov-1999              Add UDM
   --              10/30/03     Ashley     From Begining     Added BAB,BAC,BAD,BYO
   --  Upd 43 09-NOV-05   Raju      From beginning            Added BAE
   --  Upd 47 23-Jun-06   Raju      From beginning            Added Z5B, Z5C, Z5F, Z5G, Z5H
   --  upd49  19-Jan-07	  Raju      From Beginning	          Bug#5619873 Add WTA, WTB,BAF and WUM
   --  Upd 54 12-Jun-07   vmididho  From Begining            delete BAF
   --- Upd 56    13-Mar-09   Manish     01-Jan-2009               Added LA code BAG
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   -- GPPA U51   14-Aug-09   Raju       11-Sep-2009               Added LCM(8799026)

 --Begin Bug# 8799026
 if p_effective_date >= to_date('2009/09/11','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','KLM','LCM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','KLM','LCM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37195_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC,BAD, BAE, BAG, BYO, BWA,
	BWM, HAM, KLM, LCM, MXM, M6M, M8M, NAM, NCM, NEM, NJM, NUM, QAK, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB,
	WUM, Z2U, Z2W, ZEA, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU, Z5B, Z5C, Z5F, Z5G, Z5H.');
          hr_utility.raise_error;
       end if;
--End Bug# 8799026
 elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37195_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC,BAD, BAE, BAG, BYO, BWA,
      BWM, HAM, KLM, MXM, M6M, M8M, NAM, NCM, NEM, NJM, NUM, QAK, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB,
      WUM, Z2U, Z2W, ZEA, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU, Z5B, Z5C, Z5F, Z5G, Z5H.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BAG','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37195_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC,BAD, BAE, BAG, BYO, BWA,
      BWM, HAM, KLM, MXM, M6M, M8M, NAM, NCM, NEM, NJM, NUM, QAK, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB,
      WUM, Z2U, Z2W, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU, Z5B, Z5C, Z5F, Z5G, Z5H.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','UDM','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37195_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, ALM, AYM,BAB,BAC,BAD, BAE, BYO, BWA, BWM,
      HAM, KLM, MXM, M6M, M8M, NAM, NCM, NEM, NJM, NUM, QAK, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB, WUM,
      Z2U, Z2W, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU, Z5B, Z5C, Z5F, Z5G, Z5H.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/02/28','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEM','NJM',
        'NUM','QAK','SZX','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37051_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','CTM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEL','NEM','NJM',
        'NUM','QAK','SZX','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','CTM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEL','NEM','NJM',
        'NUM','QAK','SZX','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37042_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNW','BRM',
	    'BWA','BWM','CTM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEL','NEM','NJM',
        'NUM','QAK','SZX','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNW','BRM',
	    'BWA','BWM','CTM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEL','NEM','NJM',
        'NUM','QAK','SZX','VGL','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37089_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
   else
     if p_First_NOAC_Lookup_Code= '115'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNW','BRM',
        'BWA','BWM','CTM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEL','NEM','NJM',
        'NUM','QAK','SZX','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','ALM',
        'AYM','BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNW','BRM',
	    'BWA','BWM','CTM','HAM','KLM','MXM',
        'M6M','M8M','NAM','NCM','NEL','NEM','NJM',
        'NUM','QAK','SZX','VJM','V1P','V8L','V8N',
        'WTA', 'WTB','WUM',
        'Z2U','Z2W','ZJK','ZLM','ZQM','ZRM','ZSK',
        'ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	     hr_utility.set_message(8301, 'GHR_37316_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;

--265.07.2
    -- added 'Z2U' on 22-jul-1998
   -- UPDATE/CHANGE DATE        UPDATED BY     EFFECTIVE_DATE     COMMENTS
--------------------------------------------------------------------------------------------------------
   --   10/4  08/13/99          vravikan       01-Jan-1999        Add VGL
   --   14-SEP-2004		Madhuri				  Edit to be terminated as of 31 AUG 2004.
   --								  (End Date to 31st Aug 2004)
--------------------------------------------------------------------------------------------------------
IF ( p_effective_date <= to_date('20'||'04/08/31','yyyy/mm/dd') ) THEN

  IF ( p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') ) THEN

    IF  p_First_NOAC_Lookup_Code= '112' AND
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABL','ABM','ALM','AQM','AYM','BWM','HAM',
           'MAM','MBM','QDK','V1P','V8N','VGL','Z2U','ZJR','ZLM',
           'ZRM','ZSK','ZSP','ZTM','ZTU') OR
            (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) = 'X' AND
            LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
           (p_First_Action_NOA_LA_Code2 in
           ('ABL','ABM','ALM','AQM','AYM','BWM','HAM',
            'MAM','MBM','QDK','V1P','V8N','VGL','Z2U','ZJR','ZLM',
            'ZRM','ZSK','ZSP','ZTM','ZTU') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) = 'X' AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )))
       THEN
	  hr_utility.set_message(8301, 'GHR_37088_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       END IF;
  ELSE
    if  p_First_NOAC_Lookup_Code= '112'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABL','ABM','ALM','AQM','AYM','BWM','HAM',
           'MAM','MBM','QDK','V1P','V8N','Z2U','ZJR','ZLM',
           'ZRM','ZSK','ZSP','ZTM','ZTU') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) = 'X' AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
          ('ABL','ABM','ALM','AQM','AYM','BWM','HAM',
           'MAM','MBM','QDK','V1P','V8N','Z2U','ZJR','ZLM',
           'ZRM','ZSK','ZSP','ZTM','ZTU') OR
          (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) = 'X' AND
          LENGTH(p_First_Action_NOA_LA_Code1) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37315_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  END IF;
 END IF; -- CHECK for end date

--270.04.2
    --  Upd 47 23-Jun-06   Raju      From beginning            Added AYM, Z5C
   --- Upd 56  13-Mar-09   Manish     17-Feb-2009              Added LA code ZEA
   --- Upd 57  01-Jan-09   Mani       01-Jan-2009              Added LA code BAG

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '120' and
		NOT ( p_First_Action_NOA_LA_Code1  in
			('ABM','ALM','AQM','AYM','BAG','BWM','HAM','HNM','HRM',
			'QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','Z5C','ZEA')
		AND p_First_Action_NOA_LA_Code2 in
		    ('ABM','ALM','AQM','AYM','BAG','BWM','HAM','HNM','HRM',
		    'QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','Z5C','ZEA')
		) THEN
		hr_utility.set_message(8301, 'GHR_37318_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('LAC_CODE',' ABM, ALM, AQM, AYM, BAG, BWM, HAM, HNM, HRM, QAK, QBK, QCK, V1P, ZEA, ZLM, ZRM, ZSK, Z5C.');
		hr_utility.raise_error;
	    end if;
	ELSIF ( p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '120' and
		NOT ( p_First_Action_NOA_LA_Code1  in
			('ABM','ALM','AQM','AYM','BAG','BWM','HAM','HNM','HRM',
			'QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','Z5C')
		AND p_First_Action_NOA_LA_Code2 in
		    ('ABM','ALM','AQM','AYM','BAG','BWM','HAM','HNM','HRM',
		    'QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','Z5C')
		) THEN
		hr_utility.set_message(8301, 'GHR_37318_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('LAC_CODE',' ABM, ALM, AQM, AYM, BAG, BWM, HAM, HNM, HRM, QAK, QBK, QCK, V1P, ZLM, ZRM, ZSK, Z5C.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '120' and
		NOT ( p_First_Action_NOA_LA_Code1  in
			('ABM','ALM','AQM','AYM','BWM','HAM','HNM','HRM',
			'QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','Z5C')
		AND p_First_Action_NOA_LA_Code2 in
		    ('ABM','ALM','AQM','AYM','BWM','HAM','HNM','HRM',
		    'QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','Z5C')
		) THEN
		hr_utility.set_message(8301, 'GHR_37318_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('LAC_CODE',' ABM, ALM, AQM, AYM, BWM, HAM, HNM, HRM, QAK, QBK, QCK, V1P, ZLM, ZRM, ZSK, Z5C.');
		hr_utility.raise_error;
	    end if;
	END IF;

--270.07.2
   --- Upd 56  13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '122'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','ALM','BWM','HAM','HNM','HRM',
		'H3M','QAK','V1P','ZLM','ZRM','ZSK','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','ALM','BWM','HAM','HNM','HRM',
		'H3M','QAK','V1P','ZLM','ZRM','ZSK','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37319_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('LAC_CODE','ABM, ALM, BWM, HAM, HNM, HRM, H3M, QAK, V1P, ZEA, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	     end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '122'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','ALM','BWM','HAM','HNM','HRM',
		'H3M','QAK','V1P','ZLM','ZRM','ZSK') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','ALM','BWM','HAM','HNM','HRM',
		'H3M','QAK','V1P','ZLM','ZRM','ZSK') ) THEN
		  hr_utility.set_message(8301, 'GHR_37319_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, ALM, BWM, HAM, HNM, HRM, H3M, QAK, V1P, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	     end if;
	END IF;

--270.10.2
   --- Upd 56  13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '124'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','ALM','AQM','A7M','BWM','HAM','LBM','NFM',
		'NJM','NMM','QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','ALM','AQM','A7M','BWM','HAM','LBM','NFM',
		'NJM','NMM','QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37320_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, ALM, AQM, A7M, BWM, HAM, LBM,  NFM, NJM, NMM, QAK, QBK, QCK, V1P, ZEA, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	       end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '124'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','ALM','AQM','A7M','BWM','HAM','LBM','NFM',
		'NJM','NMM','QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','ALM','AQM','A7M','BWM','HAM','LBM','NFM',
		'NJM','NMM','QAK','QBK','QCK','V1P','ZLM','ZRM','ZSK') ) THEN
		  hr_utility.set_message(8301, 'GHR_37320_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, ALM, AQM, A7M, BWM, HAM, LBM,  NFM, NJM, NMM, QAK, QBK, QCK, V1P, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	       end if;
	END IF;

--275.01.2
  -- added effective date
  -- added la code Z2U on 23-jul-98
    if p_effective_date < fnd_date.canonical_to_date('1998/03/01') then
       if p_First_NOAC_Lookup_Code= '130'
          and
          NOT ( p_First_Action_NOA_LA_Code1  in
          ('ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'V1P','V8N','Z2U','ZSK','ZSP') AND
           p_First_Action_NOA_LA_Code2 in
          ('ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'V1P','V8N','Z2U','ZSK','ZSP') ) THEN
	    hr_utility.set_message(8301, 'GHR_37321_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;

--275.02.2
   -- Update/Change Date        By        Effective Date            Comment
   --   10/2        08/13/99    vravikan   01-Jan-1999              Add VGL
   --   11/2        12/14/99    vravikan   From the Start           Add ABR
   --   11/9        12/14/99    vravikan   01-Nov-1999              Add UDM
   --               29/07/09    Mani       17-Feb-2009              Add ZEA
    --
    -- The edit 275.01.2 was renamed as 275.02.2 effective 01-mar-1998
    --
  if (p_effective_date >= to_date('2009/02/17','yyyy/mm/dd')) then
     if p_First_NOAC_Lookup_Code= '130'
          and
          NOT ( p_First_Action_NOA_LA_Code1  in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'UDM','V1P','V8N','VGL','Z2U','ZEA','ZSK','ZSP') AND
           p_First_Action_NOA_LA_Code2 in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'UDM','V1P','V8N','VGL','Z2U','ZEA','ZSK','ZSP') ) THEN
	    hr_utility.set_message(8301, 'GHR_37196_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('LAC_CODE','ABR, ABS, ABT, J8M, KTM, KVM, KXM, SZT, UDM, V1P, V8N, VGL, Z2U, ZEA, ZSK, ZSP.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
       if p_First_NOAC_Lookup_Code= '130'
          and
          NOT ( p_First_Action_NOA_LA_Code1  in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'UDM','V1P','V8N','VGL','Z2U','ZSK','ZSP') AND
           p_First_Action_NOA_LA_Code2 in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'UDM','V1P','V8N','VGL','Z2U','ZSK','ZSP') ) THEN
	    hr_utility.set_message(8301, 'GHR_37196_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('LAC_CODE','ABR, ABS, ABT, J8M, KTM, KVM, KXM, SZT, UDM, V1P, V8N, VGL, Z2U, ZSK, ZSP.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
       if p_First_NOAC_Lookup_Code= '130'
          and
          NOT ( p_First_Action_NOA_LA_Code1  in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'V1P','V8N','VGL','Z2U','ZSK','ZSP') AND
           p_First_Action_NOA_LA_Code2 in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'V1P','V8N','VGL','Z2U','ZSK','ZSP') ) THEN
	    hr_utility.set_message(8301, 'GHR_37090_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('1998/03/01','yyyy/mm/dd') then
       if p_First_NOAC_Lookup_Code= '130'
          and
          NOT ( p_First_Action_NOA_LA_Code1  in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'V1P','V8N','Z2U','ZSK','ZSP') AND
           p_First_Action_NOA_LA_Code2 in
          ('ABR','ABS','ABT','J8M','KTM','KVM','KXM','SZT',
          'V1P','V8N','Z2U','ZSK','ZSP') ) THEN
	    hr_utility.set_message(8301, 'GHR_37884_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
   end if;

--275.04.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '132'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('V1P','V6M','ZLM','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('V1P','V6M','ZLM','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37322_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','V1P, V6M, ZEA, ZLM.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '132'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('V1P','V6M','ZLM') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('V1P','V6M','ZLM') ) THEN
		  hr_utility.set_message(8301, 'GHR_37322_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','V1P, V6M, ZLM.');
		hr_utility.raise_error;
	    end if;
	END IF;

--280.02.2
   --   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL
   --   11/2     12/14/99    vravikan   From the start            Add ABR
   --   11/9        12/14/99    vravikan   01-Nov-1999              Add UDM
    -- renumbered from 280.01.2 for the april release
    -- added 'Z2U' on 22-jul-1998
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

  if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '140'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37197_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM, SZW, UDM, V1P, V8N, VGL, Z2U, ZEA, ZLM, ZSK, ZSP.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '140'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37197_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM, SZW, UDM, V1P, V8N, VGL, Z2U, ZLM, ZSK, ZSP.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '140'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37091_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
 else
    if p_First_NOAC_Lookup_Code= '140'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','V1P','V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','SZW','V1P','V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37323_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;

--280.04.2
   --   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL
   --   11/2     12/14/99    vravikan   From the start            Add ABR
   --   11/9        12/14/99    vravikan   01-Nov-1999              Add UDM
    -- added 'Z2U' on 22-jul-1998
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

  if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '141'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37198_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM, UDM, V1P, V8N, VGL, Z2U, ZEA, ZLM, ZSK, ZSP.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '141'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','UDM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37198_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM, UDM, V1P, V8N, VGL, Z2U, ZLM, ZSK, ZSP.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '141'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','V1P','V8N','VGL','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37092_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
 else
    if p_First_NOAC_Lookup_Code= '141'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','V1P','V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM',
        'NUM','V1P','V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37324_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
 end if;

--280.07.2
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/01/99                  Add Legal Authorities P2M and P7M
   -- Dec 2001 Patch               1-Nov-01                  Delete AWM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57    27-Jul-09   Mani       From Start          Added QAK

if p_effective_date < to_date('1999/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '142'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','P3M','P5M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','P3M','P5M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37325_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
    elsif  p_effective_date < to_date('2001/11/01','yyyy/mm/dd') then
     if p_First_NOAC_Lookup_Code= '142'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','P2M','P3M','P5M','P7M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','P2M','P3M','P5M','P7M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC','QAK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37036_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
      end if;
  elsif  p_effective_date < to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '142'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','P2M','P3M','P5M','P7M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','P2M','P3M','P5M','P7M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37906_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','HAM, P2M, P3M, P5M, P7M, QAK, UFM, V2M, ZJR, ZLM, ZSK, ZVB or ZVC.');
        hr_utility.raise_error;
       end if;
  else
    if p_First_NOAC_Lookup_Code= '142'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','P2M','P3M','P5M','P7M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','P2M','P3M','P5M','P7M','QAK','UFM','V2M','ZJR',
        'ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37906_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','HAM, P2M, P3M, P5M, P7M, QAK, UFM, V2M, ZEA, ZJR, ZLM, ZSK, ZVB or ZVC.');
        hr_utility.raise_error;
     end if;
  end if;

--280.10.2
   -- Dec 2001 Patch               1-Nov-01                  Delete AWM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

    if  p_effective_date < to_date('2001/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '143'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','UFM','VBJ','VCJ',
        'ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','UFM','VBJ','VCJ',
        'ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37326_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
    elsif  p_effective_date < to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '143'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','UFM','VBJ','VCJ',
        'ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','UFM','VBJ','VCJ',
        'ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37905_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','HAM, UFM, VBJ, VCJ, ZLM, ZSK, ZVB, ZVC.');
        hr_utility.raise_error;
       end if;
    else
    if p_First_NOAC_Lookup_Code= '143'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','UFM','VBJ','VCJ',
        'ZLM','ZSK','ZVB','ZVC','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','UFM','VBJ','VCJ',
        'ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37905_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','HAM, UFM, VBJ, VCJ, ZEA, ZLM, ZSK, ZVB, ZVC.');
        hr_utility.raise_error;
       end if;
    end if;

--280.13.2
   -- Dec 2001 Patch               1-Nov-01                  Delete AWM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
    if  p_effective_date < to_date('2001/11/01','yyyy/mm/dd') then
      if p_First_NOAC_Lookup_Code= '145'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','UFM','V6M',
	'ZLM','ZSK','ZVB','ZVC') AND
	 p_First_Action_NOA_LA_Code2 in
       ('HAM','UFM','V6M',
	'ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37327_ALL_PROCEDURE_FAIL');
	hr_utility.raise_error;
       end if;
    elsif  p_effective_date < to_date('2009/02/17','yyyy/mm/dd') then
      if p_First_NOAC_Lookup_Code= '145'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','UFM','V6M',
        'ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','UFM','V6M',
        'ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37904_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','HAM, UFM, V6M, ZLM, ZSK, ZVB,ZVC.');
        hr_utility.raise_error;
      end if;
    else
     if p_First_NOAC_Lookup_Code= '145'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','UFM','V6M',
        'ZLM','ZSK','ZVB','ZVC','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','UFM','V6M',
        'ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37904_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','HAM, UFM, V6M, ZEA, ZLM, ZSK, ZVB,ZVC.');
          hr_utility.raise_error;
       end if;
    end if;


--280.16.2
   --            07/10/02    vravikan   From the Start         Added ZVC
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57    27-Jul-09   Mani       From the start         Add QAK

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '146'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','QAK','UFM','V4L','ZJR',
		'ZLM','ZSK','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','QAK','UFM','V4L','ZJR',
		'ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37328_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, QAK, UFM, V4L, ZEA, ZJR, ZLM, ZSK, ZVB, or ZVC.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '146'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','QAK','UFM','V4L','ZJR',
		'ZLM','ZSK','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','QAK','UFM','V4L','ZJR',
		'ZLM','ZSK','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37328_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, QAK, UFM, V4L, ZJR, ZLM, ZSK, ZVB, or ZVC.');
		hr_utility.raise_error;
	    end if;
	END IF;

--280.19.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '147'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','UFM','VAG',
		'ZLM','ZSK','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','UFM','VAG',
		'ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37329_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, UFM, VAG, ZEA, ZLM, ZSK, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '147'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','UFM','VAG',
		'ZLM','ZSK','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','UFM','VAG',
		'ZLM','ZSK','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37329_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, UFM, VAG, ZLM, ZSK, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	END IF;

--280.22.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57    27-Jul-09   Mani       From Start          Added QAK


	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '148'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','QAK','UFM','V4M',
		'ZLM','ZSK','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','QAK','UFM','V4M',
		'ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37330_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, QAK, UFM, V4M, ZEA, ZLM, ZSK, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '148'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','QAK','UFM','V4M',
		'ZLM','ZSK','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','QAK','UFM','V4M',
		'ZLM','ZSK','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37330_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, QAK, UFM, V4M, ZLM, ZSK, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	END IF;

--280.25.2

   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '149'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','UFM','V4P',
		'ZLM','ZSK','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','UFM','V4P',
		'ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37331_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, UFM, V4P, ZEA, ZLM, ZSK, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '149'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','HAM','UFM','V4P',
		'ZLM','ZSK','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','HAM','UFM','V4P',
		'ZLM','ZSK','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37331_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, HAM, UFM, V4P, ZLM, ZSK, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	END IF;

/* Commented -- Dec 2001 Patch
--285.02.2
    --renumbered from 285.01.2 for the april release
    if p_First_NOAC_Lookup_Code= '150'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ALM','AQM','HAM','PWM','P3M','P5M','QAK','QBK','QCK','TJK','TRK','ZJR',
        'ZLM','ZRM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('ALM','AQM','HAM','PWM','P3M','P5M','QAK','QBK','QCK','TJK','TRK','ZJR',
        'ZLM','ZRM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37332_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/

/* Commented -- Dec 2001 Patch
--285.04.2
    if p_First_NOAC_Lookup_Code= '151'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ALM','AQM','HAM','PWM','P3M','P5M','QAK','QBK','QCK','TJK','ZJR',
        'ZRM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('ALM','AQM','HAM','PWM','P3M','P5M','QAK','QBK','QCK','TJK','ZJR',
        'ZRM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37333_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/
/* Commented -- Dec 2001 Patch

--285.07.2
    if p_First_NOAC_Lookup_Code= '153'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','TNM','TMK','TNK','ZLM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','TNM','TMK','TNK','ZLM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37334_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/
/* Commented -- Dec 2001 Patch

--285.10.2
    if p_First_NOAC_Lookup_Code= '154'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','TMK','TNK','ZLM','ZRM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','TMK','TNK','ZLM','ZRM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37335_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/

/* Commented -- Dec 2001 Patch
--285.13.2
    if p_First_NOAC_Lookup_Code= '155'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','TPK''ZLM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','TPK''ZLM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37336_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/
/* Commented -- Dec 2001 Patch

--285.16.2
    if p_First_NOAC_Lookup_Code= '157'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','TVK''ZLM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','TVK''ZLM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37337_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/


--290.02.2

   -- renumbered from 290.01.2 for the april release
   -- added legal authority ZTA on 9-oct-98
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/01/99                  Add Legal Authority P7M
   --   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL
   --   11/9        12/14/99    vravikan   01-Nov-1999              Add UDM
   --   11/11       12/14/99    vravikan   01-Jan-99        Change legal authorities "Y--" to "Y-- (except 'YKB')
   --               17-Aug-00   vravikan   From Begining    Change legal authorities "Y--" to "Y-- (except 'YKB')
   --               08-Dec-00   vravikan   From Begining             Delete ZTA
   -- upd51  06-Feb-07	  Raju             From Begining    Bug#5745356 add legal authority Z6J
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57    30-Jul-09   Mani       From Begining      Added ABR only in the message list

  if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '170'
     and
       NOT (
	      (p_First_Action_NOA_LA_Code1 in
             ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
              'HAM','J8M','PWM','P3M','P5M','QAK','QBK',
              'QCK','UAM','UDM','UFM','VGL','V1P','V8K','V8V','Z2M','Z2U',
              'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J','ZEA')
		  OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
                and
               p_First_Action_NOA_LA_Code1 <> 'YKB' )
		)
           AND
            (p_First_Action_NOA_LA_Code2 in
            ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
             'HAM','J8M','PWM','P3M','P5M','P7M','QAK','QBK',
             'QCK','UAM','UDM','UFM','VGL','V1P','V8K','V8V','Z2M','Z2U',
             'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J','ZEA')
		 OR
            (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
                and
               p_First_Action_NOA_LA_Code2 <> 'YKB' )
 		)
          )
     THEN
	  hr_utility.set_message(8301, 'GHR_37199_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ALM, AQM, BPM, BWM, HAM, H2L, J8M, PWM, P3M, P5M,
      QAK, QBK, QCK, UAM, UDM, UFM, V1P, V8K, V8V, VGL, W--, X--, Y--(other than YKB), Z2M, Z2U, ZEA, ZJR, ZKM,
      ZLM, ZNM, ZRM, ZSK, ZSP, ZVB,ZVC,Z6J.');
          hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '170'
     and
       NOT (
	      (p_First_Action_NOA_LA_Code1 in
             ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
              'HAM','J8M','PWM','P3M','P5M','QAK','QBK',
              'QCK','UAM','UDM','UFM','VGL','V1P','V8K','V8V','Z2M','Z2U',
              'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J')
		  OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
                and
               p_First_Action_NOA_LA_Code1 <> 'YKB' )
		)
           AND
            (p_First_Action_NOA_LA_Code2 in
            ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
             'HAM','J8M','PWM','P3M','P5M','P7M','QAK','QBK',
             'QCK','UAM','UDM','UFM','VGL','V1P','V8K','V8V','Z2M','Z2U',
             'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J')
		 OR
            (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
                and
               p_First_Action_NOA_LA_Code2 <> 'YKB' )
 		)
          )
     THEN
	  hr_utility.set_message(8301, 'GHR_37199_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ALM, AQM, BPM, BWM, HAM, H2L, J8M, PWM, P3M, P5M,
      QAK, QBK, QCK, UAM, UDM, UFM, V1P, V8K, V8V, VGL, W--, X--, Y--(other than YKB), Z2M, Z2U, ZJR, ZKM, ZLM,
      ZNM, ZRM, ZSK, ZSP, ZVB,ZVC,Z6J.');
          hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '170'
     and
       NOT (
	      (p_First_Action_NOA_LA_Code1 in
             ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
              'HAM','J8M','PWM','P3M','P5M','P7M','QAK','QBK',
              'QCK','UAM','UFM','VGL','V1P','V8K','V8V','Z2M','Z2U',
              'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J')
		  OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
                and
               p_First_Action_NOA_LA_Code1 <> 'YKB' )
		)
           AND
            (p_First_Action_NOA_LA_Code2 in
            ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
             'HAM','J8M','PWM','P3M','P5M','P7M','QAK','QBK',
             'QCK','UAM','UFM','VGL','V1P','V8K','V8V','Z2M','Z2U',
             'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J')
		 OR
            (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
                and
               p_First_Action_NOA_LA_Code2 <> 'YKB' )
 		)
          )
     THEN
	  hr_utility.set_message(8301, 'GHR_37037_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
  end if;
else
 if  p_First_NOAC_Lookup_Code= '170'
     and
       NOT (
	      (p_First_Action_NOA_LA_Code1 in
             ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
              'HAM','J8M','PWM','P3M','P5M','QAK','QBK',
              'QCK','UAM','UFM','V1P','V8K','V8V','Z2M','Z2U',
              'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J')
		  OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
               and
              p_First_Action_NOA_LA_Code1 <> 'YKB' )
               )
           AND
            (p_First_Action_NOA_LA_Code2 in
            ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
             'HAM','J8M','PWM','P3M','P5M','QAK','QBK',
             'QCK','UAM','UFM','V1P','V8K','V8V','Z2M','Z2U',
             'ZJR','ZKM','ZLM','ZNM','ZRM','ZSK','ZSP','ZVB','ZVC','Z6J'
             )
		 OR
             (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
               and
              p_First_Action_NOA_LA_Code2 <> 'YKB' )
               )
               )
     THEN
	  hr_utility.set_message(8301, 'GHR_37338_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;

--290.04.2
   -- added legal authority 'ZTA' on 9-oct-98
--   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL
   --   11/9        12/14/99    vravikan   01-Nov-1999              Add UDM
   --   11/11       12/20/99    vravikan   01-Jan-1999       Change legal authorities "Y--" to "Y-- (except 'YKB')
   --   11/11       21-Sep-00   vravikan   From Begining     Change legal authorities "Y--" to "Y-- (except 'YKB')
   --               08-Dec-00   vravikan   From Begining             Delete ZTA
-- upd51  06-Feb-07	  Raju             From Begining    Bug#5745356 add legal authority Z6J
-- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

  if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '171'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UDM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VGL','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J','ZEA')
		OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X')
            OR
            (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
             AND p_First_Action_NOA_LA_Code1 <> 'YKB' )
            )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UDM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VGL','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J','ZEA') OR
           SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X')
            OR
            (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
             AND p_First_Action_NOA_LA_Code2 <> 'YKB' )
            )
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37168_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ALM, BPM, BWM, HAM, H2L, J8M, P3M, QAK, UAM, UFM,
      V1P, V8V, VGL, W--, X--, Y--(other than YKB), Z2M, ZEA, ZKM, ZLM, ZNM, VPE, V8K, ZWM, ZSK, ZSP,
      ZVB,ZVC,Z6J.');
          hr_utility.raise_error;
     end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '171'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UDM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VGL','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J')
		OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X')
            OR
            (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
             AND p_First_Action_NOA_LA_Code1 <> 'YKB' )
            )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UDM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VGL','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J') OR
           SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X')
            OR
            (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
             AND p_First_Action_NOA_LA_Code2 <> 'YKB' )
            )
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37168_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ALM, BPM, BWM, HAM, H2L, J8M, P3M, QAK, UAM, UFM,
      V1P, V8V, VGL, W--, X--, Y--(other than YKB), Z2M, ZKM, ZLM, ZNM, VPE, V8K, ZWM, ZSK, ZSP, ZVB,ZVC,Z6J.');
          hr_utility.raise_error;
     end if;
  elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code= '171'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VGL','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J')
		OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X')
            OR
            (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
             AND p_First_Action_NOA_LA_Code1 <> 'YKB' )
            )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VGL','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J') OR
           SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X')
            OR
            (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
             AND p_First_Action_NOA_LA_Code2 <> 'YKB' )
            )
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37094_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  else
   if  p_First_NOAC_Lookup_Code= '171'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J')
		OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X')
            OR
            (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y')
             AND p_First_Action_NOA_LA_Code1 <> 'YKB'
            )
            )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ALM','AQM','BPM','BWM','H2L',
            'HAM','J8M','P3M','QAK','UAM','UFM','V1P','VEM','V8V',
            'ZKM','ZLM','ZNM','VPE','V8K','ZWM','ZSK','ZSP','ZVB','Z2M','ZVC','Z6J') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
              OR
              (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y')
               and
              p_First_Action_NOA_LA_Code2 <> 'YKB' )
               )
               )
     THEN
	  hr_utility.set_message(8301, 'GHR_37339_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;

--290.20.2
    -- added 'Z2U' on 22-jul-1998
   -- Update Date        By        Effective Date            Comment
   --   8   03/09/99    vravikan   01/31/99                  Delete BEA,BMC,BNE,BNW,BRM
   -- 10/4  08/13/99    vravikan   01-Jan-99                 Add VGL
   --  9/3  09/14/99    vravikan   28-Feb-99                 Delete CTM,NEL
   --  Dec 2001 Patch   vravikan   01-Oct-01                 Delete BFS,MYM, and MZM
   --- Upd 56   13-Mar-09   Manish  17-Feb-2009              Added LA code ZEA

if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
  if  p_First_NOAC_Lookup_Code= '190'
     and
       NOT (
	 (p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','H2L','HAM','J8M','KLM','MXM',
            'M6M','M8M','NAM','NCM',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM','ZEA') OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y')
 		)
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','H2L','HAM','J8M','KLM','MXM',
            'M6M','M8M','NAM','NCM',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM','ZEA') OR
            SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y')
		)
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37922_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACM, AWM, AYM,  BPM, BWA, BWM, HAM,  H2L, J8M, KLM,
      MXM,  M6M, M8M, NAM, NCM, NEM,  NJM, NUM, SZX, UAM, UFM, VJM,  VPE, V1P, V4M, V4P, V8K, V8L, V8N,  V8V, VGL,
      W--, X--, Y--, Z2U, ZEA, ZJK, ZKM, ZLM, ZNM, ZQM, ZRM, ZSK, ZSP, ZTM.');
          hr_utility.raise_error;
     end if;
 elsif p_effective_date >= to_date('2001/10/01','yyyy/mm/dd') then
  if  p_First_NOAC_Lookup_Code= '190'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','H2L','HAM','J8M','KLM','MXM',
            'M6M','M8M','NAM','NCM',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y')
 		)
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','H2L','HAM','J8M','KLM','MXM',
            'M6M','M8M','NAM','NCM',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y')
		)
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37922_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACM, AWM, AYM,  BPM, BWA, BWM, HAM,  H2L, J8M, KLM,
      MXM,  M6M, M8M, NAM, NCM, NEM,  NJM, NUM, SZX, UAM, UFM, VJM,  VPE, V1P, V4M, V4P, V8K, V8L, V8N,  V8V, VGL,
      W--, X--, Y--, Z2U, ZJK, ZKM,  ZLM, ZNM, ZQM, ZRM, ZSK, ZSP, ZTM.');
          hr_utility.raise_error;
     end if;
 elsif p_effective_date >= to_date('1999/02/28','yyyy/mm/dd') then
  if  p_First_NOAC_Lookup_Code= '190'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y')
 		)
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y')
		)
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37188_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('1999/01/31','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '190'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CTM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM','NEL',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y')
 		)
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CTM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM','NEL',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y')
		)
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37043_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('1999/01/01','yyyy/mm/dd') then
  if  p_First_NOAC_Lookup_Code= '190'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM','BEA',
            'BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CTM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM','NEL',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y')
 		)
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM','BEA',
            'BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CTM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM','NEL',
            'NEM','NJM','NUM','SZX','UAM','UFM','VGL',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y')
		)
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37093_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
   if  p_First_NOAC_Lookup_Code= '190'
     and
       NOT (
		(p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM','BEA',
            'BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CTM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM','NEL',
            'NEM','NJM','NUM','SZX','UAM','UFM',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y')
 		)
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM','BEA',
            'BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CTM','H2L','HAM','J8M','KLM','MXM','MYM',
            'MZM','M6M','M8M','NAM','NCM','NEL',
            'NEM','NJM','NUM','SZX','UAM','UFM',
            'VJM','VPE','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','ZJK','ZKM','V8V','Z2U','ZLM','ZNM',
            'ZQM','ZRM','ZSK','ZSP','ZTM') OR
            SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y')
		)
	     )
     THEN
	  hr_utility.set_message(8301, 'GHR_37340_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

   end if;
--290.30.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '198'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('R9R','V1P','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('R9R','V1P','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37341_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','R9R, V1P, ZEA, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '198'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('R9R','V1P','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('R9R','V1P','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37341_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','R9R, V1P, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	END IF;

--290.35.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '199'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('R9N','V1P','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('R9N','V1P','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37342_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','R9N, V1P, ZEA, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '199'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('R9N','V1P','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('R9N','V1P','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37342_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','R9N, V1P, ZVB,ZVC.');
		hr_utility.raise_error;
	    end if;
	END IF;

--295.02.2
    --Renumbered from 295.01.2 for the april release
    if p_First_NOAC_Lookup_Code= '280'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('CUL','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('CUL','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37343_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--295.04.2
-- Update/Change Date        By        Effective Date            Comment
   --   9/5     08/12/99    vravikan   01-Apr-1999               Add ZJV
   -- 2038423   10/08/01    vravikan                             Add ZJW
   -- 7556102   25/12/08    Raju                                 Add UAM
   -- 9379166   23/02/10    Raju                                 Add UAM

    if p_effective_date >= to_date('2010/03/28','yyyy/mm/dd') then
        if p_First_NOAC_Lookup_Code= '292'  and
            NOT ( p_First_Action_NOA_LA_Code1  in
            ('ALM','AQM','CGM','DAM','NYM','PSM','Q3K','QRD',
            'R9N','UAM','UFM','V8V','ZJR','ZJT','ZJU','ZJV','ZJW','ZVB','ZVC') AND
            p_First_Action_NOA_LA_Code2 in
            ('ALM','AQM','CGM','DAM','NYM','PSM','Q3K','QRD',
            'R9N','UAM','UFM','V8V','ZJR','ZJT','ZJU','ZJV','ZJW','ZVB','ZVC') ) THEN
            hr_utility.set_message(8301, 'GHR_37064_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
        end if;
    elsif p_effective_date >= to_date('1999/04/01','yyyy/mm/dd') then
        if p_First_NOAC_Lookup_Code= '292'  and
            NOT ( p_First_Action_NOA_LA_Code1  in
            ('ALM','AQM','CGM','DAM','NYM','PSM','Q3K',
            'R9N','UAM','UFM','V8V','ZJR','ZJT','ZJU','ZJV','ZJW','ZVB','ZVC') AND
            p_First_Action_NOA_LA_Code2 in
            ('ALM','AQM','CGM','DAM','NYM','PSM','Q3K',
            'R9N','UAM','UFM','V8V','ZJR','ZJT','ZJU','ZJV','ZJW','ZVB','ZVC') ) THEN
            hr_utility.set_message(8301, 'GHR_37064_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    else
        if p_First_NOAC_Lookup_Code= '292'
            and NOT ( p_First_Action_NOA_LA_Code1  in
            ('ALM','AQM','CGM','DAM','NYM','PSM','Q3K',
            'R9N','UAM','UFM','V8V','ZJR','ZJT','ZJU','ZJW','ZVB','ZVC') AND
            p_First_Action_NOA_LA_Code2 in
            ('ALM','AQM','CGM','DAM','NYM','PSM','Q3K',
            'R9N','UAM','UFM','V8V','ZJR','ZJT','ZJU','ZJW','ZVB','ZVC') ) THEN
            hr_utility.set_message(8301, 'GHR_37344_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;

    end if;

--295.10.2
    if p_First_NOAC_Lookup_Code= '293'
       and
       Not(
	    p_First_Action_NOA_LA_Code1 in ('R9R','ZVB','ZVC')
	    and
	    p_First_Action_NOA_LA_Code2 in ('R9R','ZVB','ZVC')
		) THEN
	  hr_utility.set_message(8301, 'GHR_37345_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--300.02.2
     -- Renumbered from 300.01.2
     if p_First_NOAC_Lookup_Code= '300'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('SWM','UFM','USM','V8V') AND
         p_First_Action_NOA_LA_Code2 in
       ('SWM','UFM','USM','V8V') ) THEN
	  hr_utility.set_message(8301, 'GHR_37346_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--300.04.2
     if p_First_NOAC_Lookup_Code= '301'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('SUM','UFM','USM','V8V') AND
         p_First_Action_NOA_LA_Code2 in
       ('SUM','UFM','USM','V8V') ) THEN
	  hr_utility.set_message(8301, 'GHR_37347_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

GHR_CPDF_CHECK4A.chk_Legal_Authority_a
  (p_To_Play_Plan
  ,p_Agency_Sub_Element
  ,p_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_LA_Code2
  ,p_First_NOAC_Lookup_Code
  ,p_effective_date
  ,p_position_occupied_code
  ) ;
end chk_Legal_Authority;

end GHR_CPDF_CHECK4;

/
