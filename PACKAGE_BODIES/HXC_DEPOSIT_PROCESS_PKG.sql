--------------------------------------------------------
--  DDL for Package Body HXC_DEPOSIT_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DEPOSIT_PROCESS_PKG" as
/* $Header: hxcdeppr.pkb 120.3 2006/03/02 20:57:00 mbhammar noship $ */

g_package  varchar2(33) := '  hxc_deposit_process_pkg.';

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
--   p_object_version_number     - ovn of time building block
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
--   p_resource_type             - person, machine, room, etc...
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
  ) is

l_time_building_block_id   number;
l_object_version_number    number;
l_time_attribute_id        number;
l_tbb_ovn                  number;
l_tat_ovn                  number;
l_time_building_block_id_o number;

l_process_id	hxc_deposit_processes.deposit_process_id%TYPE;

e_process_not_registered exception;
e_ovn_not_latest exception;

begin

  -- get the deposit process id

  -- check that we are using a valid deposit process
  l_process_id := deposit_process_registered
           (p_source_name  => p_source_name
           ,p_process_name => p_process_name
           );
   IF ( l_process_id IS NULL )
   then
    raise e_process_not_registered;
  end if;

 if p_object_version_number is null then

      -- store the time_card_building_block_id that was passed in
      l_time_building_block_id_o := p_time_building_block_id;

      savepoint pre_create;

      -- first, create a building block in HXC_TIME_BUILDING_BLOCKS
      hxc_building_block_api.create_building_block
        (p_effective_date            => p_effective_date
        ,p_type                      => p_type
        ,p_measure                   => p_measure
        ,p_unit_of_measure           => p_unit_of_measure
        ,p_start_time                => p_start_time
        ,p_stop_time                 => p_stop_time
        ,p_parent_building_block_id  => p_parent_building_block_id
        ,p_parent_building_block_ovn => p_parent_building_block_ovn
        ,p_scope                     => p_scope
        ,p_approval_style_id         => p_approval_style_id
        ,p_approval_status           => p_approval_status
        ,p_resource_id               => p_resource_id
        ,p_resource_type             => p_resource_type
        ,p_comment_text              => p_comment_text
        ,p_application_set_id        => p_application_set_id
        ,p_translation_display_key   => null
        ,p_time_building_block_id    => p_time_building_block_id
        ,p_object_version_number     => p_object_version_number
        );

      l_time_building_block_id := p_time_building_block_id;
      l_object_version_number  := p_object_version_number;

          -- second, insert attribute data into HXC_TIME_ATTRIBUTES
	  -- if there are any attributes to insert

	IF ( p_timecard.count <> 0 )
	THEN

      hxc_time_attributes_api.create_attributes
        (p_timecard               => p_timecard
        ,p_process_id             => l_process_id
        ,p_time_building_block_id => nvl(l_time_building_block_id_o
        				    ,l_time_building_block_id)
        ,p_tbb_ovn                => l_object_version_number --l_tbb_ovn
        ,p_time_attribute_id      => l_time_attribute_id
        ,p_object_version_number  => l_tat_ovn
        );

	END IF;

      -- set out parameter
      p_time_building_block_id := l_time_building_block_id;
      p_object_version_number  := l_object_version_number;

 else -- if p_object_version_number is not null then
      -- check that if object_version_number is not null then it is the latest
      -- time building block that is being updated
    if not latest_ovn
          (p_time_building_block_id => p_time_building_block_id
          ,p_object_version_number  => p_object_version_number
           ) then
     raise e_ovn_not_latest;
    else
      -- store the time_card_building_block_id that was passed in
      l_time_building_block_id_o := p_time_building_block_id;

      savepoint pre_create;

      -- first, create a building block in HXC_TIME_BUILDING_BLOCKS
      hxc_building_block_api.create_building_block
        (p_effective_date            => p_effective_date
        ,p_type                      => p_type
        ,p_measure                   => p_measure
        ,p_unit_of_measure           => p_unit_of_measure
        ,p_start_time                => p_start_time
        ,p_stop_time                 => p_stop_time
        ,p_parent_building_block_id  => p_parent_building_block_id
        ,p_parent_building_block_ovn => p_parent_building_block_ovn
        ,p_scope                     => p_scope
        ,p_approval_style_id         => p_approval_style_id
        ,p_approval_status           => p_approval_status
        ,p_resource_id               => p_resource_id
        ,p_resource_type             => p_resource_type
        ,p_comment_text              => p_comment_text
        ,p_application_set_id        => p_application_set_id
        ,p_translation_display_key   => null
        ,p_time_building_block_id    => p_time_building_block_id
        ,p_object_version_number     => p_object_version_number
        );

      l_time_building_block_id := p_time_building_block_id;
      l_object_version_number  := p_object_version_number;

          -- second, insert attribute data into HXC_TIME_ATTRIBUTES
      hxc_time_attributes_api.create_attributes
        (p_timecard               => p_timecard
        ,p_process_id             => l_process_id
        ,p_time_building_block_id => nvl(l_time_building_block_id_o
                                            ,l_time_building_block_id)
        ,p_tbb_ovn                => l_object_version_number --l_tbb_ovn
        ,p_time_attribute_id      => l_time_attribute_id
        ,p_object_version_number  => l_tat_ovn
        );

      -- set out parameter
      p_time_building_block_id := l_time_building_block_id;
      p_object_version_number  := l_object_version_number;
    end if;
 end if;

