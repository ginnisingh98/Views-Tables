--------------------------------------------------------
--  DDL for Package GHR_SF52_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_BK3" AUTHID CURRENT_USER as
/* $Header: ghparapi.pkh 120.10.12010000.2 2009/02/27 12:12:19 vmididho ship $ */
--
--
-- end_sf52_b
--
Procedure end_sf52_b	(
      p_pa_request_id                   in      number  ,
      p_user_name                       in      varchar2,
      p_action_taken                    in      varchar2,
      p_altered_pa_request_id           in      number  ,
      p_first_noa_code                  in      varchar2,
      p_second_noa_code                 in      varchar2,
      p_par_object_version_number       in      number
	);
--
-- end_sf52_a
--
Procedure end_sf52_a	(
      p_pa_request_id                   in      number  ,
      p_user_name                       in      varchar2,
      p_action_taken                    in      varchar2,
      p_altered_pa_request_id           in      number  ,
      p_first_noa_code                  in      varchar2,
      p_second_noa_code                 in      varchar2,
      p_par_object_version_number       in      number
	);
--
end ghr_sf52_bk3;

/
