--------------------------------------------------------
--  DDL for Package GHR_SF52_VALIDN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_VALIDN_PKG" AUTHID CURRENT_USER AS
/* $Header: ghvalidn.pkh 115.2 2004/02/10 05:39:52 aandhava ship $ */


--  ---------------------------------------------------------------------------
-- |-----------------------------< prelim_req_chk_for_update_hr >---------------------------|
--  ---------------------------------------------------------------------------
--

--
 Procedure prelim_req_chk_for_update_hr
 (p_pa_request_rec             in      ghr_pa_requests%rowtype
 );

--
--
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the various codes that were not
--   validated at the row handler level
--
-- Pre Conditions:
--
-- In Parameter:
--
--   p_rec                ghr_pa_requests%rowtype;
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
--  Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}


procedure perform_validn
(p_rec               in        ghr_pa_requests%ROWTYPE
);
end ghr_sf52_validn_pkg;


 

/
