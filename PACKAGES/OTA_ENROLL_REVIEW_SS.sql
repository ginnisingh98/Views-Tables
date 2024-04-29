--------------------------------------------------------
--  DDL for Package OTA_ENROLL_REVIEW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ENROLL_REVIEW_SS" AUTHID CURRENT_USER AS
 /* $Header: otrevwrs.pkh 115.0 2003/10/20 04:36:06 dbatra noship $*/




  procedure save_add_enroll_detail(
      p_login_person_id     NUMBER default null
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_eventid                       in     VARCHAR2
    , p_activityversionid             in     VARCHAR2
    , p_specialInstruction            in     VARCHAR2
    , p_keyflexId                     in     VARCHAR2
    , p_businessGroupId               in     VARCHAR2
    , p_assignmentId                  in     VARCHAR2
    , p_organizationId                in     VARCHAR2
    , p_from                          in     VARCHAR2
    , p_tdb_information_category            in varchar2     default null
    , p_tdb_information1                    in varchar2     default null
    , p_tdb_information2                    in varchar2     default null
    , p_tdb_information3                    in varchar2     default null
    , p_tdb_information4                    in varchar2     default null
    , p_tdb_information5                    in varchar2     default null
    , p_tdb_information6                    in varchar2     default null
    , p_tdb_information7                    in varchar2     default null
    , p_tdb_information8                    in varchar2     default null
    , p_tdb_information9                    in varchar2     default null
    , p_tdb_information10                   in varchar2     default null
    , p_tdb_information11                   in varchar2     default null
    , p_tdb_information12                   in varchar2     default null
    , p_tdb_information13                   in varchar2     default null
    , p_tdb_information14                   in varchar2     default null
    , p_tdb_information15                   in varchar2     default null
    , p_tdb_information16                   in varchar2     default null
    , p_tdb_information17                   in varchar2     default null
    , p_tdb_information18                   in varchar2     default null
    , p_tdb_information19                   in varchar2     default null
    , p_tdb_information20                   in varchar2     default null
    , p_delegate_person_id                  in  NUMBER default null
    , p_ccselectiontext                     in varchar2     default null
    , p_oafunc                              in varchar2     default null
    , p_processname                         in varchar2     default null
    , p_calledfrom                          in varchar2     default null
    , p_frommenu                            in varchar2     default null
);





PROCEDURE get_add_enr_dtl_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_add_enroll_detail_data          out nocopy varchar2
);



procedure get_add_enr_dtl_data_from_tt
   (p_transaction_step_id             in  number
   ,p_add_enroll_detail_data          out nocopy varchar2
);

PROCEDURE get_review_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_person_id                       out nocopy number
   ,p_review_data                     out nocopy varchar2
);

procedure get_review_data_from_tt
   (p_transaction_step_id             in  number
   ,p_review_data                     out nocopy varchar2
);

procedure process_api
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
);

procedure process_api2
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
);

procedure create_enrollment
 (itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 );

procedure cancel_enrollment
 (itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 );

procedure validate_enrollment
 (p_item_type     in varchar2,
  p_item_key      in varchar2,
  p_message out nocopy varchar2) ;


Procedure create_segment
  (p_assignment_id                        in     number
  ,p_business_group_id_from               in     number
  ,p_business_group_id_to                 in     number
  ,p_organization_id				in     number
  ,p_sponsor_organization_id              in     number
  ,p_event_id 					in 	 number
  ,p_person_id					in     number
  ,p_currency_code				in     varchar2
  ,p_cost_allocation_keyflex_id           in     number
  ,p_user_id                              in     number
  ,p_finance_header_id			 out nocopy    number
  ,p_object_version_number		 out nocopy    number
  ,p_result                     	 out nocopy    varchar2
  ,p_from_result                          out nocopy    varchar2
  ,p_to_result                            out nocopy    varchar2
  ,p_auto_transfer                        in     varchar2);



end ota_enroll_review_ss;

 

/
