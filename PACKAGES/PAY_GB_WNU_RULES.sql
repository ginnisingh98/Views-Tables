--------------------------------------------------------
--  DDL for Package PAY_GB_WNU_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_WNU_RULES" AUTHID CURRENT_USER as
/* $Header: pygbwnu1.pkh 115.8 2003/12/18 00:26:58 asengar noship $ */
Procedure wnu_update
  (p_assignment_id                in    number,
   p_effective_date               in    date,
   p_assignment_number            in    varchar2 default null,
   p_assignment_number_old        in    varchar2 default null,
   p_not_included_in_wnu          in    varchar2 default null,
   p_object_version_number        in out NOCOPY  number,
   p_assignment_extra_info_id     out NOCOPY  number
  );

-- BUG 3294480 Added procedure
Procedure wnu_update
  (p_person_id                    in    number,
   p_effective_date               in    date,
   p_aggregated_assignment        in    varchar2 default null,
   p_ni_number_update             in    varchar2 default null,
   p_not_included_in_wnu          in    varchar2 default null,
   p_object_version_number        in out NOCOPY number,
   p_assignment_extra_info_id     out NOCOPY  number
  );

end;

 

/
