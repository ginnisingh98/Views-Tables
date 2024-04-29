--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK4A
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK4A" as
/* $Header: ghcpdf4a.pkb 120.6.12010000.9 2010/02/25 07:07:16 utokachi ship $ */

-- Legal Authority

procedure chk_Legal_Authority_a
  (p_To_Play_Plan              in varchar2
  ,p_Agency_Sub_Element        in varchar2
  ,p_First_Action_NOA_LA_Code1 in varchar2
  ,p_First_Action_NOA_LA_Code2 in varchar2
  ,p_First_NOAC_Lookup_Code    in varchar2
  ,p_effective_date            in date
  ,p_position_occupied_code    in varchar2
  ) is
begin

--300.07.2
     if p_First_NOAC_Lookup_Code= '302'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('SQM','SRM','UFM','USM','V8V') AND
         p_First_Action_NOA_LA_Code2 in
       ('SQM','SRM','UFM','USM','V8V') ) THEN
	  hr_utility.set_message(8301, 'GHR_37348_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--300.10.2
     if p_First_NOAC_Lookup_Code= '303'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('AZM','USM','V3P','V8V','ZLM') AND
         p_First_Action_NOA_LA_Code2 in
       ('AZM','USM','V3P','V8V','ZLM') ) THEN
	  hr_utility.set_message(8301, 'GHR_37349_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--300.13.2
     if p_First_NOAC_Lookup_Code= '304'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('SQM','USM','V8V') AND
         p_First_Action_NOA_LA_Code2 in
       ('SQM','USM','V8V') ) THEN
	  hr_utility.set_message(8301, 'GHR_37350_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--300.16.2
    -- added 'Z2U' on 22-jul-1998
   -- Update/Change Date        By        Effective Date            Comment
   --   10/2        08/13/99    vravikan   01-Aug-1999              Change R5M to R6M
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/08/01') then
     if p_First_NOAC_Lookup_Code= '312'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('RPM','RPR','RQM','RRM','RSM','RTM','RTR','RUM','RWM',
        'RXM','R6M','R7M','R8M','R9M','V8V','Z2U','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('RPM','RPR','RQM','RRM','RSM','RTM','RTR','RUM','RWM',
        'RXM','R6M','R7M','R8M','R9M','V8V','Z2U','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37082_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  else
     if p_First_NOAC_Lookup_Code= '312'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('RPM','RPR','RQM','RRM','RSM','RTM','RTR','RUM','RWM',
        'RXM','R5M','R7M','R8M','R9M','V8V','Z2U','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('RPM','RPR','RQM','RRM','RSM','RTM','RTR','RUM','RWM',
        'RXM','R5M','R7M','R8M','R9M','V8V','Z2U','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37351_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  end if;

--300.19.2
   -- Update/Change Date        By        Effective Date            Comment
   --   10/2        08/13/99    vravikan   01-Aug-1999              Change R5M to R6M
   --               30/12/08    Raju                                Added UFM, removed R7M,R8M,R9M
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/08/01') then
     if p_First_NOAC_Lookup_Code= '317'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('RPM','RQM','RRM','RSM','RUM','R6M','UFM','V8V','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('RPM','RQM','RRM','RSM','RUM','R6M','UFM','V8V','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37083_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  else
     if p_First_NOAC_Lookup_Code= '317'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('RPM','RQM','RRM','RSM','RUM','R5M','UFM','V8V','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('RPM','RQM','RRM','RSM','RUM','R5M','UFM','V8V','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37352_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  end if;

--305.02.2
    -- added 'Z2U' on 22-jul-1998
    -- added 'Z2W' on 9-oct-98
	-- Upd 47	 23-Jun-06	 Raju	From Begining	  Added VAA
     if p_First_NOAC_Lookup_Code= '330'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','LTM','LUM','QGM','QHM','RYM','UAM','UFM','VAA','VAJ','VHJ','VJJ','VWP',
        'VWR','V2J','V4J','V5J','V6J','V7J','V8J','V8K','V8V','V9A','V9B','Z2U',
        'Z2W','ZEM','ZLM','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','LTM','LUM','QGM','QHM','RYM','UAM','UFM','VAA','VAJ','VHJ','VJJ','VWP',
        'VWR','V2J','V4J','V5J','V6J','V7J','V8J','V8K','V8V','V9A','V9B','Z2U',
        'Z2W','ZEM','ZLM','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37353_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--307.02.2
     -- Renumbered from 307.01.2
     if p_First_NOAC_Lookup_Code= '351'
       and
       NOT ( p_First_Action_NOA_LA_Code1 ='RPM' AND
         p_First_Action_NOA_LA_Code2  ='RPM' ) THEN
	  hr_utility.set_message(8301, 'GHR_37354_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--310.02.2
    -- added 'Z2U' on 22-jul-1998
     if p_First_NOAC_Lookup_Code= '352'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('DBM','DFM','DKM','HAM','PDM','PZM','VCR','VCS','VCT',
        'VCW','VDJ','V8V','Z2U','ZPM','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('DBM','DFM','DKM','HAM','PDM','PZM','VCR','VCS','VCT',
        'VCW','VDJ','V8V','Z2U','ZPM','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37355_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--310.05.2
-- Update/Change Date        By        Effective Date            Comment
   --   9/5     08/12/99    vravikan   01-Apr-1999               Add ZJV
   -- 2038423   10/08/01    vravikan                             Add ZJW

  if p_effective_date >= to_date('1999/04/01','yyyy/mm/dd') then

     if p_First_NOAC_Lookup_Code= '353'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('Q3K','UFM','V8V','ZJR','ZJS','ZJT','ZJU','ZJV','ZJW','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q3K','UFM','V8V','ZJR','ZJS','ZJT','ZJU','ZJV','ZJW','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37167_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
    else
     if p_First_NOAC_Lookup_Code= '353'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('Q3K','UFM','V8V','ZJR','ZJS','ZJT','ZJU','ZJW','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q3K','UFM','V8V','ZJR','ZJS','ZJT','ZJU','ZJW','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37356_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
	end if;
--310.11.2
     -- added legal authority Z2W on 9-oct-98
	 --upd47  26-Jun-06	Raju	   From Beginning	    Added Z5N
	 --upd57  27-Jul-09     Mani       From 01-MAR-2009         Removed Z5N

    if p_effective_date >= to_date('2009/03/01','yyyy/mm/dd') then
     if p_First_NOAC_Lookup_Code= '356'  and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','PNM','PNR','UAM','UFM','VDK','VGL','V8K','V8V','Z2W','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','PNM','PNR','UAM','UFM','VDK','VGL','V8K','V8V','Z2W','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37357_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','HAM, PNM, PNR, UAM, UFM, VDK, VGL, V8K, V8V, Z2W, ZVB,ZVC.');
        hr_utility.raise_error;
       end if;
    else
     if p_First_NOAC_Lookup_Code= '356'  and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','PNM','PNR','UAM','UFM','VDK','VGL','V8K','V8V','Z2W','ZVB','ZVC','Z5N') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','PNM','PNR','UAM','UFM','VDK','VGL','V8K','V8V','Z2W','ZVB','ZVC','Z5N') ) THEN
	  hr_utility.set_message(8301, 'GHR_37357_ALL_PROCEDURE_FAIL');
 	  hr_utility.set_message_token('LAC_CODE','HAM, PNM, PNR, UAM, UFM, VDK, VGL, V8K, V8V, Z2W, ZVB,ZVC,Z5N.');
        hr_utility.raise_error;
       end if;
     end if;

--310.14.2
    -- added 'Z2U' on 22-jul-1998
     if p_First_NOAC_Lookup_Code= '357'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('A3M','C7M','HAM','LTM','LUM','MUM','R9Q','UAM','UFM',
        'USM','UTM','UXM','UYM','VAA','VCM','V8K','V8N','V8V',
        'Z2U','ZLJ','ZLK','ZLL','ZLM','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('A3M','C7M','HAM','LTM','LUM','MUM','R9Q','UAM','UFM',
        'USM','UTM','UXM','UYM','VAA','VCM','V8K','V8N','V8V',
        'Z2U','ZLJ','ZLK','ZLL','ZLM','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37358_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--315.02.2
--   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL
    -- added 'Z2U' on 22-jul-1998
if p_effective_date >= fnd_date.canonical_to_date('19'||'99/01/01') then
  if p_First_NOAC_Lookup_Code= '385'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'HAM','L2M','L4M','L5M','L6M','L8M','LXM','UFM','VGL',
        'VUM','VYM','V2M','V8V','Z2U','ZSP','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','L2M','L4M','L5M','L6M','L8M','LXM','UFM','VGL',
        'VUM','VYM','V2M','V8V','Z2U','ZSP','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37095_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

else
     if p_First_NOAC_Lookup_Code= '385'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'HAM','L2M','L4M','L5M','L6M','L8M','LXM','UFM',
        'VUM','VYM','V2M','V8V','Z2U','ZSP','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','L2M','L4M','L5M','L6M','L8M','LXM','UFM',
        'VUM','VYM','V2M','V8V','Z2U','ZSP','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37359_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;
--320.02.2
     if p_First_NOAC_Lookup_Code= '430' then
        if p_First_Action_NOA_LA_Code1 not in ('CUL','ZVB','ZVC') or
           NVL(p_First_Action_NOA_LA_Code2, 'CUL') not in ('CUL','ZVB','ZVC') then
           hr_utility.set_message(8301, 'GHR_37360_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
        end if;
     end if;

--320.05.2
     if p_First_NOAC_Lookup_Code= '450'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'UAM','UFM','USP','USR','VAA','VAB','VAC','VAD','VAE','VAV', 'V4J',
        'V8V','VWJ','ZEM','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM','UFM','USP','USR','VAA','VAB','VAC','VAD','VAE','VAV', 'V4J',
        'V8V','VWJ','ZEM','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37361_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;


--320.08.2
     if p_First_NOAC_Lookup_Code= '452'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'UAM','UFM','USM','VAJ', 'VHJ','V8V','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM','UFM','USM','VAJ', 'VHJ','V8V','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37362_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--320.11.2
     if p_First_NOAC_Lookup_Code= '460'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'DAK','DAM','L9K','NYM','Q3K','UFM','V8V','ZJR','ZJT','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('DAK','DAM','L9K','NYM','Q3K','UFM','V8V','ZJR','ZJT','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37363_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--320.14.2
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/01/99                  End date
   if p_effective_date < fnd_date.canonical_to_date('19'||'99/01/01') then
     if p_First_NOAC_Lookup_Code= '462'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'GFM','R4M','UFM','V8V','ZVB') AND
         p_First_Action_NOA_LA_Code2 in
       ('GFM','R4M','UFM','V8V','ZVB') ) THEN
	  hr_utility.set_message(8301, 'GHR_37364_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
   end if;

--320.17.2
     if p_First_NOAC_Lookup_Code= '471'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'L9K','PNM','UFM','USM','VAJ','VDR','V8V','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('L9K','PNM','UFM','USM','VAJ','VDR','V8V','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37365_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--320.20.2
     if p_First_NOAC_Lookup_Code= '472'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'L9K','PNM','UFM','USM','VAJ','VDR','V8V','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('L9K','PNM','UFM','USM','VAJ','VDR','V8V','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37366_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;


--320.23.2
-- Update/Change Date        By        Effective Date            Comment
   --   9/5     08/12/99    vravikan   01-Apr-1999               Add ZJV
   -- 2038423   10/08/01    vravikan                             Add ZJW
   -- 9379166   28/03/10    Raju                                 Add QRD

  if p_effective_date >= to_date('2010/03/28','yyyy/mm/dd') then

     if p_First_NOAC_Lookup_Code= '473'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'Q3K','QRD','V8V','ZJU','ZJV','ZJW','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q3K','QRD','V8V','ZJU','ZJV','ZJW','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37066_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
     end if;
  elsif p_effective_date >= to_date('1999/04/01','yyyy/mm/dd') then

     if p_First_NOAC_Lookup_Code= '473'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'Q3K','V8V','ZJU','ZJV','ZJW','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q3K','V8V','ZJU','ZJV','ZJW','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37066_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
     end if;
  else
     if p_First_NOAC_Lookup_Code= '473'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ( 'Q3K','V8V','ZJU','ZJW','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q3K','V8V','ZJU','ZJW','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37367_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

  end if;

--320.26.2
--   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL

     -- added legal authority Z2W on 9-oct-98
if p_effective_date >= fnd_date.canonical_to_date('19'||'99/01/01') then
     if p_First_NOAC_Lookup_Code= '480'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','V3M','VGL','Z2W','ZSP','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','V3M','VGL','Z2W','ZSP','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37096_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
if p_First_NOAC_Lookup_Code= '480'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','V3M','Z2W','ZSP','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','V3M','Z2W','ZSP','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37368_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;

--
-- START OF 325.02.2
    -- added 'BNK' and deleted 'VHM' for the april 98 release
    -- added 'Z2U' on 22-jul-1998
    -- added 'ZTA','Z2W' on 9-oct-98
   -- Update   Date        By        Effective Date        Comment
   --   8     03/09/99    vravikan   01/31/99               Delete BEA,BMC,BNE
   --                                                        ,BNW,BRM
   --   10/4  08/13/99    vravikan   01-Jan-99              Add VGL
   --   11/1  12/13/99    vravikan   01-Dec-99              Add ZBA
   --   11/9  12/14/99    vravikan   01-Nov-1999            Add UDM
   --         17-Aug-00   vravikan   From Begining          Add ZBA
   --         08-Dec-00   vravikan   From Begining          Delete ZTA
   --         30-Oct-03   Ashley     From Begining          Added BAB,BAC,BAD,BYO
   --	      30-APR-04   Madhuri    From Beginning         Added LYP for 500
   --  Upd 37 09-NOV-04   Madhuri    From beginning         Added LAC's - BNR, BNT
   --  Upd 43 09-NOV-05   Raju       From beginning         Added BAE
   --  Upd 39 07-MAR-06   vnarasim   From beginning         Added BNY
   -- Upd 47  23-Jun-06	  Raju		 From Begining			Added ZJK, Z5B, Z5C, Z5D, Z5E
    -- upd49  19-Jan-07	  Raju       From 01-Feb-2005	    Bug#5619873 delete BNT
    -- upd49  19-Jan-07	  Raju       From Beginning	    Bug#5619873 add BAF
    -- Upd 54 12-Jun-07   vmididho   From Begining          delete BAF
   --- Upd 56 13-Mar-09   Manish     01-Jan-2009            Added LA code BAG
   --- Upd 56 13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57 30-Jul-09   Mani       From Begining          Added ZVB

  if p_effective_date >= to_date('19'||'99/12/01','yyyy/mm/dd') then
    if p_effective_date < fnd_date.canonical_to_date('2005/02/01') then --Bug#5619873
        if p_First_NOAC_Lookup_Code= '500' and
           NOT ( p_First_Action_NOA_LA_Code1  in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BYO',
            'BBM','BDN','BLM','BNK','BNR', 'BNT','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA', 'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') AND
            p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BYO',
            'BBM','BDN','BLM','BNK','BNR', 'BNT','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA',
            'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') ) THEN
            hr_utility.set_message(8301, 'GHR_37299_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    elsif p_effective_date < fnd_date.canonical_to_date('2009/01/01') then --Begin Bug#5619873
        if p_First_NOAC_Lookup_Code= '500' and
           NOT ( p_First_Action_NOA_LA_Code1  in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BYO',
            'BBM','BDN','BLM','BNK','BNR','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA', 'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') AND
            p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BYO',
            'BBM','BDN','BLM','BNK','BNR','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA',
            'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') ) THEN
            hr_utility.set_message(8301, 'GHR_37862_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, AYM, A2M, BWM, BAB, BAC, BAD, BAE,
            BYO, BBM, BDN, BLM, BNK, BNM, BNN, BNR, BNY, BWA, BWM, BYM, HAM, K1M, K7M, K8M, K9M, LBM, LEM,  LHM,
            LJM, LKM, LKP, LLM, LPM, LSM, LWM, LYM, LYP, LZM, L1M, L2K, L3M, PNR, P5M, UDM,VJM, V1P, V8N, VGL,
            Z2U, Z2W, ZBA, ZGM, ZGY, ZHK, ZJK, ZJM, ZLM, ZMM, ZQM, ZRM, ZSK, ZSP, ZTR, ZTU, ZTZ, ZVB, Z5B, Z5C, Z5D,
            Z5E.');
            hr_utility.raise_error;
        end if;
        --End Bug#5619873
        --Bug# 8329793
    elsif p_effective_date < fnd_date.canonical_to_date('2009/02/17') then
        if p_First_NOAC_Lookup_Code= '500' and
           NOT ( p_First_Action_NOA_LA_Code1  in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BAG','BYO',
            'BBM','BDN','BLM','BNK','BNR','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA', 'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') AND
            p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BAG','BYO',
            'BBM','BDN','BLM','BNK','BNR','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA',
            'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') ) THEN
            hr_utility.set_message(8301, 'GHR_37862_ALL_PROCEDURE_FAIL');
   	        hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, AYM, A2M, BWM, BAB, BAC, BAD, BAE,
            BAG, BYO, BBM, BDN, BLM, BNK, BNM, BNN, BNR, BNY, BWA, BWM, BYM, HAM, K1M, K7M, K8M, K9M, LBM, LEM,
            LHM, LJM, LKM, LKP, LLM, LPM, LSM, LWM, LYM, LYP, LZM, L1M, L2K, L3M, PNR, P5M, UDM,VJM, V1P, V8N,
            VGL, Z2U, Z2W, ZBA, ZGM, ZGY, ZHK, ZJK, ZJM, ZLM, ZMM, ZQM, ZRM, ZSK, ZSP, ZTR, ZTU, ZTZ, ZVB, Z5B, Z5C,
            Z5D, Z5E.');
            hr_utility.raise_error;
        end if;
    else
        if p_First_NOAC_Lookup_Code= '500' and
           NOT ( p_First_Action_NOA_LA_Code1  in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BAG','BYO',
            'BBM','BDN','BLM','BNK','BNR','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA', 'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E','ZEA') AND
            p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
            'BAB','BAC','BAD','BAE','BAG','BYO',
            'BBM','BDN','BLM','BNK','BNR','BNY',
            'BNM','BNN','BWA','BWM',
            'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
            'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
            'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
            'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
            'ZBA',
            'ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
            'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E','ZEA') ) THEN
	    hr_utility.set_message(8301, 'GHR_37862_ALL_PROCEDURE_FAIL');
	    hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, AYM, A2M, BWM, BAB, BAC, BAD, BAE, BAG,
        BYO, BBM, BDN, BLM, BNK, BNM, BNN, BNR, BNY, BWA, BWM, BYM, HAM, K1M, K7M, K8M, K9M, LBM, LEM,  LHM, LJM,
        LKM, LKP, LLM, LPM, LSM, LWM, LYM, LYP, LZM, L1M, L2K, L3M, PNR, P5M, UDM,VJM, V1P, V8N, VGL, Z2U, Z2W,
        ZBA, ZEA, ZGM, ZGY, ZHK, ZJK, ZJM, ZLM, ZMM, ZQM, ZRM, ZSK, ZSP, ZTR, ZTU, ZTZ, ZVB, Z5B, Z5C, Z5D, Z5E.');
	    hr_utility.raise_error;
        end if;
    end if;
    --Bug# 8329793
  elsif p_effective_date > to_date('19'||'99/11/01','yyyy/mm/dd') then

    if p_First_NOAC_Lookup_Code= '500'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','UDM','VJM','V1P','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37169_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then

    if p_First_NOAC_Lookup_Code= '500'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','VJM','V1P','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','VJM','V1P','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37044_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
if p_First_NOAC_Lookup_Code= '500'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
      	'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','VJM','V1P','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','VJM','V1P','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37098_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
if p_First_NOAC_Lookup_Code= '500'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','VJM','V1P','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR', 'BNT','BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LWM','LYM','LZM','L1M','L2K','L3M','LYP',
        'PNR','P5M','VJM','V1P','V8N','Z2U','Z2W',
        'ZBA','ZGM','ZGY','ZHK','ZJK','ZJM','ZLM','ZMM','ZQM',
        'ZRM','ZSK','ZSP','ZTR','ZTU','ZTZ','ZVB','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37369_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

end if;
-- END OF 325.02.2
--
-- START OF 325.05.2
    -- added 'BNK' for the april 98 release
    -- added 'Z2U' on 22-jul-1998
    -- added 'ZTA','Z2W' on 9-oct-98
    -- Update Date        By        Effective Date      Comment
    --   8   03/09/99    vravikan   01/31/99            Delete BEA,BMC
    --                                                   ,BNE,BNW,BRM
    -- 10/4  08/13/99    vravikan   01-Jan-99           Add VGL
    -- 11/1  12/13/99    vravikan   01-Dec-99           Add ZBA
    -- 11/9  12/14/99    vravikan   01-Nov-1999         Add UDM
    --       17-Aug-00   vravikan   From Begining       Add ZBA,Delete BNP
   --        08-Dec-00   vravikan   From Begining       Delete ZTA
   --        30-Oct-03   Ashley     From Begining       Added BAB,BAC,BAD,BYO
   --	     30-APR-04   Madhuri    From Beginning      Added LYP for 501
   --  Upd 37 09-NOV-04   Madhuri   From beginning      Added LAC's - BNR, BNT
   --  Upd 43 09-NOV-05   Raju      From beginning      Added BAE
   -- upd49  19-Jan-07	  Raju      From beginning	    Bug#5619873 delete BNT,add BAF
   --  Upd 54 12-Jun-07   vmididho  From Begining      delete BAF
   --- Upd 56 13-Mar-09   Manish     01-Jan-2009               Added LA code BAG
   --- Upd 56 13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57 30-Jul-09   Mani      From Begining       Added Z5B, Z5C, Z5D, Z5E
   -- GPPA U51  14-Aug-09 Raju       11-Sep-2009        Added LAM(8799026)

  --Begin Bug# 8799026
  if p_effective_date >= to_date('2009/09/11','yyyy/mm/dd') then
      if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BBM','BDN','BLM','BNK','BNR','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LAM','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','ZEA','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LAM','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','ZEA','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37300_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, AYM, A2M, BAG, BBM, BDN,  BLM, BNK, BNM,
      BNR, BNY, BWM, BAB, BAC, BAD, BAE, BYO, BNN,  BWA, BWM, BYM, HAM, K1M, K7M, K8M, K9M, LAM, LBM, LEM, LHM, LJM,
      LKM, LKP, LLM, LPM, LSM, LYM, LYP, LZM, L1M, L2K, L3M, PNR, P5M, UDM, V1P, V8M, V8N, VGL, Z2U, Z2W, ZBA,
      ZEA, ZGM, ZHK, ZJK, ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ, Z5B, Z5C, Z5D, Z5E.');
          hr_utility.raise_error;
       end if;
--End Bug# 8799026
  elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
      if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BBM','BDN','BLM','BNK','BNR','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','ZEA','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','ZEA','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37300_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, AYM, A2M, BAG, BBM, BDN,  BLM, BNK, BNM,
      BNR, BNY, BWM, BAB, BAC, BAD, BAE, BYO, BNN,  BWA, BWM, BYM, HAM, K1M, K7M, K8M, K9M, LBM, LEM, LHM, LJM,
      LKM, LKP, LLM, LPM, LSM, LYM, LYP, LZM, L1M, L2K, L3M, PNR, P5M, UDM, V1P, V8M, V8N, VGL, Z2U, Z2W, ZBA,
      ZEA, ZGM, ZHK, ZJK, ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ, Z5B, Z5C, Z5D, Z5E.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') then
      if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BBM','BDN','BLM','BNK','BNR','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','ZEA','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','ZEA','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37300_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, AYM, A2M, BAG, BBM, BDN,  BLM, BNK, BNM,
      BNR, BNY, BWM, BAB, BAC, BAD, BAE, BYO, BNN,  BWA, BWM, BYM, HAM, K1M, K7M, K8M, K9M, LBM, LEM, LHM, LJM,
      LKM, LKP, LLM, LPM, LSM, LYM, LYP, LZM, L1M, L2K, L3M, PNR, P5M, UDM, V1P, V8M, V8N, VGL, Z2U, Z2W, ZBA,
      ZGM, ZHK, ZJK, ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ, Z5B, Z5C, Z5D, Z5E.');
          hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/12/01','yyyy/mm/dd') then
      if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR','BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM',
        'ZBA','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37300_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACA, ACM, AYM, A2M, BBM, BDN,  BLM, BNK, BNM, BNR,
      BNY, BWM, BAB, BAC, BAD, BAE, BYO, BNN,  BWA, BWM, BYM, HAM, K1M, K7M, K8M, K9M, LBM, LEM, LHM, LJM, LKM,
      LKP, LLM, LPM, LSM, LYM, LYP, LZM, L1M, L2K, L3M, PNR, P5M, UDM, V1P, V8M, V8N, VGL, Z2U, Z2W, ZBA, ZGM,
      ZHK, ZJK, ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ, Z5B, Z5C, Z5D, Z5E.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/11/01','yyyy/mm/dd') then
if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','UDM','V1P','V8M','V8N','VGL','Z2U','Z2W',
        'ZBA','ZGM','ZHK','ZJK','ZJM',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37289_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then
if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM','ZHK','ZJK','ZJM',
        'ZBA','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BLM','BNK','BNR', 'BNY',
        'BNM','BNN','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM','ZHK','ZJK','ZJM',
        'ZBA','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37045_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
        'BAB','BAC','BAD','BAE','BYO',
        'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR', 'BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM','ZHK','ZJK','ZJM',
        'ZBA','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
        'BAB','BAC','BAD','BAE','BYO',
        'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR', 'BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','V1P','V8M','V8N','VGL','Z2U','Z2W','ZGM','ZHK','ZJK','ZJM',
        'ZBA','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37084_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  else
if p_First_NOAC_Lookup_Code= '501'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
 	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR', 'BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','V1P','V8M','V8N','Z2U','Z2W','ZGM','ZHK','ZJK','ZJM',
        'ZBA','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ACA','ACM','AYM','A2M',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BBM','BDN','BEA','BLM','BMC','BNE','BNK','BNR','BNY',
        'BNM','BNN','BNW','BRM','BWA','BWM',
        'BYM','HAM','K1M','K7M','K8M','K9M','LBM',
        'LEM','LHM','LJM','LKM','LKP','LLM','LPM',
        'LSM','LYM','LZM','L1M','L2K','L3M','LYP','PNR',
        'P5M','V1P','V8M','V8N','Z2U','Z2W','ZGM','ZHK','ZJK','ZJM',
        'ZBA','ZLM','ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5D','Z5E') ) THEN
	  hr_utility.set_message(8301, 'GHR_37370_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

      end if;

-- END OF 325.05.2
--

--325.17.2
    -- added 'Z2U' on 22-jul-1998
   -- Update/Change Date        By        Effective Date            Comment
   --   8/5        03/09/99    vravikan                             Add BWA
   --   8/5        03/09/99    vravikan    02/27/99                 Delete ACM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57    30-Jul-09   Mani       01-Jan-2009               Added LA code BAG

  if p_effective_date >= fnd_date.canonical_to_date('2009/02/17') then
    if p_First_NOAC_Lookup_Code= '507'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM','BAG','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM','BAG','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37052_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BAG, BWM, BWA, HAM,  HDM, HGM, HJM, HLM, NUM, PNR, V1P,  V8N, Z2U, ZEA, ZLM, ZRM, ZSK.');
          hr_utility.raise_error;
    end if;
  elsif p_effective_date >= fnd_date.canonical_to_date('2009/01/01') then
    if p_First_NOAC_Lookup_Code= '507'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM','BAG','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM','BAG','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37052_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BAG, BWM, BWA, HAM,  HDM, HGM, HJM, HLM, NUM, PNR, V1P,  V8N, Z2U, BAG, ZLM, ZRM, ZSK.');
          hr_utility.raise_error;
    end if;
  elsif p_effective_date >= fnd_date.canonical_to_date('19'||'99/02/27') then
    if p_First_NOAC_Lookup_Code= '507'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37052_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, BWA, HAM,  HDM, HGM, HJM, HLM, NUM, PNR, V1P,  V8N, Z2U, ZLM, ZRM, ZSK.');
        hr_utility.raise_error;
    end if;
  else
    if p_First_NOAC_Lookup_Code= '507'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ACM','AYM','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','ACM','AYM','BWA','BWM',
        'HAM','HDM','HGM','HJM','HLM','NUM','PNR',
        'V1P','V8N','Z2U','ZLM','ZRM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37371_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
  end if;


--325.20.2
    -- added 'Z2U' on 22-jul-1998
    -- added 'Z2W' on 9-oct-98
   -- Update/Change  Date        By        Effective Date      Comment
   --   8/5        03/09/99    vravikan    01/31/99            Delete BEA,BMC,BNE,BNW,BRM
   --   8/5        03/09/99    vravikan                        Add ZTU
   --   8/5        03/09/99    vravikan    02/27/99            Delete ACM,MLL,MCM
  --   10/4        08/13/99    vravikan   01-Jan-99            Add VGL
  --   11/9        12/14/99    vravikan   01-Nov-1999          Add UDM
  --               10/30/03    Ashley     From Begining        Added BAB,BAC,BAD,BYO
  --  Upd 43	   09-NOV-05   Raju       From beginning       Added BAE
  -- Upd 47		   23-Jun-06   Raju	      From Begining			Added Z5B, Z5C, Z5F, Z5H, Z5J
   -- upd49        19-Jan-07   Raju       From Beginning       Bug#5619873 add BAF
  --  Upd 54       12-Jun-07   vmididho   From Begining        delete BAF
  --- Upd 56       13-Mar-09   Manish     01-Jan-2009               Added LA code BAG
  --- Upd 56       13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
  -- Upd 57        30-Jul-09   Mani       01-Mar-2009          Removed Z5H
  -- Upd 57        30-Jul-09   Mani       From Begining        Added LA codde Z6L
  -- GPPA U51      14-Aug-09   Raju       11-Sep-2009          Added LDM(8799026)

   --Begin Bug# 8799026
  if p_effective_date >= to_date('2009/09/11','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '508' and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','LDM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5J','ZEA','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','LDM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5J','ZEA','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37290_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, AYM, BWM,BAB,BAC,BAD, BAE, BAG, BYO,
        BWA, BWM, HAM, LDM, MEM, MGM, MJM, MLK, MLM, MMM, NMM, NUM, PNR, UDM, VJM, V1P, V8N, VGL, Z2U, Z2W, ZEA, ZJK,
        ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ,Z5B, Z5C, Z5F, Z5J, Z6L.');
            hr_utility.raise_error;
     end if;
  --End Bug# 8799026
  elsif p_effective_date >= to_date('2009/03/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5J','ZEA','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5J','ZEA','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37290_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, AYM, BWM,BAB,BAC,BAD, BAE, BAG, BYO,
        BWA, BWM, HAM,  MEM, MGM, MJM, MLK, MLM, MMM, NMM, NUM, PNR, UDM, VJM, V1P, V8N, VGL, Z2U, Z2W, ZEA, ZJK,
        ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ,Z5B, Z5C, Z5F, Z5J, Z6L.');
            hr_utility.raise_error;
     end if;
  elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','ZEA','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','ZEA','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37290_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, AYM, BWM,BAB,BAC,BAD, BAE, BAG, BYO,
        BWA, BWM, HAM,  MEM, MGM, MJM, MLK, MLM, MMM, NMM, NUM, PNR, UDM, VJM, V1P, V8N, VGL, Z2U, Z2W, ZEA, ZJK,
        ZJM, ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ,Z5B, Z5C, Z5F, Z5H, Z5J, Z6L.');
            hr_utility.raise_error;
     end if;
  elsif p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37290_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, AYM, BWM,BAB,BAC,BAD, BAE, BAG, BYO,
        BWA, BWM, HAM,  MEM, MGM, MJM, MLK, MLM, MMM, NMM, NUM, PNR, UDM, VJM, V1P, V8N, VGL, Z2U, Z2W, ZJK, ZJM,
        ZLM, ZQM, ZRM, ZSK, ZSP, ZTU, ZTZ,Z5B, Z5C, Z5F, Z5H, Z5J, Z6L.');
            hr_utility.raise_error;
     end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO',
	    'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','UDM','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37290_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, ABS, AYM, BWM,BAB,BAC,BAD, BAE,BYO, BWA, BWM,
        HAM,  MEM, MGM, MJM, MLK, MLM, MMM, NMM, NUM, PNR, UDM, VJM, V1P, V8N, VGL, Z2U, Z2W, ZJK, ZJM, ZLM, ZQM,
        ZRM, ZSK, ZSP, ZTU, ZTZ,Z5B, Z5C, Z5F, Z5H, Z5J, Z6L.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date >= to_date('19'||'99/02/27','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MEM','MGM','MJM','MLK',
        'MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37053_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','AYM',
        'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM','MLK',
        'MLL','MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','AYM',
        'BAB','BAC','BAD','BAE','BYO',
        'BWA','BWM','HAM','MCM','MEM','MGM','MJM','MLK',
        'MLL','MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') ) THEN
	    hr_utility.set_message(8301, 'GHR_37046_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
  if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','AYM',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNW','BRM','BWA',
        'BWM','HAM','MCM','MEM','MGM','MJM','MLK',
        'MLL','MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','AYM',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNW','BRM','BWA',
        'BWM','HAM','MCM','MEM','MGM','MJM','MLK',
        'MLL','MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','VGL','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37099_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

    else
     if p_First_NOAC_Lookup_Code= '508'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABK','ABL','ABM','ABR','ABS','ACM','AYM',
	    'BAB','BAC','BAD','BAE','BYO',
	   'BEA','BMC','BNE','BNW','BRM','BWA',
        'BWM','HAM','MCM','MEM','MGM','MJM','MLK',
        'MLL','MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABK','ABL','ABM','ABR','ABS','ACM','AYM',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNW','BRM','BWA',
        'BWM','HAM','MCM','MEM','MGM','MJM','MLK',
        'MLL','MLM','MMM','NMM','NUM','PNR','VJM',
        'V1P','V8N','Z2U','Z2W','ZJK','ZJM','ZLM',
        'ZQM','ZRM','ZSK','ZSP','ZTU','ZTZ','Z5B','Z5C','Z5F','Z5H','Z5J','Z6L') ) THEN
	  hr_utility.set_message(8301, 'GHR_37372_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
 end if;

--325.23.2
-- added 'Z2U' on 22-jul-1998
 -- UPDATE/CHANGE DATE        UPDATED BY     EFFECTIVE_DATE     COMMENTS
 -------------------------------------------------------------------------------------
 --   10/4     08/13/99       vravikan       01-Jan-99           Add VGL
 -- 14-SEP-2004		      Madhuri
 -------------------------------------------------------------------------------------
IF ( p_effective_date <= to_date('20'||'04/08/31','yyyy/mm/dd') ) THEN

 IF p_effective_date >= fnd_date.canonical_to_date('19'||'99/01/01') then
    if p_First_NOAC_Lookup_Code= '512'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','AYM','BWM','HAM',
        'MAM','MBM','PNR','V1P','V8N','VGL',
        'Z2U','ZLM','ZRM','ZSK','ZSP','ZTU') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','AYM','BWM','HAM',
        'MAM','MBM','PNR','V1P','V8N','VGL',
        'Z2U','ZLM','ZRM','ZSK','ZSP','ZTU') ) THEN
	  hr_utility.set_message(8301, 'GHR_37100_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
 ELSE
    if p_First_NOAC_Lookup_Code= '512'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','AYM','BWM','HAM',
        'MAM','MBM','PNR','V1P','V8N',
        'Z2U','ZLM','ZRM','ZSK','ZSP','ZTU') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','AYM','BWM','HAM',
        'MAM','MBM','PNR','V1P','V8N',
        'Z2U','ZLM','ZRM','ZSK','ZSP','ZTU') ) THEN
	  hr_utility.set_message(8301, 'GHR_37373_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
 END IF;

END IF; -- END DATE CHECK

--325.26.2
    -- added 'Z2U' on 22-jul-1998
    -- added 'Z2W' on 12-oct-1998
   -- Update Date        By        Effective Date  Bug       Comment
   --   8   03/09/99    vravikan   01/31/99                  Delete BEA,BMC,BNE,BNW,BRM
   --   8   03/09/99    vravikan   02/27/99                  Delete ACM,NEL,MXM,CTM
   --   8   04/22/99    vravikan   02/27/99        871385    Add CTM,MXM
   -- 10/4  08/13/99    vravikan   01-Jan-99                 Add VGL
   --  9/3  09/15/99    vravikan   27-Feb-99       992944    Delete CTM,MXM
   --       11/17/99    AVR        27-Feb-99       1079338   Add MXM
  --   11/9 12/14/99    vravikan   01-Nov-1999               Add UDM
  --        10/30/03    Ashley     From Begining             Added BAB,BAC,BAD,BYO
  --  Upd 43    09-NOV-05   Raju       From beginning            Added BAE
  -- Upd 47  23-Jun-06	  Raju		 From Begining			Added Z5B, Z5C, Z5F, Z5G, Z5H
  -- upd49  19-Jan-07	  Raju       From Beginning	        Bug#5619873 add BAF,WTA,WTB,WUM
  --  Upd 54 12-Jun-07  vmididho   From Begining             delete BAF
  --- Upd 56 13-Mar-09   Manish     01-Jan-2009               Added LA code BAG
  --- Upd 56 13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
  -- GPPA U51 14-Aug-09  Raju       11-Sep-2009               Added LCM(8799026)

	--Begin Bug# 8799026
  if p_effective_date >= to_date('2009/09/11','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO','BNM','BWA','BWM',
        'HAM','KLM','LCM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO','BNM','BWA','BWM',
        'HAM','KLM','LCM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') ) THEN
		hr_utility.set_message(8301, 'GHR_37291_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, AYM, BWA, BWM, BAB, BAC, BAD, BAE, BAG, BYO,
        BWM, HAM, LCM, KLM, MXM, M6M,M8M, NAM, NCM,  NEM, NMM, NUM, PNR, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB,
        WUM, Z2U, Z2W, ZEA, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU,Z5B, Z5C, Z5F, Z5G, Z5H.');
		hr_utility.raise_error;
    end if;
	--End Bug# 8799026
  elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H','ZEA') ) THEN
		hr_utility.set_message(8301, 'GHR_37291_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, AYM, BWA, BWM, BAB, BAC, BAD, BAE, BAG, BYO,
        BWM, HAM, KLM, MXM, M6M,M8M, NAM, NCM,  NEM, NMM, NUM, PNR, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB,
        WUM, Z2U, Z2W, ZEA, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU,Z5B, Z5C, Z5F, Z5G, Z5H.');
		hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BAG','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
		hr_utility.set_message(8301, 'GHR_37291_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, AYM, BWA, BWM, BAB, BAC, BAD, BAE, BAG, BYO,
        BWM, HAM, KLM, MXM, M6M,M8M, NAM, NCM,  NEM, NMM, NUM, PNR, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB,
        WUM, Z2U, Z2W, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU,Z5B, Z5C, Z5F, Z5G, Z5H.');
		hr_utility.raise_error;
    end if;
  elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','UDM','VGL','VJM','V1P','V8L',
        'V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
        hr_utility.set_message(8301, 'GHR_37291_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, AYM, BWA, BWM, BAB, BAC, BAD, BAE, BYO, BWM,
        HAM, KLM, MXM, M6M,M8M, NAM, NCM,  NEM, NMM, NUM, PNR, SZX, UDM, VJM, V1P, V8L, V8N, VGL, WTA, WTB, WUM,
        Z2U, Z2W, ZJK, ZLM, ZQM, ZRM, ZSK, ZSP, ZTM, ZTU,Z5B, Z5C, Z5F, Z5G, Z5H.');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/02/28','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','VGL','VJM','V1P','V8L','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','AYM',
        'BAB','BAC','BAD','BAE','BYO','BNM','BWA','BWM',
        'HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEM','NMM','NUM','PNR',
        'SZX','VGL','VJM','V1P','V8L','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37054_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
  elsif p_effective_date > to_date('19'||'99/01/31','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ACM','AYM',
        'BAB','BAC','BAD','BAE','BYO','BNM','BWA','BWM',
        'CTM','HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEL','NEM','NMM','NUM','PNR',
        'SZX','VGL','VJM','V1P','V8L','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','ACM','AYM',
        'BAB','BAC','BAD','BAE','BYO','BNM','BWA','BWM',
        'CTM','HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEL','NEM','NMM','NUM','PNR',
        'SZX','VGL','VJM','V1P','V8L','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37047_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ACM','AYM',
        'BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNM','BRM','BWA','BWM',
	    'CTM','HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEL','NEM','NMM','NUM','PNR',
        'SZX','VJM','V1P','V8L','VGL','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','ACM','AYM',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNM','BRM','BWA','BWM',
        'CTM','HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEL','NEM','NMM','NUM','PNR',
        'SZX','VGL','VJM','V1P','V8L','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37170_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

  else
    if p_First_NOAC_Lookup_Code= '515'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','ACM','AYM',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNM','BRM','BWA','BWM',
        'CTM','HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEL','NEM','NMM','NUM','PNR',
        'SZX','VJM','V1P','V8L','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','ACM','AYM',
	    'BAB','BAC','BAD','BAE','BYO',
	    'BEA','BMC','BNE','BNM','BRM','BWA','BWM',
        'CTM','HAM','KLM','MXM','M6M','M8M',
        'NAM','NCM','NEL','NEM','NMM','NUM','PNR',
        'SZX','VJM','V1P','V8L','V8N','WTA','WTB','WUM','Z2U','Z2W','ZJK',
        'ZLM','ZQM','ZRM','ZSK','ZSP','ZTM','ZTU','Z5B','Z5C','Z5F','Z5G','Z5H') ) THEN
	  hr_utility.set_message(8301, 'GHR_37374_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;
--325.29.2
/* This is commented by skutteti on 8-apr-98 as this has to be deleted as per the
   update 6 of the edit manual for the april release.

   if  p_First_NOAC_Lookup_Code= '517'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABL','ABM','ABR','ABS','BWM','HAM','MXM',
           'M2M','M4M','M6M','M8M','NCM','NEM','NUM',
           'PNR','UAM','UFM','V1P','V8N','V8V','ZLM',
           'ZSK','ZSP','ZVB','ZVM','Z2M') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 AND p_First_Action_NOA_LA_Code1 <>'WWM' ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABL','ABM','ABR','ABS','BWM','HAM','MXM',
           'M2M','M4M','M6M','M8M','NCM','NEM','NUM',
           'PNR','UAM','UFM','V1P','V8N','V8V','ZLM',
           'ZSK','ZSP','ZVB','ZVM','Z2M') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 AND p_First_Action_NOA_LA_Code1 <>'WWM')))
     THEN
	  hr_utility.set_message(8301, 'GHR_37375_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/

--325.32.2
	-- Upd 47  23-Jun-06  Raju	 From Begining	Added AYM,Z5C
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
   --- Upd 57    30-Jul-09   Mani       01-Jan-2009               Added LA code BAG

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '520'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','AYM','BAG','BWM','HAM','HNM','HRM','PNR','V1P','ZLM','ZRM','ZSK','Z5C','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','AYM','BAG','BWM','HAM','HNM','HRM','PNR','V1P','ZLM','ZRM','ZSK','Z5C','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37376_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, AYM, BAG, BWM, HAM, HNM, HRM, PNR, V1P, ZEA, ZLM, ZRM, ZSK, Z5C.');
		hr_utility.raise_error;
	    end if;
	ELSIF ( p_effective_date >= to_date('2009/01/01','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '520'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','AYM','BAG','BWM','HAM','HNM','HRM','PNR','V1P','ZLM','ZRM','ZSK','Z5C') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','AYM','BAG','BWM','HAM','HNM','HRM','PNR','V1P','ZLM','ZRM','ZSK','Z5C') ) THEN
		  hr_utility.set_message(8301, 'GHR_37376_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, AYM, BAG, BWM, HAM, HNM, HRM, PNR, V1P, ZLM, ZRM, ZSK, Z5C.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '520'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','AYM','BWM','HAM','HNM','HRM','PNR','V1P','ZLM','ZRM','ZSK','Z5C') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','AYM','BWM','HAM','HNM','HRM','PNR','V1P','ZLM','ZRM','ZSK','Z5C') ) THEN
		  hr_utility.set_message(8301, 'GHR_37376_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, AYM, BWM, HAM, HNM, HRM, PNR, V1P, ZLM, ZRM, ZSK, Z5C.');
		hr_utility.raise_error;
	    end if;
	END IF;

--325.35.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '522'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','BWM','HAM','HNM','HRM','H3M','PNR','V1P','ZLM','ZRM','ZSK','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','BWM','HAM','HNM','HRM','H3M','PNR','V1P','ZLM','ZRM','ZSK','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37377_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, BWM, HAM, HNM, HRM, H3M, PNR, V1P, ZEA, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '522'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','BWM','HAM','HNM','HRM','H3M','PNR','V1P','ZLM','ZRM','ZSK') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','BWM','HAM','HNM','HRM','H3M','PNR','V1P','ZLM','ZRM','ZSK') ) THEN
		  hr_utility.set_message(8301, 'GHR_37377_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, BWM, HAM, HNM, HRM, H3M, PNR, V1P, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	    end if;
	END IF;

--325.38.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '524'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','A7M','BWM','HAM','HNM','LBM','NFM','NMM','PNR','V1P','ZLM','ZRM','ZSK','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','A7M','BWM','HAM','HNM','LBM','NFM','NMM','PNR','V1P','ZLM','ZRM','ZSK','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37378_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, A7M, BWM, HAM, LBM, NFM, NMM, PNR, V1P, ZEA, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '524'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('ABM','A7M','BWM','HAM','HNM','LBM','NFM','NMM','PNR','V1P','ZLM','ZRM','ZSK') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('ABM','A7M','BWM','HAM','HNM','LBM','NFM','NMM','PNR','V1P','ZLM','ZRM','ZSK') ) THEN
		  hr_utility.set_message(8301, 'GHR_37378_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','ABM, A7M, BWM, HAM, LBM, NFM, NMM, PNR, V1P, ZLM, ZRM, ZSK.');
		hr_utility.raise_error;
	    end if;
	END IF;

--325.44.2
    -- added 'Z2U' on 22-jul-1998
   --   10/4  08/13/99    vravikan   01-Jan-99                 Add VGL
   -- 11/2    12/14/99    vravikan   From the Start            Add ABR
   --   11/9  12/14/99    vravikan   01-Nov-1999              Add UDM
   --- Upd 56 13-Mar-09   Manish     17-Feb-2009              Added LA code ZEA
   --- Upd 57 30-Jul-09   Mani       01-Mar-2009              Remove U2M
   --- Upd 57 30-Jul-09   Mani       From Begining            Add V2M

if p_effective_date >= to_date('2009/03/01','yyyy/mm/dd') then

    if p_First_NOAC_Lookup_Code= '540'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37292_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM,  PNR, QGM, QHM, UDM, USM, VAJ, VCS,  VCT, VCW, VDJ, VFJ, VGJ, VGL, VHJ, V1P, V2M, V8N, Z2U, ZEA, ZLM, ZSK, ZSP.');
          hr_utility.raise_error;
    end if;
elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then

    if p_First_NOAC_Lookup_Code= '540'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37292_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM,  PNR, QGM, QHM, U2M, UDM, USM, VAJ, VCS,  VCT, VCW, VDJ, VFJ, VGJ, VGL, VHJ, V1P, V2M, V8N, Z2U, ZEA, ZLM, ZSK, ZSP.');
          hr_utility.raise_error;
    end if;
elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then

    if p_First_NOAC_Lookup_Code= '540'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37292_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM,  PNR, QGM, QHM, U2M, UDM, USM, VAJ, VCS,  VCT, VCW, VDJ, VFJ, VGJ, VGL, VHJ, V1P, V2M, V8N, Z2U, ZLM, ZSK, ZSP.');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then

    if p_First_NOAC_Lookup_Code= '540'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37171_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
    if p_First_NOAC_Lookup_Code= '540'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37379_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

end if;
--325.47.2
    -- added 'Z2U' on 22-jul-1998
  -- Update/Change Date        By        Effective Date            Comment
  --   8/5      03/09/99    vravikan                             Add ABR
  --   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL
  --   11/9     12/14/99    vravikan   01-Nov-1999              Add UDM
  --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
  --- Upd 57 30-Jul-09   Mani       01-Mar-2009              Remove U2M
   --- Upd 57 30-Jul-09   Mani       From Begining            Add V2M



if p_effective_date >= to_date('2009/03/01','yyyy/mm/dd') then

   if p_First_NOAC_Lookup_Code= '541'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P', 'V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','VGL','V1P', 'V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37293_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM, PNR, QGM, QHM, UDM, USM, VAJ, VCS,  VCT, VCW, VDJ, VFJ, VGJ, VGL, VHJ, V1P, V2M, V8N, ZEA, Z2U, ZLM, ZSK, ZSP.');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then

   if p_First_NOAC_Lookup_Code= '541'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P', 'V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','VGL','V1P', 'V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37293_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM, PNR, QGM, QHM, UDM, USM, U2M, VAJ, VCS,  VCT, VCW, VDJ, VFJ, VGJ, VGL, VHJ, V1P, V2M, V8N, ZEA, Z2U, ZLM, ZSK, ZSP.');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then

   if p_First_NOAC_Lookup_Code= '541'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P', 'V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','UDM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','VGL','V1P', 'V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37293_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABL, ABM, ABR, ABS, BWM, HAM, KQM, NUM, PNR, QGM, QHM, UDM, USM, U2M, VAJ, VCS,  VCT, VCW, VDJ, VFJ, VGJ, VGL, VHJ, V1P, V2M, V8N, Z2U, ZLM, ZSK, ZSP.');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then

   if p_First_NOAC_Lookup_Code= '541'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VGL','VHJ','V1P', 'V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','VGL','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37172_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
if p_First_NOAC_Lookup_Code= '541'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') AND
         p_First_Action_NOA_LA_Code2 in
       ('ABL','ABM','ABR','ABS','BWM','HAM','KQM','NUM',
        'PNR','QGM','QHM','USM','U2M','VAJ','VCS',
        'VCT','VCW','VDJ','VFJ','VGJ','VHJ','V1P','V2M',
        'V8N','Z2U','ZLM','ZSK','ZSP') ) THEN
	  hr_utility.set_message(8301, 'GHR_37380_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

end if;
--325.50.2
   -- Dec 2001 Patch               1-Nov-01                  Delete AWM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

  if  p_effective_date < to_date('2001/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '542'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('BWM','HAM','HRM','NRM','NTM','PNR',
        'P3M','P5M','UFM','V2M','ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('BWM','HAM','HRM','NRM','NTM','PNR',
        'P3M','P5M','UFM','V2M','ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37381_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
    end if;
  elsif ( p_effective_date < to_date('2009/02/17','yyyy/mm/dd') ) THEN
    if p_First_NOAC_Lookup_Code= '542'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('BWM','HAM','HRM','NRM','NTM','PNR',
        'P3M','P5M','UFM','V2M','ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('BWM','HAM','HRM','NRM','NTM','PNR',
        'P3M','P5M','UFM','V2M','ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37903_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','BWM, HAM, NRM, NTM, NXM, PNR, P3M, P5M, UFM, V2M, ZLM, ZSK, ZVB,ZVC.');
        hr_utility.raise_error;
    end if;
  else
    if p_First_NOAC_Lookup_Code= '542'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('BWM','HAM','HRM','NRM','NTM','PNR',
        'P3M','P5M','UFM','V2M','ZLM','ZSK','ZVB','ZVC','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('BWM','HAM','HRM','NRM','NTM','PNR',
        'P3M','P5M','UFM','V2M','ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37903_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','BWM, HAM, NRM, NTM, NXM, PNR, P3M, P5M, UFM, V2M, ZEA, ZLM, ZSK, ZVB,ZVC.');
        hr_utility.raise_error;
    end if;
  end if;

--325.53.2
   -- Dec 2001 Patch               1-Nov-01                  Delete AWM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

    if  p_effective_date < to_date('2001/11/01','yyyy/mm/dd') then
      if p_First_NOAC_Lookup_Code= '543'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('BWM','HAM','PNR',
        'UFM','VBJ','VCJ','ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('BWM','HAM','PNR',
        'UFM','VBJ','VCJ','ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37382_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
      end if;
    elsif  p_effective_date < to_date('2009/02/17','yyyy/mm/dd') then
     if p_First_NOAC_Lookup_Code= '543'
        and
        NOT ( p_First_Action_NOA_LA_Code1  in
        ('BWM','HAM','PNR',
         'UFM','VBJ','VCJ','ZLM','ZSK','ZVB','ZVC') AND
          p_First_Action_NOA_LA_Code2 in
        ('BWM','HAM','PNR',
         'UFM','VBJ','VCJ','ZLM','ZSK','ZVB','ZVC') ) THEN
	   hr_utility.set_message(8301, 'GHR_37902_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('LAC_CODE','BWM, HAM, PNR, UFM, VBJ, VCJ, ZLM, ZSK, ZVB,ZVC.');
           hr_utility.raise_error;
      end if;
    else
     if p_First_NOAC_Lookup_Code= '543'
        and
        NOT ( p_First_Action_NOA_LA_Code1  in
        ('BWM','HAM','PNR',
         'UFM','VBJ','VCJ','ZLM','ZSK','ZVB','ZVC','ZEA') AND
          p_First_Action_NOA_LA_Code2 in
        ('BWM','HAM','PNR',
         'UFM','VBJ','VCJ','ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
	   hr_utility.set_message(8301, 'GHR_37902_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('LAC_CODE','BWM, HAM, PNR, UFM, VBJ, VCJ, ZEA, ZLM, ZSK, ZVB,ZVC.');
           hr_utility.raise_error;
      end if;
    end if;

--325.57.2
   -- Dec 2001 Patch               1-Nov-01                  Add AUM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

    if  p_effective_date < to_date('2001/11/01','yyyy/mm/dd') then
     if p_First_NOAC_Lookup_Code= '546'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('AUM','AWM','BWM','HAM','NSM','NWM','PNR',
        'UFM','V4L','ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('AUM','AWM','BWM','HAM','NSM','NWM','PNR',
        'UFM','V4L','ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37383_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
   elsif  p_effective_date < to_date('2009/02/17','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '546'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('AUM','AWM','BWM','HAM','NSM','NWM','PNR',
        'UFM','V4L','ZLM','ZSK','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('AUM','AWM','BWM','HAM','NSM','NWM','PNR',
        'UFM','V4L','ZLM','ZSK','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37901_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','AUM, AWM, BWM, HAM, NSM, NWM, PNR, UFM, V4L, ZLM, ZSK, ZVB,ZVC.');
        hr_utility.raise_error;
     end if;
   else
    if p_First_NOAC_Lookup_Code= '546'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('AUM','AWM','BWM','HAM','NSM','NWM','PNR',
        'UFM','V4L','ZLM','ZSK','ZVB','ZVC','ZEA') AND
         p_First_Action_NOA_LA_Code2 in
       ('AUM','AWM','BWM','HAM','NSM','NWM','PNR',
        'UFM','V4L','ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
	  hr_utility.set_message(8301, 'GHR_37901_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','AUM, AWM, BWM, HAM, NSM, NWM, PNR, UFM, V4L, ZEA, ZLM, ZSK, ZVB,ZVC.');
        hr_utility.raise_error;
     end if;
   end if;

--325.60.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '548'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','BWM','HAM','NVM','PNR',
		'UFM','V4M','ZLM','ZSK','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','BWM','HAM','NVM','PNR',
		'UFM','V4M','ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37384_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, BWM, HAM, NVM, PNR, UFM, V4M, ZEA, ZLM, ZSK, ZVB, ZVC.');
		  hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '548'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','BWM','HAM','NVM','PNR',
		'UFM','V4M','ZLM','ZSK','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','BWM','HAM','NVM','PNR',
		'UFM','V4M','ZLM','ZSK','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37384_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, BWM, HAM, NVM, PNR, UFM, V4M, ZLM, ZSK, ZVB, ZVC.');
		  hr_utility.raise_error;
	    end if;
	END IF;

--325.63.2
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA
	IF ( p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') ) THEN
	    if p_First_NOAC_Lookup_Code= '549'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','BWM','HAM','PNR',
		'UFM','V4P','ZLM','ZSK','ZVB','ZVC','ZEA') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','BWM','HAM','PNR',
		'UFM','V4P','ZLM','ZSK','ZVB','ZVC','ZEA') ) THEN
		  hr_utility.set_message(8301, 'GHR_37385_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, BWM, HAM, PNR, UFM, V4P, ZEA, ZLM  ZSK, ZVB,ZVC.');
		  hr_utility.raise_error;
	    end if;
	ELSE
	    if p_First_NOAC_Lookup_Code= '549'
	       and
	       NOT ( p_First_Action_NOA_LA_Code1  in
	       ('AWM','BWM','HAM','PNR',
		'UFM','V4P','ZLM','ZSK','ZVB','ZVC') AND
		 p_First_Action_NOA_LA_Code2 in
	       ('AWM','BWM','HAM','PNR',
		'UFM','V4P','ZLM','ZSK','ZVB','ZVC') ) THEN
		  hr_utility.set_message(8301, 'GHR_37385_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('LAC_CODE','AWM, BWM, HAM, PNR, UFM, V4P, ZLM  ZSK, ZVB,ZVC.');
		  hr_utility.raise_error;
	    end if;
	END IF;

/* Commented -- Dec 2001 Patch
--325.66.2
    if p_First_NOAC_Lookup_Code= '550'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','PNR','P5M','TJK','TRK','TRL','TTK','TXK',
        'ZLM','ZSK','ZRM') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','PNR','P5M','TJK','TRK','TRL','TTK','TXK',
        'ZLM','ZSK','ZRM') ) THEN
	  hr_utility.set_message(8301, 'GHR_37386_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/
/* Commented -- Dec 2001 Patch

--325.69.2
    if p_First_NOAC_Lookup_Code= '551'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','PNR','P5M','TJK','TRL','TTK','TXK',
        'ZLM','ZSK','ZRM') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','PNR','P5M','TJK','TRL','TTK','TXK',
        'ZLM','ZSK','ZRM') ) THEN
	  hr_utility.set_message(8301, 'GHR_37387_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/
/* Commented -- Dec 2001 Patch

--325.72.2
    if p_First_NOAC_Lookup_Code= '553'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','PNR','TMK','TNK','TNM',
        'ZLM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','PNR','TMK','TNK','TNM',
        'ZLM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37388_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/
/* Commented -- Dec 2001 Patch

--325.75.2
    if p_First_NOAC_Lookup_Code= '554'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','PNR','TMK','TNK',
        'ZRM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','PNR','TMK','TNK',
        'ZRM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37389_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/
/* Commented -- Dec 2001 Patch

--325.78.2
    if p_First_NOAC_Lookup_Code= '555'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('HAM','PNR','TPK','ZLM','ZSK') AND
         p_First_Action_NOA_LA_Code2 in
       ('HAM','PNR','TPK','ZLM','ZSK') ) THEN
	  hr_utility.set_message(8301, 'GHR_37390_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
*/

--325.81.2
--   10/4     08/13/99    vravikan   01-Jan-1999                 Add VGL
--   11/9     12/14/99    vravikan   01-Nov-1999              Add UDM
--   11/11    12/20/99    vravikan   01-Jan-1999              Change legal authorities "Y--" to "Y-- (except 'YKB')
--            21-Sep-00   vravikan   From Begining            Change legal authorities "Y--" to "Y-- (except 'YKB')
   --         08-Dec-00   vravikan   From Begining             Delete ZTA
   -- added 'ZTA' on 12-oct-1998
   -- upd51  06-Feb-07	  Raju       From Begining	    Bug#5745356 add Legal autority Z6J
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '570'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM',
            'UDM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VGL','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J','ZEA') OR
           ((SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X'))
           OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y') AND
             p_First_Action_NOA_LA_Code1 <> 'YKB' )
           AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )
           )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM',
            'UDM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VGL','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J','ZEA') OR
           ((SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
            OR
             (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y') AND
               p_First_Action_NOA_LA_Code2 <> 'YKB'
             ) AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37294_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, BPM, BWM, HAM, H2L, J8M, PNR, P5M, QGM, QHM,
      UAM, UDM, UFM, USM, U2M, VAJ, VCS, VCT, VCW, VDJ, VFJ, VGJ, VHJ, V1P, V8K, V8V, VGL, W--, X--, Y--
      (other than YKB), ZEA, ZKM, ZLM, ZNM, ZRM, ZSK, ZSP, ZTZ, ZVB, ZVC, Z2M, Z2U,Z6J.');
          hr_utility.raise_error;
    end if;
elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '570'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM',
            'UDM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VGL','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J') OR
           ((SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X'))
           OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y') AND
             p_First_Action_NOA_LA_Code1 <> 'YKB' )
           AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )
           )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM',
            'UDM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VGL','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J') OR
           ((SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
            OR
             (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y') AND
               p_First_Action_NOA_LA_Code2 <> 'YKB'
             ) AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37294_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, BPM, BWM, HAM, H2L, J8M, PNR, P5M, QGM, QHM,
      UAM, UDM, UFM, USM, U2M, VAJ, VCS, VCT, VCW, VDJ, VFJ, VGJ, VHJ, V1P, V8K, V8V, VGL, W--, X--, Y--
      (other than YKB), ZKM, ZLM, ZNM, ZRM, ZSK, ZSP, ZTZ, ZVB, ZVC, Z2M, Z2U,Z6J.');
          hr_utility.raise_error;
    end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '570'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VGL','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J') OR
           ((SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X'))
           OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y') AND
             p_First_Action_NOA_LA_Code1 <> 'YKB' )
           AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )
           )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VGL','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J') OR
           ((SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X'))
            OR
             (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y') AND
               p_First_Action_NOA_LA_Code2 <> 'YKB'
             ) AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37173_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
if  p_First_NOAC_Lookup_Code= '570'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J') OR
           SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('Y') AND
             p_First_Action_NOA_LA_Code1 <> 'YKB' )
           )
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','QGM','QHM','UAM','UFM',
            'USM','U2M','VAJ','VCS', 'VCT', 'VCW','VDJ',
            'VFJ','VGJ','VHJ','V1P','V8K','Z2U','ZKM','ZLM','ZNM',
            'ZRM','ZSK','ZSP','ZTZ','ZVB','ZVC','Z2M','Z6J') OR
           SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('Y') AND
             p_First_Action_NOA_LA_Code2 <> 'YKB' )
           )
           )
     THEN
	  hr_utility.set_message(8301, 'GHR_37391_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

end if;

--325.84.2
   -- added 'ZTA' on 12-oct-1998
--   10/4     08/13/99    vravikan   01-Jan-99                 Add VGL
--   11/9     12/14/99    vravikan   01-Nov-1999              Add UDM
 -- upd51  06-Feb-07	  Raju       From Begining	    Bug#5745356 add Legal autority Z6J
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '571'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UDM','UFM',
            'V1P','V8K','V8V','VGL','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J','ZEA') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UDM','UFM',
            'V1P','V8K','V8V','VGL','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J','ZEA') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37295_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, BPM, BWM, HAM, H2L, J8M, PNR, UAM, UDM, UFM, V1P, V8K, V8V, VGL, W--, X--, Y--, Z2M, ZEA, ZKM, ZLM, ZNM, ZSK, ZSP, ZVB,ZVC, ZWM,Z6J.');
          hr_utility.raise_error;
     end if;
