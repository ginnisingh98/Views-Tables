--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK4A
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK4A" AUTHID CURRENT_USER as
/* $Header: ghcpdf4a.pkh 120.0.12010000.1 2008/07/28 10:26:13 appldev ship $ */

-- <Precedure Info>
-- Name:
--   Legal Authority
-- Sections in CPDF:
--   C24 - C36
-- Note:
--
--

procedure chk_Legal_Authority_a
  (p_To_Play_Plan              in varchar2
  ,p_Agency_Sub_Element        in varchar2
  ,p_First_Action_NOA_LA_Code1 in varchar2
  ,p_First_Action_NOA_LA_Code2 in varchar2
  ,p_First_NOAC_Lookup_Code    in varchar2
  ,p_effective_date            in date
  ,p_position_occupied_code    in varchar2
  );


end GHR_CPDF_CHECK4A;

/
