--------------------------------------------------------
--  DDL for Package GHR_MASS_CHANGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MASS_CHANGES" AUTHID CURRENT_USER AS
/* $Header: ghmass52.pkh 120.0.12010000.1 2008/07/28 10:32:41 appldev ship $ */

Procedure create_sf52_for_mass_changes
(p_mass_action_type  in      varchar2,
 p_pa_request_rec    in out  NOCOPY ghr_pa_requests%rowtype,
 p_errbuf            out     NOCOPY varchar2, --\___  error log
 p_retcode           out     NOCOPY number    --/     in conc. manager.
);

Procedure create_remarks
(p_pa_request_rec        in   ghr_pa_requests%rowtype,
 p_remark_code 	       in   ghr_remarks.code%type
);

end ghr_mass_changes;

/
