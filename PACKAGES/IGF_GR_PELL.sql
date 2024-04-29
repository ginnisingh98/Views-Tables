--------------------------------------------------------
--  DDL for Package IGF_GR_PELL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_PELL" AUTHID CURRENT_USER AS
/* $Header: IGFGR01S.pls 120.0 2005/06/01 14:13:42 appldev noship $ */

--
-- History :
-- who                 when            what
------------------------------------------------------------------------
-- bkkumar            23-july-04      Bug 3773300 Added the function get_enrollment_date
-- ugummall           09-DEC-2003.    Bug 3252832. FA 131 - COD Updates.
--                                    Removed the procedure pell_calc.
-- sjalasut           7 Nov 03        Changed the variable name l_rep_pell_id to
--                                      l_attend_pell_id as part of FA126 Build.
-- rasahoo            27-Aug-2003     Changed the signature of procedure RFMS_LOAD.
--                                    Removed the parameter P_GET_RECENT_INFO
--                                    as part of obsoletion of FA base record history
-- Bug 2613546,2606001
-- sjadhav
-- FA 105 108 Build
-- added l_pell_mat spec variable
--
--
-- Bug : 2216956
-- sjadhav , Removed Run Type param
--
-- Bug ID  : 1818617
-- sjadhav             24-jul-2001     added parameter p_get_recent_info
--
-- Bug Id : 1867738
-- avenkatr           06-SEP-2001      Added the proceudre "Generate_Origination_Id" to take care of
--                                     cases when the student does not have the ISIR record or when either
--                                     of SSN, Start dt of Award Year or Reporting Pell Id is NULL
--                                     when generating the Origination Id
------------------------------------------------------------------------
--

-- Creation of RFMS records id done in this procedure

-- Parameters
-- l_run_type    -->  S ( run for single student ) / Y  ( run for a year )
-- l_award_year  -->  concatinated cal_type + sequence_number
-- l_base_id     -->  Student base ID


PROCEDURE Rfms_load( errbuf               OUT NOCOPY    VARCHAR,
                     retcode              OUT NOCOPY    NUMBER,
                     l_award_year         IN     VARCHAR2,
                     l_base_id            IN     igf_ap_fa_base_rec_all.base_id%TYPE,
                     p_org_id             IN     NUMBER );


PROCEDURE Generate_Origination_Id( l_base_id         IN  NUMBER,
                                   l_attend_pell_id     IN  VARCHAR2,
                                   l_origination_id  OUT NOCOPY VARCHAR2,
                                   l_error           OUT NOCOPY VARCHAR2);

FUNCTION get_enrollment_date(p_award_id igf_aw_award_all.award_id%TYPE)
RETURN DATE;
-- The calculation of Pell amount is done in this package
--
-- Pre-requisites
-- The following tables have to be populated before calling this process
-- igf_fa_base_rec
-- igf_aw_fund_mast
-- igf_gr_pell_setup
--
-- The pell calculation routine can only be called from the Packaging package
--


--
-- Bug 2460904
-- Re Calculate Pell Shcedule Ammount when this routine is
-- called from Origination form
--
-- Added parameters
-- 1. l_enrl_stat
-- 2. l_pell_coa
--

--
-- Bug 2613546,2606001
-- Added l_pell_mat parameter. This will denote
-- if regular or alternate pell matrix is used to
-- calculate pell award
--
--

END IGF_GR_PELL;

 

/
