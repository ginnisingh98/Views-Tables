--------------------------------------------------------
--  DDL for Package HR_PROCESS_EIT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_EIT_SS" AUTHID CURRENT_USER as
/* $Header: hreitwrs.pkh 115.4 2002/12/05 19:32:15 snachuri noship $ */


  gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';


--
-- ----------------------------------------------------------------------------
-- |----------------------------< save_transaction_data >--------------------------------|
-- ----------------------------------------------------------------------------
  /*
  ||===========================================================================
  || PROCEDURE: save_transaction_data
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE save_transaction_data
    (p_person_id                 in   number
    ,p_login_person_id           in   number
    ,p_eit_type			 in   varchar2
    ,p_eit_type_id		 in   number
    ,p_eit_number		 in   number
    ,p_eit_table		 in   HR_EIT_STRUCTURE_TABLE
    ,p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   number
    ,p_transaction_step_id       out nocopy  number
    ,p_error_message             out nocopy  varchar2
    ,p_active_view               in   varchar2
    ,p_active_row_id		 in   number
    ,p_flow_mode                     in     varchar2 default null
  );


-- ---------------------------------------------------------------------------
-- ---------------------- < get_eit_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a given person id, workflow process name
--          and workflow activity name.  This is the overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_eit_data_from_tt
  (p_item_type                 in   varchar2
  ,p_item_key                  in   varchar2
  ,p_activity_id               in   number
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id	             out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_eit_table	            	     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy  long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
);

--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_eit_data_from_tt >---------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------

procedure get_eit_data_from_tt
  (p_transaction_step_id             in      number
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id	             out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_eit_table			     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy  long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
);

-- ----------------------------------------------------------------------------
-- |-----------------------< del_transaction_data >---------------------------|
-- Wrapper Package for API hr_process_sit_ss.
--
-- Description:
--  This Function dels the transaction data for the given item type, item key
--  and activity id.
-- ----------------------------------------------------------------------------

PROCEDURE del_transaction_data
    (p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   varchar2
    ,p_login_person_id           in   varchar2
    ,p_flow_mode                     in     varchar2 default null
);

--
-- ----------------------------------------------------------------------------
-- |-----------------------< process_api >-------------------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure .....
-- ---------------------------------------------------------------------------

PROCEDURE PROCESS_API
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date      IN VARCHAR2 DEFAULT null
);

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eit >--------------------------------|
-- ----------------------------------------------------------------------------
  /*
  ||===========================================================================
  || PROCEDURE: create_eit
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
procedure create_eit
  (p_validate                  in     number   default 0
  ,p_login_person_id           in     number default null
  ,p_eit_type    	       in     varchar2
  ,p_person_id                 in     number
  ,p_information_type          in     varchar2
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_information_category      in     varchar2 default null
  ,p_information1              in     varchar2 default null
  ,p_information2              in     varchar2 default null
  ,p_information3              in     varchar2 default null
  ,p_information4              in     varchar2 default null
  ,p_information5              in     varchar2 default null
  ,p_information6              in     varchar2 default null
  ,p_information7              in     varchar2 default null
  ,p_information8              in     varchar2 default null
  ,p_information9              in     varchar2 default null
  ,p_information10             in     varchar2 default null
  ,p_information11             in     varchar2 default null
  ,p_information12             in     varchar2 default null
  ,p_information13             in     varchar2 default null
  ,p_information14             in     varchar2 default null
  ,p_information15             in     varchar2 default null
  ,p_information16             in     varchar2 default null
  ,p_information17             in     varchar2 default null
  ,p_information18             in     varchar2 default null
  ,p_information19             in     varchar2 default null
  ,p_information20             in     varchar2 default null
  ,p_information21             in     varchar2 default null
  ,p_information22             in     varchar2 default null
  ,p_information23             in     varchar2 default null
  ,p_information24             in     varchar2 default null
  ,p_information25             in     varchar2 default null
  ,p_information26             in     varchar2 default null
  ,p_information27             in     varchar2 default null
  ,p_information28             in     varchar2 default null
  ,p_information29              in     varchar2 default null
  ,p_information30             in     varchar2 default null
  ,p_extra_info_id             out nocopy number
  ,p_object_version_number     out nocopy number
  -- EndRegistration
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_action                        in     varchar2
  ,p_old_extra_info_id             in     number   default null
  ,p_old_object_version_number     in     number   default null
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  ,p_eit_type_id    	           in     number
  ,p_flow_mode                     in     varchar2 default null
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_eit >--------------------------------|
-- ----------------------------------------------------------------------------
  /*
  ||===========================================================================
  || PROCEDURE: update_eit
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE update_eit
  (p_validate                  in     number   default 0
  ,p_login_person_id           in     number default null
  ,p_eit_type    	       in     varchar2
  ,p_person_id                 in     number
  ,p_information_type          in     varchar2
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_information_category      in     varchar2 default null
  ,p_information1              in     varchar2 default null
  ,p_information2              in     varchar2 default null
  ,p_information3              in     varchar2 default null
  ,p_information4              in     varchar2 default null
  ,p_information5              in     varchar2 default null
  ,p_information6              in     varchar2 default null
  ,p_information7              in     varchar2 default null
  ,p_information8              in     varchar2 default null
  ,p_information9              in     varchar2 default null
  ,p_information10             in     varchar2 default null
  ,p_information11             in     varchar2 default null
  ,p_information12             in     varchar2 default null
  ,p_information13             in     varchar2 default null
  ,p_information14             in     varchar2 default null
  ,p_information15             in     varchar2 default null
  ,p_information16             in     varchar2 default null
  ,p_information17             in     varchar2 default null
  ,p_information18             in     varchar2 default null
  ,p_information19             in     varchar2 default null
  ,p_information20             in     varchar2 default null
  ,p_information21             in     varchar2 default null
  ,p_information22             in     varchar2 default null
  ,p_information23             in     varchar2 default null
  ,p_information24             in     varchar2 default null
  ,p_information25             in     varchar2 default null
  ,p_information26             in     varchar2 default null
  ,p_information27             in     varchar2 default null
  ,p_information28             in     varchar2 default null
  ,p_information29             in     varchar2 default null
  ,p_information30             in     varchar2 default null
  ,p_extra_info_id             in     number
  ,p_object_version_number     in out nocopy number
  -- EndRegistration
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_action                        in     varchar2
  ,p_old_extra_info_id             in     number   default null
  ,p_old_object_version_number     in     number   default null
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  ,p_eit_type_id    	       in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eit >--------------------------------|
-- ----------------------------------------------------------------------------
  /*
  ||===========================================================================
  || PROCEDURE: delete_eit
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

procedure delete_eit
  (p_validate                  in     number   default 0
  ,p_login_person_id           in     number default null
  ,p_eit_type                  in     varchar2
  ,p_eit_type_id               in     number
  ,p_person_id                 in     number
  ,p_information_type          in     varchar2
  ,p_extra_info_id             in     number
  ,p_object_version_number     in      number
  -- EndRegistration
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_action                        in     varchar2
  ,p_old_extra_info_id             in     number   default null
  ,p_old_object_version_number     in     number   default null
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  );


--
-- ----------------------------------------------------------------------------
-- |----------------------------< dump_eit_table >--------------------------------|
-- ----------------------------------------------------------------------------
  /*
  ||===========================================================================
  || PROCEDURE: dump_eit_table
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE dump_eit_table (p_eit_table  in   HR_EIT_STRUCTURE_TABLE );

end hr_process_eit_ss;

 

/
