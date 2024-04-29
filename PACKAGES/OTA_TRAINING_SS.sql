--------------------------------------------------------
--  DDL for Package OTA_TRAINING_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRAINING_SS" AUTHID CURRENT_USER AS
 /* $Header: otenrwrs.pkh 120.1 2005/06/14 12:05:43 mcaruso noship $*/

  gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';
  /*
  ||===========================================================================
  || PROCEDURE: save_adv_search
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will save Advance Search items in Transaction table
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out  Arguments:
  ||
  || In out Arguments:
  ||
  || Post Success:
  ||
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure save_adv_search(
     p_login_person_id     NUMBER default null
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_keyword                       in     VARCHAR2
    , p_category                      in     VARCHAR2
    , p_dmethod                       in     VARCHAR2
    , p_language                      in     VARCHAR2
    , p_trndates                      in     VARCHAR2
    , p_trnorgids                     in     VARCHAR2
    , p_trnorgnames                   in     VARCHAR2
    , p_trncompids                    in     VARCHAR2
    , p_trncompnames                  in     VARCHAR2
    , p_trncompminlvl                 in     VARCHAR2  --Bug 2509979
    , p_trncompmaxlvl                 in     VARCHAR2  --Bug 2509979
    , p_criteria                      in     VARCHAR2
    , p_oafunc                        in     VARCHAR2
    , p_processname                   in     VARCHAR2
    , p_calledfrom                    in     VARCHAR2
    , p_frommenu                      in     VARCHAR2
  );



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


-- ---------------------------------------------------------------------------
-- ---------------------- < get_adv_search_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page or make further changes or
--          vice-versa.  Hence, we need to use
--          the item_type item_key passed in to retrieve the transaction record.
-- ---------------------------------------------------------------------------

PROCEDURE get_adv_search_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_adv_search_data                 out nocopy varchar2
);

-- ---------------------------------------------------------------------------
-- ---------------------- < get_adv_search_data_from_tt> ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is a overloaded version
-- ---------------------------------------------------------------------------

procedure get_adv_search_data_from_tt
   (p_transaction_step_id             in  number
   ,p_adv_search_data                 out nocopy varchar2
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
        ,p_effective_date in varchar2 DEFAULT NULL
);

procedure process_api2
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date in varchar2 DEFAULT NULL
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
  p_message out nocopy varchar2);

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

procedure get_min_competence
 (p_comp_id          in  varchar2,
  p_step_value       out nocopy varchar2);

procedure get_max_competence
 (p_comp_id          in  varchar2,
  p_step_value       out nocopy varchar2);

end ota_training_ss;

 

/
