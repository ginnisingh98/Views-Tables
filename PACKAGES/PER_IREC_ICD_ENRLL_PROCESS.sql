--------------------------------------------------------
--  DDL for Package PER_IREC_ICD_ENRLL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IREC_ICD_ENRLL_PROCESS" AUTHID CURRENT_USER as
/* $Header: periricd.pkh 120.3.12000000.1 2007/07/25 11:08:45 gaukumar noship $ */


--
--
-- ----------------------------------------------------------------------------
--  populate_Pay_Elements
--     called from concurrent process to populate Pay Elements :
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_Pay_Elements
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pBgId      in         number
             , pVacancyid in         number   default null
             , pPersonId  in         number   default null);
--

--
--
-- ----------------------------------------------------------------------------
--  populate_for_bg
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_for_bg
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pBgId      in         number);
--

--
--
-- ----------------------------------------------------------------------------
--  populate_for_vacancy
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_for_vacancy
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pVacancyId      in         number);
--

--
--
-- ----------------------------------------------------------------------------
--  populate_Pay_Elements_for_vacancy
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_for_person
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pPersonId in         number);
--

--
--
-- ----------------------------------------------------------------------------
--  is_offer_accepted_or_extended
--
--
-- ----------------------------------------------------------------------------
--
function is_offer_accepted_or_extended
            (  pPersonId     in     number
             , pAssignmentId in     number) RETURN boolean;

--
--
-- ----------------------------------------------------------------------------
--  run_enrollment
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE run_enrollment
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pPersonId     in     number
             , pAssignmentId in     number
             , pPerInLerId   in     number
             , pBgId         in     number);

END PER_IREC_ICD_ENRLL_PROCESS;

 

/
