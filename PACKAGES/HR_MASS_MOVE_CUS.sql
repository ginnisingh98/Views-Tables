--------------------------------------------------------
--  DDL for Package HR_MASS_MOVE_CUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MASS_MOVE_CUS" AUTHID CURRENT_USER as
/* $Header: pemmvcus.pkh 115.1 99/07/18 14:02:49 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< pre_move_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- The pre-core move employee assignment procedure is delivered as an 'empty'
-- packaged procedure which the customer can customize by coding any additional
-- validation which they may require at assignment level before an employee
-- assignment is moved.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                    Reqd Type     Description
--   p_effective_date        Yes  date     Date the assignment is being moved
--   p_assignment_id	     Yes  number   The Assignment that is being moved
--   p_object_version_number Yes  number   The object version number of the
--			                   assignment which is to be moved.
--   p_mass_move_id	     No   number   If the Assignment is being moved as
--				      	   part of a mass move, this is the
--				           particular mass move by which it is
--				           being moved.
--   p_position_id           No   number   Position to which the assignment is
--				           being moved.
--   p_organization_id	     No   number   Organization to which the
--                                         assignment is being moved.
--   p_location_id	     No   number   Location to which the assignment is
--				           being moved.
--   p_frequency	     No   varchar2 New Frequency of Normal Working
--				           Hours for the Asg.
--   p_normal_hours	     No   number   New Normal Working Hours for the asg
--   p_time_normal_finish    No   varchar2 New Normal finish time for the asg.
--   p_time_normal_start     No   varchar2 New Normal start time for the asg.
--   p_segment1              No   varchar2 Soft Coding Keyflex.
--   p_segment2              No   varchar2 Soft Coding Keyflex.
--   p_segment3              No   varchar2 Soft Coding Keyflex.
--   p_segment4              No   varchar2 Soft Coding Keyflex.
--   p_segment5              No   varchar2 Soft Coding Keyflex.
--   p_segment6              No   varchar2 Soft Coding Keyflex.
--   p_segment7              No   varchar2 Soft Coding Keyflex.
--   p_segment8              No   varchar2 Soft Coding Keyflex.
--   p_segment9              No   varchar2 Soft Coding Keyflex.
--   p_segment10             No   varchar2 Soft Coding Keyflex.
--   p_segment11             No   varchar2 Soft Coding Keyflex.
--   p_segment12             No   varchar2 Soft Coding Keyflex.
--   p_segment13             No   varchar2 Soft Coding Keyflex.
--   p_segment14             No   varchar2 Soft Coding Keyflex.
--   p_segment15             No   varchar2 Soft Coding Keyflex.
--   p_segment16             No   varchar2 Soft Coding Keyflex.
--   p_segment17             No   varchar2 Soft Coding Keyflex.
--   p_segment18             No   varchar2 Soft Coding Keyflex.
--   p_segment19             No   varchar2 Soft Coding Keyflex.
--   p_segment20             No   varchar2 Soft Coding Keyflex.
--   p_segment21             No   varchar2 Soft Coding Keyflex.
--   p_segment22             No   varchar2 Soft Coding Keyflex.
--   p_segment23             No   varchar2 Soft Coding Keyflex.
--   p_segment24             No   varchar2 Soft Coding Keyflex.
--   p_segment25             No   varchar2 Soft Coding Keyflex.
--   p_segment26             No   varchar2 Soft Coding Keyflex.
--   p_segment27             No   varchar2 Soft Coding Keyflex.
--   p_segment28             No   varchar2 Soft Coding Keyflex.
--   p_segment29             No   varchar2 Soft Coding Keyflex.
--   p_segment30             No   varchar2 Soft Coding Keyflex.
--
-- Post Success:
--   The pre-move assignemnt validation has been successful, ie. the assignment
--   has been validated for moving, and processing by the core move_emp_asg
--   proceeds.
--
-- Post Failure:
--   The assignment has not been successful validated for moving and an
--    error is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure pre_move_emp_asg
  (p_effective_date        in  		date
  ,p_assignment_id	   in  		number
  ,p_object_version_number in    	number
  ,p_mass_move_id	   in  		number   default hr_api.g_number
  ,p_position_id           in  		number   default hr_api.g_number
  ,p_organization_id	   in  		number   default hr_api.g_number
  ,p_location_id	   in  		number   default hr_api.g_number
  ,p_frequency	           in  		varchar2 default hr_api.g_varchar2
  ,p_normal_hours	   in  		number   default hr_api.g_number
  ,p_time_normal_finish    in  		varchar2 default hr_api.g_varchar2
  ,p_time_normal_start     in  		varchar2 default hr_api.g_varchar2
  ,p_segment1              in  		varchar2 default hr_api.g_varchar2
  ,p_segment2              in  		varchar2 default hr_api.g_varchar2
  ,p_segment3              in  		varchar2 default hr_api.g_varchar2
  ,p_segment4              in  		varchar2 default hr_api.g_varchar2
  ,p_segment5              in  		varchar2 default hr_api.g_varchar2
  ,p_segment6              in  		varchar2 default hr_api.g_varchar2
  ,p_segment7              in  		varchar2 default hr_api.g_varchar2
  ,p_segment8              in  		varchar2 default hr_api.g_varchar2
  ,p_segment9              in  		varchar2 default hr_api.g_varchar2
  ,p_segment10             in  		varchar2 default hr_api.g_varchar2
  ,p_segment11             in  		varchar2 default hr_api.g_varchar2
  ,p_segment12             in  		varchar2 default hr_api.g_varchar2
  ,p_segment13             in  		varchar2 default hr_api.g_varchar2
  ,p_segment14             in  		varchar2 default hr_api.g_varchar2
  ,p_segment15             in  		varchar2 default hr_api.g_varchar2
  ,p_segment16             in  		varchar2 default hr_api.g_varchar2
  ,p_segment17             in  		varchar2 default hr_api.g_varchar2
  ,p_segment18             in  		varchar2 default hr_api.g_varchar2
  ,p_segment19             in  		varchar2 default hr_api.g_varchar2
  ,p_segment20             in  		varchar2 default hr_api.g_varchar2
  ,p_segment21             in  		varchar2 default hr_api.g_varchar2
  ,p_segment22             in  		varchar2 default hr_api.g_varchar2
  ,p_segment23             in  		varchar2 default hr_api.g_varchar2
  ,p_segment24             in  		varchar2 default hr_api.g_varchar2
  ,p_segment25             in  		varchar2 default hr_api.g_varchar2
  ,p_segment26             in  		varchar2 default hr_api.g_varchar2
  ,p_segment27             in  		varchar2 default hr_api.g_varchar2
  ,p_segment28             in  		varchar2 default hr_api.g_varchar2
  ,p_segment29             in  		varchar2 default hr_api.g_varchar2
  ,p_segment30             in  		varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< post_move_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- The post-core move employee assignment procedure is delivered as an 'empty'
-- packaged procedure which the customer can customize by coding any additional
-- DML which they may require at assignment level before an employee
-- assignment is moved.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                     	  Reqd Type     Description
--   p_validate               	  Yes  boolean  If true, the database
--                                              remains unchanged. If false,
--                                              the assignment is updated.
--   p_old_asg_eff_start_date     Yes  date     This is the effective start date
--                                              of the 'old' assignment row, ie.
--                                              the latest row which existed
--                                              for the assignment prior to
--                                              the move and whose effective end
--                                              date is now the day before the
--                                              move date.
--   p_new_asg_eff_start_date     Yes  date     This is the effective start date
--                                              of the 'new' assignment row, ie.
--                                              the row whose effective start
--                                              date is equal to the move date.
--   p_assignment_id              Yes  number   The assignment which was moved.
--   p_old_asg_object_version_num Yes  number   The object version number of
--                                              the 'old' assignment row.
--   p_new_asg_object_version_num Yes  number   The object version number of
--                                              the 'new' assignment row.
--
-- Post Success:
--   When the post-move assignment DML is successful, the following out
--   parameters are set :
--   Name                     	  Type     Description
--   p_old_asg_object_version_num number
--   p_new_asg_object_version_num number
--
--
-- Post Failure:
--   The API does not update the Assignment and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
procedure post_move_emp_asg
  (p_validate		   	in	boolean  default false
  ,p_old_asg_eff_start_date 	in out  date
  ,p_new_asg_eff_start_date 	in out  date
  ,p_assignment_id	   	in  	number
  ,p_old_asg_object_version_num in out  number
  ,p_new_asg_object_version_num in out  number
  ,p_mass_move_id	   	in   	number   default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< pre_move_position >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- The pre-core move position procedure is delivered as an 'empty'
-- packaged procedure which the customer can customize by coding any additional
-- validation which they may require at position level before position is
-- moved.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                    Reqd Type     Description
--   p_position_id	     Yes  number   The position which is to be moved.
--   p_object_version_number Yes  number   The object version number of the
--                                         position which is to be moved.
--   p_date_effective        Yes  date     The start date of the new position
--					   position which is to be created.
--   p_organization_id       Yes  number   The Organization to which the
--                                         position is to be moved, ie. the
--                                         Organization for which the new
--                                         position is to be created.
--   p_segment1              No   varchar2 Key flex for position definition.
--   p_segment2              No   varchar2 Key flex for position definition.
--   p_segment3              No   varchar2 Key flex for position definition.
--   p_segment4              No   varchar2 Key flex for position definition.
--   p_segment5              No   varchar2 Key flex for position definition.
--   p_segment6              No   varchar2 Key flex for position definition.
--   p_segment7              No   varchar2 Key flex for position definition.
--   p_segment8              No   varchar2 Key flex for position definition.
--   p_segment9              No   varchar2 Key flex for position definition.
--   p_segment10             No   varchar2 Key flex for position definition.
--   p_segment11             No   varchar2 Key flex for position definition.
--   p_segment12             No   varchar2 Key flex for position definition.
--   p_segment13             No   varchar2 Key flex for position definition.
--   p_segment14             No   varchar2 Key flex for position definition.
--   p_segment15             No   varchar2 Key flex for position definition.
--   p_segment16             No   varchar2 Key flex for position definition.
--   p_segment17             No   varchar2 Key flex for position definition.
--   p_segment18             No   varchar2 Key flex for position definition.
--   p_segment19             No   varchar2 Key flex for position definition.
--   p_segment20             No   varchar2 Key flex for position definition.
--   p_segment21             No   varchar2 Key flex for position definition.
--   p_segment22             No   varchar2 Key flex for position definition.
--   p_segment23             No   varchar2 Key flex for position definition.
--   p_segment24             No   varchar2 Key flex for position definition.
--   p_segment25             No   varchar2 Key flex for position definition.
--   p_segment26             No   varchar2 Key flex for position definition.
--   p_segment27             No   varchar2 Key flex for position definition.
--   p_segment28             No   varchar2 Key flex for position definition.
--   p_segment29             No   varchar2 Key flex for position definition.
--   p_segment30             No   varchar2 Key flex for position definition.
--   p_deactivate_old_position No boolean  When this is set to TRUE the 'old'
--					   position, ie. P_POSITION_ID is
--					   closed down, ie. its end date is set
--					   to the day before P_DATE_EFFECTIVE.
--					   When this argument is set to FALSE,
--					   the old position is not closed down.
--   p_mass_move_id	     No   number   Where this Business Process is being
--					   called as part of Mass Move, this is
--					   the particular mass move that is
--					   being processed.
--
-- Post Success:
--   The pre-move position validation has been successful, ie. the position
--   has been validated for moving, and processing by the core move_position
--   proceeds.
--
-- Post Failure:
--   The position has not been successfully validated for moving and an
--    error is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure pre_move_position
  (p_position_id	   in  		number
  ,p_object_version_number in    	number
  ,p_date_effective        in  		date
  ,p_business_group_id	   in		number
  ,p_organization_id	   in  		number
  ,p_segment1              in  		varchar2 default hr_api.g_varchar2
  ,p_segment2              in  		varchar2 default hr_api.g_varchar2
  ,p_segment3              in  		varchar2 default hr_api.g_varchar2
  ,p_segment4              in  		varchar2 default hr_api.g_varchar2
  ,p_segment5              in  		varchar2 default hr_api.g_varchar2
  ,p_segment6              in  		varchar2 default hr_api.g_varchar2
  ,p_segment7              in  		varchar2 default hr_api.g_varchar2
  ,p_segment8              in  		varchar2 default hr_api.g_varchar2
  ,p_segment9              in  		varchar2 default hr_api.g_varchar2
  ,p_segment10             in  		varchar2 default hr_api.g_varchar2
  ,p_segment11             in  		varchar2 default hr_api.g_varchar2
  ,p_segment12             in  		varchar2 default hr_api.g_varchar2
  ,p_segment13             in  		varchar2 default hr_api.g_varchar2
  ,p_segment14             in  		varchar2 default hr_api.g_varchar2
  ,p_segment15             in  		varchar2 default hr_api.g_varchar2
  ,p_segment16             in  		varchar2 default hr_api.g_varchar2
  ,p_segment17             in  		varchar2 default hr_api.g_varchar2
  ,p_segment18             in  		varchar2 default hr_api.g_varchar2
  ,p_segment19             in  		varchar2 default hr_api.g_varchar2
  ,p_segment20             in  		varchar2 default hr_api.g_varchar2
  ,p_segment21             in  		varchar2 default hr_api.g_varchar2
  ,p_segment22             in  		varchar2 default hr_api.g_varchar2
  ,p_segment23             in  		varchar2 default hr_api.g_varchar2
  ,p_segment24             in  		varchar2 default hr_api.g_varchar2
  ,p_segment25             in  		varchar2 default hr_api.g_varchar2
  ,p_segment26             in  		varchar2 default hr_api.g_varchar2
  ,p_segment27             in  		varchar2 default hr_api.g_varchar2
  ,p_segment28             in  		varchar2 default hr_api.g_varchar2
  ,p_segment29             in  		varchar2 default hr_api.g_varchar2
  ,p_segment30             in  		varchar2 default hr_api.g_varchar2
  ,p_deactivate_old_position in		boolean  default false
  ,p_mass_move_id	   in  		number   default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< post_move_position >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- The post-core move position procedure is delivered as an 'empty' packaged
-- procedure which the customer can customize by coding any additional
-- DML which they may require at position level before a position is moved.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                     	  Reqd Type     Description
--   p_validate               	  No   boolean  If true, the database
--                                              remains unchanged. If false,
--                                              the assignment is updated.
--   p_position_id		  Yes  number   The 'old' position which was
--                                              moved.
--   p_object_version_number	  Yes  number   The object version number of
--                                              the 'old' position, ie. the
--                                              position which was moved.
--   p_date_effective          	  Yes  date     The start date of the new
--                                              position which is to be created.
--   p_business_group_id	  Yes  number   The business group of the old
--                                              and new positions.
--   p_organization_id		  Yes  number   The organization to which the
--					        position was moved.
--   p_deactivate_old_position 	  No   boolean  When this is set to TRUE the
--                                              'old' position, ie.
--                                              P_POSITION_ID was closed down,
--                                              ie. its end date was set to the
--                                              day before P_DATE_EFFECTIVE.
--					        When this argument is set to
--                                              FALSE, the old position was not
--                                              closed down.
--   p_new_position_id		  Yes  number   The new position which was
--					        created to accomplish the move.
--   p_new_object_version_number  Yes  number   The object version number of the
--					        'new' position, ie. the position
--					        which was created to accomplish
--					        the move.
--   p_mass_move_id	          No   number   Where this Business Process is
--                                              being called as part of Mass
--                                              Move, this is the particular
--                                              mass move that is being
--                                              processed.
--
--
-- Post Success:
--   When the post-move position DML is successful, the following out
--   parameters are set :
--   Name                     	  Type     Description
--   p_object_version_number	  number   The object version number of the
--                                         'old' position, ie. the position
--                                         which was moved.
--   p_new_object_version_number  number   The object version number of the
--					   'new' position, ie. the position
--					    which was created to accomplish
--					    the move.
--
-- Post Failure:
--   The API does not update the position(s) and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
procedure post_move_position
  (p_validate		   	in	boolean  default false
  ,p_position_id		in	number
  ,p_object_version_number	in out	number
  ,p_date_effective		in	date
  ,p_business_group_id		in	number
  ,p_organization_id		in	number
  ,p_deactivate_old_position	in	boolean  default false
  ,p_new_position_id		in	number
  ,p_new_object_version_number	in out	number
  ,p_mass_move_id	   	in   	number   default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< pre_mass_move >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- The pre-core mass move procedure is delivered as an 'empty'
-- packaged procedure which the customer can customize by coding any additional
-- validation which they may require before a mass move begins.
--
-- Prerequisites:
--   None.
--
--
-- In Parameters:
--   Name                    Reqd Type     Description
--   p_mass_move_id	     Y    number   The ID of the mass move.
--
-- Post Success:
--   The pre-move validation has been successful, and processing by the
--   core mass_move process proceeds.
--
-- Post Failure:
--   The mass move has not been successfully validated for continuing and an
--    error is raised.
--
-- Access Status:
--   Public.
--
--
procedure pre_mass_move
  (p_mass_move_id	   in  		number   default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< post_mass_move >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- The post-core mass move procedure is delivered as an 'empty'
-- packaged procedure which the customer can customize by coding any additional
-- validation after a mass move has completed.
--
-- Prerequisites:
--  None.
--
-- In Parameters:
--   Name                     	  Reqd Type     Description
--   p_mass_move_id               Yes  number   The ID of the mass move
--
-- Post Success:
--   The entire mass move process completes.
--
-- Post Failure:
--   Errors are written to HR_API_BATCH_MESSAGE_LINES table.
--
-- Access Status:
--   Public.
--
--
procedure post_mass_move
  (p_mass_move_id	   	in   	number   default hr_api.g_number
  );
--
end hr_mass_move_cus ;
--

 

/
