--------------------------------------------------------
--  DDL for Package PQH_FR_QUOTA_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_QUOTA_CHECK" AUTHID CURRENT_USER as
/* $Header: pqqutchk.pkh 120.0 2005/05/29 02:23 appldev noship $ */

Procedure quota_grid_formation(p_elctbl_chc_id in number,
                              p_effective_date in date);

procedure check_quota(p_business_group_id in number, p_return_status out nocopy varchar2);

procedure check_quota(p_business_group_id in number,
                     p_effective_date in date,
                     p_corp_id in number,
                     p_grade_id in number,
                     p_return_status out nocopy varchar2);

procedure delete_rows;

END PQH_FR_QUOTA_CHECK;

 

/
