--------------------------------------------------------
--  DDL for Package PQP_GENERIC_EIT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GENERIC_EIT_SS" AUTHID CURRENT_USER as
/* $Header: pqpexssvehinfo.pkh 120.0 2005/05/29 02:23:08 appldev noship $ */
--

 gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';



--This procedure is called to create vehicle information in both
--allocation and repository.
PROCEDURE create_generic_eit
  (
   p_validate                 in     boolean default false
  ,p_effective_date           in     date
  ,p_login_person_id          in     number
  ,p_person_id                in     number
  ,p_assignment_id            in     number
  ,p_business_group_id        in     number
  ,p_action                   in     varchar2
  ,p_eit_type                 in     varchar2
  ,p_eit_type_id              in     number
  ,p_information_type         in     varchar2
  ,p_attribute_category       in     varchar2
  ,p_attribute1               in     varchar2
  ,p_attribute2               in     varchar2
  ,p_attribute3               in     varchar2
  ,p_attribute4               in     varchar2
  ,p_attribute5               in     varchar2
  ,p_attribute6               in     varchar2
  ,p_attribute7               in     varchar2
  ,p_attribute8               in     varchar2
  ,p_attribute9               in     varchar2
  ,p_attribute10              in     varchar2
  ,p_attribute11              in     varchar2
  ,p_attribute12              in     varchar2
  ,p_attribute13              in     varchar2
  ,p_attribute14              in     varchar2
  ,p_attribute15              in     varchar2
  ,p_attribute16              in     varchar2
  ,p_attribute17              in     varchar2
  ,p_attribute18              in     varchar2
  ,p_attribute19              in     varchar2
  ,p_attribute20              in     varchar2
  ,p_information_category     in     varchar2
  ,p_information1             in     varchar2
  ,p_information2             in     varchar2
  ,p_information3             in     varchar2
  ,p_information4             in     varchar2
  ,p_information5             in     varchar2
  ,p_information6             in     varchar2
  ,p_information7             in     varchar2
  ,p_information8             in     varchar2
  ,p_information9             in     varchar2
  ,p_information10            in     varchar2
  ,p_information11            in     varchar2
  ,p_information12            in     varchar2
  ,p_information13            in     varchar2
  ,p_information14            in     varchar2
  ,p_information15            in     varchar2
  ,p_information16            in     varchar2
  ,p_information17            in     varchar2
  ,p_information18            in     varchar2
  ,p_information19            in     varchar2
  ,p_information20            in     varchar2
  ,p_information21            in     varchar2
  ,p_information22            in     varchar2
  ,p_information23            in     varchar2
  ,p_information24            in     varchar2
  ,p_information25            in     varchar2
  ,p_information26            in     varchar2
  ,p_information27            in     varchar2
  ,p_information28            in     varchar2
  ,p_information29            in     varchar2
  ,p_information30            in     varchar2
  ,p_object_version_number    in out nocopy  number
  ,p_extra_info_id            in out nocopy number
  ,p_error_message            out    nocopy varchar2
  ,p_error_status             out    nocopy varchar2
   );



PROCEDURE set_extra_info
    (p_effective_date            in   date
    ,p_person_id                 in   number
    ,p_login_person_id           in   number
    ,p_assignment_id             in   number
    ,p_business_group_id         in   number
    ,p_eit_type			 in   varchar2
    ,p_eit_type_id		 in   number
    ,p_eit_number		 in   number
    ,p_eit_table		 in   HR_EIT_STRUCTURE_TABLE
    ,p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   number
    ,p_transaction_step_id       in out nocopy  number
    ,p_error_message             out nocopy  varchar2
    ,p_active_view               in   varchar2
    ,p_active_row_id		 in   number
    ,p_status                    in   varchar2
    ,p_key_id		         in   varchar2
    ,p_flow_mode                 in   varchar2 default null
  ) ;

-----------------------------------------------------------------------------





-- ---------------------------------------------------------------------------
-- ---------------------- < get_eit_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a given person id, workflow process name
--          and workflow activity name.  This is the overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_eit_data_from_tt
  (p_item_type                       in     varchar2
  ,p_item_key                        in     varchar2
  ,p_activity_id                     in     number
  ,p_effective_date                  out nocopy    date
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_assignment_id                   out nocopy    number
  ,p_business_group_id               out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id	             out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_key_id		             out nocopy    varchar2
  ,p_eit_table	            	     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy    long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
);

-- ---------------------------------------------------------------------------
-- ---------------------- < get_eit_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------
procedure get_eit_data_from_tt
  (p_transaction_step_id             in     number
  ,p_effective_date                  out nocopy    date
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_assignment_id                   out nocopy    number
  ,p_business_group_id               out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id		     out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_key_id		             out nocopy    varchar2
  ,p_eit_table	             	     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy    long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
);


PROCEDURE del_transaction_data
    (p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   varchar2
    ,p_login_person_id           in   varchar2
    ,p_flow_mode                 in   varchar2 default null
);


-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE PROCESS_API
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date      IN VARCHAR2 default null
);

PROCEDURE clear_delete_trans (p_item_type           IN     VARCHAR2,
                              p_item_key            IN     VARCHAR2,
                              p_transaction_step_id IN     NUMBER
                             );


END;


 

/