elsif p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '571'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UDM','UFM',
            'V1P','V8K','V8V','VGL','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UDM','UFM',
            'V1P','V8K','V8V','VGL','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37295_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ABR, BPM, BWM, HAM, H2L, J8M, PNR, UAM, UDM, UFM, V1P, V8K, V8V, VGL, W--, X--, Y--, Z2M, ZKM, ZLM, ZNM, ZSK, ZSP, ZVB,ZVC, ZWM,Z6J.');
          hr_utility.raise_error;
     end if;
elsif p_effective_date >= to_date('19'||'99/01/01','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '571'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UFM',
            'V1P','V8K','V8V','VGL','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UFM',
            'V1P','V8K','V8V','VGL','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37174_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
if  p_First_NOAC_Lookup_Code= '571'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UFM',
            'V1P','V8K','V8V','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','BPM',
            'BWM','H2L','HAM','J8M','PNR','UAM','UFM',
            'V1P','V8K','V8V','Z2M','ZKM','ZLM','ZNM',
            'ZSK','ZSP','ZTA','ZVB','ZVC','ZWM','Z6J') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37392_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;

--325.90.2
    -- added 'Z2U' on 22-jul-1998
   -- Update Date        By        Effective Date            Comment
   --   8   03/09/99    vravikan   01/31/99                  Delete BEA,BMC,BNE, BNW,BRM
   -- 10/4  08/13/99    vravikan   01-Jan-99                 Add VGL
   --  9/3  09/14/99    vravikan   28-Feb-99                 Delete CTM,NEL
   --  Dec 2001 Patch   vravikan   01-Oct-01                 Delete BFS,MYM, MZM
   --- Upd 56    13-Mar-09   Manish     17-Feb-2009               Added LA code ZEA