exception
  when e_process_not_registered then
    fnd_message.set_name('HXC', 'HXC_DEP_PROCESS_NOT_REGISTERED');
    fnd_message.raise_error;

   when e_ovn_not_latest then
     fnd_message.set_name('HXC','HXC_TIME_BLD_BLK_NOT_LATEST');
     fnd_message.raise_error;

  when others then
    rollback to pre_create;
    raise;

end execute_deposit_process;


-- function
--   deposit_process_registered
--
-- description
--   returns deposit process id depending on
--   whether or not a deposit process is registered in the time
--   store for a given time source name and deposit name
--
-- parameters
--   p_source_name            - the id of the time source
--   p_process_name           - the id of the deposit process

FUNCTION deposit_process_registered
  (p_source_name    in varchar2
  ,p_process_name   in varchar2
  ) RETURN number is

CURSOR csr_get_time_source_id IS
SELECT	ts.time_source_id
FROM	hxc_time_sources ts
WHERE 	name = p_source_name;

l_time_source_id     hxc_time_sources.time_source_id%TYPE := NULL;

cursor c_process is
  select deposit_process_id
  from hxc_deposit_processes
  where time_source_id	= l_time_source_id
  and   name 		= p_process_name;

l_deposit_process_id hxc_deposit_processes.deposit_process_id%TYPE := NULL;

begin

OPEN  csr_get_time_source_id;
FETCH csr_get_time_source_id INTO l_time_source_id;
CLOSE csr_get_time_source_id;

  open c_process;
  fetch c_process into l_deposit_process_id;
  close c_process;

RETURN l_deposit_process_id;

end deposit_process_registered;



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
  ) return boolean is

-- You can only have one object version number of a block with date to of hr_general.end_of_time
cursor c_latest_ovn is
 select null
 from  hxc_time_building_blocks tbb
 where tbb.time_building_block_id = p_time_building_block_id
 and tbb.object_version_number = p_object_version_number
 and tbb.date_to = hr_general.end_of_time;
/*cursor c_latest_ovn is
 select null
 from  hxc_time_building_blocks tbb
 where tbb.time_building_block_id = p_time_building_block_id
 and p_object_version_number = (select max(object_version_number) from hxc_time_building_blocks where time_building_block_id = tbb.time_building_block_id)
 and tbb.date_to = to_date('31/12/4712','DD/MM/YYYY');
*/
/*cursor c_latest_ovn is
  select null
  from  hxc_time_building_blocks tbb
  where tbb.time_building_block_id        = p_time_building_block_id
  and  ((select max(object_version_number)
         from hxc_time_building_blocks
         where time_building_block_id = tbb.time_building_block_id)
                                          = p_object_version_number)
  and   tbb.date_to                       = to_date('31/12/4712','DD/MM/YYYY');
*/

l_null varchar2(1);

begin

  open c_latest_ovn;
  fetch c_latest_ovn into l_null;
  if c_latest_ovn%found then
    close c_latest_ovn;
    return true;
  else
    close c_latest_ovn;
    return false;
  end if;

end latest_ovn;

end hxc_deposit_process_pkg;

/
