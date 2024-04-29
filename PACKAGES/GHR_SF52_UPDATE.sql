--------------------------------------------------------
--  DDL for Package GHR_SF52_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_UPDATE" AUTHID CURRENT_USER AS
/* $Header: ghsf52up.pkh 120.0.12010000.1 2008/07/28 10:39:52 appldev ship $ */
--
PROCEDURE MAIN
(p_pa_request_rec       in  out NOCOPY  ghr_pa_requests%rowtype,
 p_pa_request_ei_rec    in     ghr_pa_request_extra_info%rowtype,
 p_generic_ei_rec       in     ghr_pa_request_extra_info%rowtype,
 p_capped_other_pay     in     NUMBER default null
);
end GHR_SF52_UPDATE;

/
