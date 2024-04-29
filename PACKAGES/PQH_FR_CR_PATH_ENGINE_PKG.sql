--------------------------------------------------------
--  DDL for Package PQH_FR_CR_PATH_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_CR_PATH_ENGINE_PKG" AUTHID CURRENT_USER AS
/* $Header: pqcrpeng.pkh 120.0 2005/05/29 01:46 appldev noship $ */

Procedure get_elctbl_chc_career_path (p_per_in_ler_id in number,
                                     p_effective_date in date,
                                     P_Elig_Per_Elctbl_Chc_Id out nocopy number,
                                     p_return_code out nocopy varchar2,
                                     p_return_status out nocopy varchar2);

END PQH_FR_CR_PATH_ENGINE_PKG;

 

/
