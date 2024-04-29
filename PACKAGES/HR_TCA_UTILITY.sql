--------------------------------------------------------
--  DDL for Package HR_TCA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCA_UTILITY" AUTHID CURRENT_USER as
/* $Header: petcautl.pkh 115.2 2004/06/21 16:02:00 tpapired noship $ */

  -- ----------------------------------------------------------------------------
  -- |----------------------------< get_person_id >-------------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   This procedure returns the person id for a given party id. If multiple
  --   persons match to the given party_id, then PERSON ID is returned in the
  --   following order of preference
  --   EMPLOYEE  -  CONTINGENT WORKER  -  APPLICANT - OTHERS
  --
  --   This procedure also returns the value for p_matches depending on number
  --   of matches exist for the given party_id.
  --
  --   If NO person matches to the party,       p_matches is set to 'N'
  --   If ONE person matches to the party,      p_matches is set to 'Y'
  --   If MULITIPLE persons match to the party, p_matches is set to 'W'
  --
  -- Prerequisites:
  --   A valid record should be existing in per_all_people_f table for the
  --   given party id and effective date
  --
  -- In Parameters:
  --   Name              Reqd   Type     Description
  --   p_party_id        Yes    Number   Identifies the party
  --   p_effective_date  No     Date     Effective date
  --
  -- This procedure sets the following Out Parameters:
  --
  --   p_person_id       Yes    Number   If a match exists for the party, then set to the
  --                                     Person record identified by the party.
  --   p_matches         Yes    varchar  If only one person record matches to the party, then set to 'Y'
  --                                     if more than one person record matches, then set to 'W'
  --                                     and if no person record matches, then set to 'N'
  --
  -- Post Success:
  --   A valid Person id is returned if there is a match exists. p_matches
  --   returns one of the following values based on number of matches
  --   found for the party_id.
  --    'Y' - one match
  --    'N' - no matches
  --    'W' - multiple matches
  --
  --
  -- Post Failure:
  --   No person id is returned (Null person_id)
  --   p_matches is set to 'N'
  --
  -- Access Status:
  --   Internal development use only.
  --
  -- {End Of Comments}
  --
  -- ---------------------------------------------------------------------------
  PROCEDURE get_person_id
    (p_party_id       in  number
    ,p_effective_date in  date default sysdate
    ,p_person_id      out nocopy number
    ,p_matches        out nocopy varchar
    ) ;
end hr_tca_utility;
--

 

/
