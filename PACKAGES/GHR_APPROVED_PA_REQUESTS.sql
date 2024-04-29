--------------------------------------------------------
--  DDL for Package GHR_APPROVED_PA_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_APPROVED_PA_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: ghparapr.pkh 120.0.12010000.4 2009/02/01 10:49:41 vmididho ship $ */
--
--
--
--
-- ------------------------------------------------
   function ghr_correct_sf52 (
-- ------------------------------------------------
     p_pa_request_id              in     number
   , p_par_object_version_number  IN     number
   , p_noa_id                     in     number
   , p_which_noa                  in     number
   , p_row_id                     in     varchar
   , p_username                   in     varchar)
  return number;
--
-- ------------------------------------------------
   function ghr_cancel_sf52 (
-- ------------------------------------------------
     p_pa_request_id              in     number
   , p_par_object_version_number  IN OUT NOCOPY number
   , p_noa_id                     in     number
   , p_which_noa                  in     number
   , p_row_id                     in     varchar2
   , p_username                   in     varchar2
   , p_which_action               in     varchar2 default 'SUBSEQUENT'
   , p_cancel_legal_authority     in     varchar2)
  return number;
--
-- ------------------------------------------------
   function ghr_reroute_sf52 (
-- ------------------------------------------------
  P_PA_REQUEST_ID              IN     NUMBER
 ,p_par_object_version_number  IN OUT NOCOPY number
 ,P_ROUTING_GROUP_ID           IN     NUMBER
 ,P_USER_NAME                  IN     VARCHAR2
)
return boolean;

-- ---------------------------------
   PROCEDURE find_last_request(
-- ---------------------------------
  p_pa_request_id              in     number
, p_which_noa                  in     number
, p_row_id                     in     varchar
, p_first_pa_request_rec       IN OUT NOCOPY GHR_PA_REQUESTS%ROWTYPE
, p_last_pa_request_rec        IN OUT NOCOPY GHR_PA_REQUESTS%ROWTYPE
, p_number_of_requests         IN OUT NOCOPY number
);

-- ---------------------------------
   PROCEDURE can_cancel_or_correct(
-- ---------------------------------
  p_pa_request_id              in     number
, p_which_noa                  in     number
, p_row_id                     in     varchar
, p_total_actions              IN OUT NOCOPY number
, p_corrections                IN OUT NOCOPY number
, p_rpas                       IN OUT NOCOPY number
);
-- BUG # 7216635 added the new parameter p_noa_id_correct
-- ------------------------------------------------
FUNCTION chk_intervene_seq (
-- ------------------------------------------------
     p_pa_request_id              in     number
   , p_pa_notification_id         in     number
   , p_person_id                  in     number
   , p_effective_date             in     date
   , p_noa_id_correct             in     number)
  return NUMBER;
-- BUG # 7216635 added the new parameter p_noa_id_correct
-- ------------------------------------------------
PROCEDURE determine_ia (
-- ------------------------------------------------
     p_pa_request_id              in number
   , p_pa_notification_id         in     number
   , p_person_id                  in     number
   , p_effective_date             in     date
   , p_noa_id_correct             in     number
   , p_retro_pa_request_id        out nocopy number
   , p_retro_eff_date             out nocopy date
   , p_retro_first_noa            out nocopy varchar2
   , p_retro_second_noa           out nocopy varchar2
  ) ;

--
--6850492
procedure Update_Dual_Id(p_parent_pa_request_id in number,
                         p_first_dual_action_id in number,
			 p_second_dual_action_id in number);

--6850492

end GHR_APPROVED_PA_REQUESTS ;

/
