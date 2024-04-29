--------------------------------------------------------
--  DDL for Package HXC_DEPOSIT_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DEPOSIT_PROCESS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcdeppr.pkh 115.10 2003/03/12 12:52:08 ksethi ship $ */

-- procedure
--   execute_deposit_process
--
-- description
--   main wrapper process for depositing time information into the time
--   store.  accepts a 'timecard' in the form of a pl/sql record structure,
--   along with all associated header information, and splits the data into
--   suitable components prior to insertion into the following storage tables:
--
--     HXC_TIME_BUILDING_BLOCKS
--     HXC_TIME_ATTRIBUTES
--     HXC_TIME_ATTRIBUTE_USAGES
--
-- parameters
--   p_time_building_block_id    - time building block id
--   p_process_name              - deposit process name
--   p_source_name               - time source name
--   p_effective_date            - effective date of deposit
--   p_type                      - building block type, (R)ange or (D)uration
--   p_measure                   - magnitude of time unit
--   p_unit_of_measure           - time unit
--   p_start_time                - time in
--   p_stop_time                 - time out
--   p_parent_building_block_id  - id of parent building block
--   p_parent_building_block_ovn - ovn of parent building block
--   p_scope                     - scope of building block
--   p_approval_style_id         - approval style id
--   p_approval_status           - approval status code
--   p_resource_id               - resource id (fk dependent on p_resource_type)
--   p_resource_type             - (P)erson, (M)achine, (R)oom
--   p_comment_text              - comment text
--   p_application_set_id        - Application Set Id
--   p_timecard                  - time attributes in pl/sql table structure

procedure execute_deposit_process
  (p_time_building_block_id    in out nocopy number
  ,p_object_version_number     in out nocopy number
  ,p_process_name              in     varchar2
  ,p_source_name               in     varchar2
  ,p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_measure                   in     number
  ,p_unit_of_measure           in     varchar2
  ,p_start_time                in     date
  ,p_stop_time                 in     date
  ,p_parent_building_block_id  in     number
  ,p_parent_building_block_ovn in     number
  ,p_scope                     in     varchar2
  ,p_approval_style_id         in     number
  ,p_approval_status           in     varchar2
  ,p_resource_id               in     number
  ,p_resource_type             in     varchar2
  ,p_comment_text              in     varchar2
  ,p_application_set_id        in     number default null
  ,p_timecard                  in     hxc_time_attributes_api.timecard
  );

-- function
--   deposit_process_registered
--
-- description
--   returns true or false depending on whether or not a deposit process
--   is registered in the time store for a given time source
--
-- parameters
--   p_source_name            - the name of the time source
--   p_process_name           - the name of the deposit process

FUNCTION deposit_process_registered
  (p_source_name    in varchar2
  ,p_process_name   in varchar2
  ) RETURN number;

-- function
--   latest_ovn
--
-- description
--   returns true or false depending on whether or not the object version number
--   passed to the deposit api is the latest one.
--
-- parameters
--   p_time_building_block_id - the id of the time building block
--   p_object_version_number  - ovn of the time building block

function latest_ovn
  (p_time_building_block_id    in number
  ,p_object_version_number     in number
  ) return boolean;


end hxc_deposit_process_pkg;

 

/
