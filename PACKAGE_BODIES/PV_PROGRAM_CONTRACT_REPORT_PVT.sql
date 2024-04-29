--------------------------------------------------------
--  DDL for Package Body PV_PROGRAM_CONTRACT_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PROGRAM_CONTRACT_REPORT_PVT" as
/* $Header: pvxtpcrb.pls 115.1 2002/12/25 01:01:26 ktsao ship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PROGRAM_CONTRACT_REPORT_PVT
-- Purpose
--
-- History
--         02-AUG-2002    Karen.Tsao      Created
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================

--
--  PROCEDURE/Function
-- private function data_required_msg
-- called from prerun validation
--
--  PURPOSE
--
-- returns translated message OKC_DATA_REQUIRED
-- Data required for some operation
-- DATA_NAME data required for OPERATION
--
-- translatable token DATA_NAME
--   OKC_SECTIONS Sections
--   OKC_RULE_GROUPS Rule Groups
-- translatable token OPERATION
--   OKC_PRINT_CONTRACT Contract Printing
--
function data_required_msg(p_data_name varchar2) return varchar2 is
begin
  fnd_message.clear;
  FND_MESSAGE.SET_NAME(application => 'PV',
                       name        => 'PV_DATA_REQUIRED');
  FND_MESSAGE.SET_TOKEN(token      => 'DATA_NAME',
                        value      => p_data_name,
                        translate  => TRUE);
  FND_MESSAGE.SET_TOKEN(token      => 'OPERATION',
                        value      => 'PV_VIEW_CONTRACT',
                        translate  => TRUE);
  return fnd_message.get;
end;

--
--  PROCEDURE/Function
--    prerun
--
--  PURPOSE
--
--    sample procedure, its name could be used
--    to set profile option OKC_WEB_PRERUN
--    performs sample validation tasks:
--    checks if lines and sections are present in the contract
--
--    what is import - signature
--
  procedure prerun(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version in NUMBER default NULL,
	p_scn_id in NUMBER default NULL
  ) is
  l_dummy varchar2(1);
--
-- sections required
--
  cursor sections_csr(p_chr number) is
    select '!'
    from okc_sections_v
    where CHR_ID = p_chr
  ;

    begin
    l_dummy := '?';
    open sections_csr(p_chr_id);
    fetch sections_csr into l_dummy;
    close sections_csr;
    if (l_dummy = '?') then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := data_required_msg('Sections');
      return;
    end if;
    x_return_status := 'S';
  end;


END PV_PROGRAM_CONTRACT_REPORT_PVT;

/