if p_effective_date >= to_date('2009/02/17','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code= '590'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','M6M','M8M','NAM','NCM',
            'NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM','ZEA') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','M6M','M8M','NAM','NCM',
            'NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM','ZEA') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37921_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACM, AWM, AYM,   BPM, BWA, BWM, CRK, CRL,  CRN, C1K,
      C2K, C3K, C4K,  C1L, C2L, C3L, C4L, C1N, C2N,  C3N, C4N, HAM, H2L, J8M, KLM,  MXM, M6M, M8M, NAM,  NCM, NEM,
      NUM, NVM, PNR, UAM,  UFM, VJM, V1P, V4M, V4P, V8K, V8L,  V8N, V8V, VGL, W--, X--, Y--, Z2U, ZEA, ZJK, ZKM,
      ZLM, ZNM, ZQM, ZRM, ZSK, ZSP, ZTM.');
          hr_utility.raise_error;
  end if;
elsif p_effective_date >= to_date('2001/10/01','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code= '590'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','M6M','M8M','NAM','NCM',
            'NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','M6M','M8M','NAM','NCM',
            'NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37921_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('LAC_CODE','ABK, ABL, ABM, ACM, AWM, AYM,   BPM, BWA, BWM, CRK, CRL,  CRN, C1K,
      C2K, C3K, C4K,  C1L, C2L, C3L, C4L, C1N, C2N,  C3N, C4N, HAM, H2L, J8M, KLM,  MXM, M6M, M8M, NAM,  NCM, NEM,
      NUM, NVM, PNR, UAM,  UFM, VJM, V1P, V4M, V4P, V8K, V8L,  V8N, V8V, VGL, W--, X--, Y--, Z2U, ZJK, ZKM,  ZLM,
      ZNM, ZQM, ZRM, ZSK, ZSP, ZTM.');
          hr_utility.raise_error;
  end if;
elsif p_effective_date >= to_date('1999/02/28','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code= '590'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37189_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
  end if;
elsif p_effective_date > to_date('1999/01/31','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code= '590'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','CTM','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEL','NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BPM','BWA',
            'BWM','CRK','CRL','CRN','CTM','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEL','NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37048_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('1999/01/01','yyyy/mm/dd') then
if  p_First_NOAC_Lookup_Code= '590'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BEA','BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CRK','CRL','CRN','CTM','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEL','NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BEA','BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CRK','CRL','CRN','CTM','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEL','NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L','VGL',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37175_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
if  p_First_NOAC_Lookup_Code= '590'
     and
       NOT ((p_First_Action_NOA_LA_Code1 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BEA','BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CRK','CRL','CRN','CTM','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEL','NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code1,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code1) =3 ))
           AND
          (p_First_Action_NOA_LA_Code2 in
           ('ABK','ABL','ABM','ABR','ABS','ACM','AWM','AYM',
            'BEA','BMC','BNE','BNW','BPM','BRM','BWA',
            'BWM','CRK','CRL','CRN','CTM','C1K','C2K',
            'C3K','C4K','C1L','C2L','C3L','C4L','C1N',
            'C2N','C3N','C4N','H2L','HAM','J8M','KLM',
            'MXM','MYM','MZM','M6M','M8M','NAM','NCM',
            'NEL','NEM','NUM','NVM','PNR','UAM','UFM',
            'VJM','V1P','V4M','V4P','V8K','V8L',
            'V8N','V8V','Z2U','ZJK','ZKM','ZLM',
            'ZNM','ZQM','ZRM','ZSK','ZSP','ZTM') OR
           (SUBSTR(p_First_Action_NOA_LA_Code2,1,1) IN ('W','X','Y') AND
           LENGTH(p_First_Action_NOA_LA_Code2) =3 )))
     THEN
	  hr_utility.set_message(8301, 'GHR_37393_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;
--328.02.2
    -- added LA code ZSE on 23-jul-98
	--upd47  26-Jun-06	Raju	   From Beginning    Added ZSL
    if p_First_NOAC_Lookup_Code= '803'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('CGM','ZLM','ZSM','ZSE','ZSL') AND
         p_First_Action_NOA_LA_Code2 in
       ('CGM','ZLM','ZSM','ZSE','ZSL') ) THEN
	  hr_utility.set_message(8301, 'GHR_37394_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--328.10.2
  --   11/9     12/14/99    vravikan   01-Nov-1999              Add UDM
  --           17-Aug-00   vravikan   From the Start            Add V7R
  --           17-Aug-00   vravikan   From the Start            Delete ZTS
  --           25-May-02   vnarasim   From the Start            Modified date,
  --                                                            added ZTS in else
  --                                                            part.
  -- UPD 56  8309414       Raju       From the Start            Add Z2U
if p_effective_date >= to_date('20'||'00/08/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '810'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UDM','UFM','VPG','VPH','VXK','V8K',
        'V8N','V8V','ZLM','V7R','Z2U','ZTZ','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UDM','UFM','VPG','VPH','VXK','V8K',
        'V8N','V8V','ZLM','V7R','Z2U','ZTZ','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37296_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
 else
    if p_First_NOAC_Lookup_Code= '810'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','VPG','VPH','VXK','V8K','V8N','V8V','ZLM','V7R','Z2U','ZTS','ZTZ','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','VPG','VPH','VXK','V8K','V8N','V8V','ZLM','V7R','Z2U','ZTS','ZTZ','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37395_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;

--329.05.2
    -- added ZPK on 23-jul-1998
  --   11/9     12/14/99    vravikan   01-Nov-1999              Add UDM
  --            17-Aug-00   vravikan   From the Start           Add V7R
  -- Dec 2001 Patch         vravikan   01-Oct-2001              Delete ZPK
  --  UPD 41(Bug 4567571)   Raju	   08-Nov-2005				Add VPO and VPT

if p_effective_date >= to_date('2001/10/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '815'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UAM','UDM','UFM','VPF','V7R','V8K','V8N','V8V','ZLM','ZVB','ZVC','VPO','VPT') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM','UDM','UFM','VPF','V7R','V8K','V8N','V8V','ZLM','ZVB','ZVC','VPO','VPT') ) THEN
	  hr_utility.set_message(8301, 'GHR_37920_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
elsif p_effective_date >= to_date('1999/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '815'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UAM','UDM','UFM','VPF','V7R','V8K','V8N','V8V','ZPK','ZLM','ZVB','ZVC','VPO','VPT') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM','UDM','UFM','VPF','V7R','V8K','V8N','V8V','ZPK','ZLM','ZVB','ZVC','VPO','VPT') ) THEN
	    hr_utility.set_message(8301, 'GHR_37297_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
    if p_First_NOAC_Lookup_Code= '815'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UAM','UFM','VPF','V7R','V8K','V8N','V8V','ZPK','ZLM','ZVB','ZVC','VPO','VPT') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM','UFM','VPF','V7R','V8K','V8N','V8V','ZPK','ZLM','ZVB','ZVC','VPO','VPT') ) THEN
	  hr_utility.set_message(8301, 'GHR_37396_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;
--329.07.2
  --   11/9     12/14/99    vravikan   01-Nov-1999              Add UDM
  --           17-Aug-00    vravikan   From the Start            Add V7R
  --  UPD 41(Bug 4567571)   Raju	   08-Nov-2005				Add VPO and VPW
if p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '816'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UAM','UDM','UFM','VPF','V7R','V8K','V8N','V8V','ZLM','ZTY','ZVB','ZVC','VPO','VPW') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM','UDM','UFM','VPF','V7R','V8K','V8N','V8V','ZLM','ZTY','ZVB','ZVC','VPO','VPW') ) THEN
        hr_utility.set_message(8301, 'GHR_37298_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
else
    if p_First_NOAC_Lookup_Code= '816'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UAM','UFM','VPF','V7R','V8K','V8N','V8V','ZLM','ZTY','ZVB','ZVC','VPO','VPW') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM','UFM','VPF','V7R','V8K','V8N','V8V','ZLM','ZTY','ZVB','ZVC','VPO','VPW') ) THEN
        hr_utility.set_message(8301, 'GHR_37397_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
end if;
--329.09.2
    if p_First_NOAC_Lookup_Code= '818'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('RMM','UFM','V8K','V8N','V8V','ZLM','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('RMM','UFM','V8K','V8N','V8V','ZLM','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37398_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
-- 329.18.2
-- 10-Nov-2005 Raju Created the edit
-- 14-Apr-2008 Raju added VPA,VPB, VPC
-- If Nature of Action is 827, the Legal Authority must be VPN, VPR, VPS, VPX, VPY, Z4G, Z4H
	if	p_First_NOAC_Lookup_Code= '827' and
		NOT ( p_First_Action_NOA_LA_Code1  in
		('VPA','VPB','VPC','VPN', 'VPR', 'VPS', 'VPX', 'VPY', 'Z4G', 'Z4H') AND
		p_First_Action_NOA_LA_Code2 in
		('VPA','VPB','VPC','VPN', 'VPR', 'VPS', 'VPX', 'VPY', 'Z4G', 'Z4H') ) THEN
		hr_utility.set_message(8301, 'GHR_38987_ALL_PROCEDURE_FAIL');
		hr_utility.raise_error;
	end if;

--329.30.2
-- Update Date    By       Effective Date       Comment
-- 05-NOV-03      ajose    From the begining    Added the Edit as a part of EOY03 changes
--upd47  26-Jun-06	Raju	   From 01-May-2006		             Terminate the edit
	if p_effective_date < fnd_date.canonical_to_date('2006/05/01') then
	   IF  p_First_NOAC_Lookup_Code= '849' AND
			NOT ( p_First_Action_NOA_LA_Code1  IN
		   ('V9N','V9P') AND
				  p_First_Action_NOA_LA_Code2  IN
		   ('V9N','V9P') ) THEN
			hr_utility.set_message(8301, 'GHR_38840_ALL_PROCEDURE_FAIL');
			hr_utility.raise_error;
	   END IF;
	end if;

--329.50.2
    if p_First_NOAC_Lookup_Code= '867'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('Q9K','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q9K','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37399_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--329.55.2
    if p_First_NOAC_Lookup_Code= '868'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('Q9M','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q9M','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37400_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;

--329.58.2
  --   11/9     12/14/99    vravikan   01-Nov-1999            New Edit
  --   If nature of action is 871, then legal authority must be UAM
if p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '871'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UAM') AND
         p_First_Action_NOA_LA_Code2 in
       ('UAM') ) THEN
	  hr_utility.set_message(8301, 'GHR_37407_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;
--Commented as per EOY 2003 cpdf changes by Ashley
--330.02.2
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
  --           17-Aug-00   vravikan   From the Start            Add V7R
 /*  if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '875'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','V3G','V4G','V7R','V8V','ZVB') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','V3G','V4G','V7R','V8V','ZVB') ) THEN
	  hr_utility.set_message(8301, 'GHR_37401_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
   end if;*/

--Commented as per EOY 2003 cpdf changes by Ashley
--330.05.2
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
  --           17-Aug-00   vravikan   From the Start            Add V7R
/*   if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '876'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','V3G','V4G','V7R','V8V','ZVB') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','V3G','V4G','V7R','V8V','ZVB') ) THEN
	  hr_utility.set_message(8301, 'GHR_37402_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
   end if;*/

--Commented as per EOY 2003 cpdf changes by Ashley
--330.08.2
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
  --           17-Aug-00   vravikan   From the Start            Add V7R
 /*  if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '877'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','VGL','V3F','V3G','V4G','V7R','V8V','ZVB') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','VGL','V3F','V3G','V4G','V7R','V8V','ZVB') ) THEN
	  hr_utility.set_message(8301, 'GHR_37403_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
   end if;
*/

--330.11.2
  --   11/3     12/14/99    vravikan   01-Nov-1999              Add UBM
  --	Upd 47  23-Jun-06	Raju		From Begining			Added V9N,V9P
if p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '878'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UBM','UFM','V8G','V7G','V9N','V9P','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UBM','UFM','V8G','V7G','V9N','V9P','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37408_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
    if p_First_NOAC_Lookup_Code= '878'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','V8G','V7G','V9N','V9P','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','V8G','V7G','V9N','V9P','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37404_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;

--330.12.2
  --   11/3     12/14/99    vravikan   01-Nov-1999              Add UBM
if p_effective_date >= to_date('19'||'99/11/01','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '879'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UBM','UFM','VWK','ZLM','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UBM','UFM','VWK','ZLM','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37409_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
else
    if p_First_NOAC_Lookup_Code= '879'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('UFM','VWK','ZLM','ZVB','ZVC') AND
         p_First_Action_NOA_LA_Code2 in
       ('UFM','VWK','ZLM','ZVB','ZVC') ) THEN
	  hr_utility.set_message(8301, 'GHR_37405_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
end if;
--Commented as per EOY 2003 cpdf changes by Ashley
--330.14.2
    -- added 'Z2W' on 12-oct-1998
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
  --           17-Aug-00   vravikan   From the Start            Add V7R
/*   if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
    if p_First_NOAC_Lookup_Code= '885'
       and
       NOT ( p_First_Action_NOA_LA_Code1  in
       ('Q4M','UAM','UFM','VGL','V4R','V7R','V8V',
        'Z2W','ZLM','ZSR','Z2M','ZVB') AND
         p_First_Action_NOA_LA_Code2 in
       ('Q4M','UAM','UFM','VGL','V4R','V7R','V8V',
        'Z2W','ZLM','ZSR','Z2M','ZVB') ) THEN
	  hr_utility.set_message(8301, 'GHR_37406_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
       end if;
   end if;
*/

end chk_Legal_Authority_a;

end GHR_CPDF_CHECK4A;

/
