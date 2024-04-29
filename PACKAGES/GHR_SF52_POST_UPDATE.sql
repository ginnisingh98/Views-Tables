--------------------------------------------------------
--  DDL for Package GHR_SF52_POST_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_POST_UPDATE" AUTHID CURRENT_USER AS
/* $Header: gh52poup.pkh 120.0.12010000.1 2008/07/28 10:21:09 appldev ship $ */

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Post_sf52_process>--------------------------|
-- ----------------------------------------------------------------------------


Procedure Post_sf52_process
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_object_version_number          in out NOCOPY number,
 p_from_position_id               in     number    default null,
 p_to_position_id                 in     number    default null,
 p_agency_code                    in     varchar2  default null,  -- to_agency_code
 p_sf52_data_result               in ghr_pa_requests%rowtype,
 p_called_from                    in varchar2 default null
 );

Procedure Post_sf52_cancel
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_object_version_number          in out NOCOPY number,
 p_from_position_id               in     number    default null,
 p_to_position_id                 in     number    default null,
 p_agency_code                    in     varchar2  default null  -- to_agency_code
 );

Procedure Post_sf52_future
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_object_version_number          in out NOCOPY number
);

--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_Notification_Details>--------------------------|
-- ----------------------------------------------------------------------------

Procedure get_notification_details
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_from_position_id               in     number    default null,
 p_to_position_id                 in     number    default null,
 p_agency_code                    in out NOCOPY varchar2,  -- to_agency_code
 p_from_agency_code               out NOCOPY  varchar2,
 p_from_agency_desc               out NOCOPY  varchar2,
 p_from_office_symbol             out NOCOPY  varchar2,
 p_personnel_office_id            out NOCOPY  number,
 p_employee_dept_or_agency        out NOCOPY  varchar2,
 p_to_office_symbol               out NOCOPY  varchar2
 );

end ghr_sf52_post_update;

/
