--------------------------------------------------------
--  DDL for Package OTA_ADD_TRAINING_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ADD_TRAINING_SS" AUTHID CURRENT_USER AS
/* $Header: otaddwrs.pkh 120.0.12000000.1 2007/01/18 03:34:57 appldev noship $ */

  gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';
  /*
  ||===========================================================================
  || PROCEDURE: save_add_training
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will save additional training details in Transaction table.
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
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

  PROCEDURE save_add_training(
     p_login_person_id                NUMBER DEFAULT NULL
    , p_item_type                     IN     VARCHAR2
    , p_item_key                      IN     VARCHAR2
    , p_activity_id                   IN     NUMBER
    , p_save_mode                     IN     VARCHAR2 DEFAULT NULL
    , p_error_message                 OUT NOCOPY    VARCHAR2
    , p_title                         IN     VARCHAR2
    , p_supplier                      IN     VARCHAR2
    , p_eq_ota_activity               IN     VARCHAR2
    , p_location                      IN     VARCHAR2
    , p_trntype                       IN     VARCHAR2
    , p_duration                      IN     VARCHAR2
    , p_duration_unit                 IN     VARCHAR2
    , p_status                        IN     VARCHAR2
    , p_completion_date               IN     Date
    , p_award                         IN     VARCHAR2
    , p_score                         IN     VARCHAR2
    , p_internal_contact_person       IN     VARCHAR2
    , p_historyId                     IN     VARCHAR2
    , p_nth_information_category      IN     VARCHAR2     DEFAULT NULL
    , p_nth_information1              IN VARCHAR2     DEFAULT NULL
    , p_nth_information2              IN VARCHAR2     DEFAULT NULL
    , p_nth_information3              IN VARCHAR2     DEFAULT NULL
    , p_nth_information4              IN VARCHAR2     DEFAULT NULL
    , p_nth_information5              IN VARCHAR2     DEFAULT NULL
    , p_nth_information6              IN VARCHAR2     DEFAULT NULL
    , p_nth_information7              IN VARCHAR2     DEFAULT NULL
    , p_nth_information8              IN VARCHAR2     DEFAULT NULL
    , p_nth_information9              IN VARCHAR2     DEFAULT NULL
    , p_nth_information10             IN VARCHAR2     DEFAULT NULL
    , p_nth_information11             IN VARCHAR2     DEFAULT NULL
    , p_nth_information12             IN VARCHAR2     DEFAULT NULL
    , p_nth_information13             in VARCHAR2     DEFAULT NULL
    , p_nth_information14             in VARCHAR2     DEFAULT NULL
    , p_nth_information15             in VARCHAR2     DEFAULT NULL
    , p_nth_information16             in VARCHAR2     DEFAULT NULL
    , p_nth_information17             in VARCHAR2     DEFAULT NULL
    , p_nth_information18             in VARCHAR2     DEFAULT NULL
    , p_nth_information19             in VARCHAR2     DEFAULT NULL
    , p_nth_information20             in VARCHAR2     DEFAULT NULL
    , p_contact_name                  in VARCHAR2
    , p_activity_name                 in VARCHAR2
    , p_obj_ver_no                    in VARCHAR2
    , p_business_grp_id               in VARCHAR2
    , p_person_id                     in NUMBER
    , p_from                          in VARCHAR2
    , p_oafunc                        in VARCHAR2     DEFAULT NULL
    , p_processname                   in VARCHAR2     DEFAULT NULL
    , p_calledfrom                    in VARCHAR2     DEFAULT NULL
    , p_frommenu                      in VARCHAR2     DEFAULT NULL
    , p_org_id                        in VARCHAR2
    , p_transaction_mode              IN VARCHAR2
    , p_check_changes_result          OUT NOCOPY    VARCHAR2 --new parameter
    , p_Status_Meaning                IN     VARCHAR2
    , p_Type_Meaning                  IN     VARCHAR2
  );




-- ---------------------------------------------------------------------------
-- ---------------------- < get_add_trg_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page or make further changes or
--          vice-versa.  Hence, we need to use
--          the item_type item_key passed in to retrieve the transaction record.
-- ---------------------------------------------------------------------------

PROCEDURE get_add_trg_data_from_tt
   (p_item_type                       in  VARCHAR2
   ,p_item_key                        in  VARCHAR2
   ,p_activity_id                     in  VARCHAR2
   ,p_trans_rec_count                 out nocopy NUMBER
   ,p_person_id                       out nocopy NUMBER
   ,p_add_trg_data                    out nocopy VARCHAR2
);

-- ---------------------------------------------------------------------------
-- ---------------------- < get_add_trg_data_from_tt> ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is a overloaded version
-- ---------------------------------------------------------------------------

procedure get_add_trg_data_from_tt
   (p_transaction_step_id             in  NUMBER
   ,p_add_trg_data                    out nocopy VARCHAR2
);

PROCEDURE get_pending_transaction_data
         (p_processname                   IN     VARCHAR2,
          p_item_type                     IN     VARCHAR2,
          p_person_id                     IN     NUMBER,
          p_exclude_historyid             OUT NOCOPY    VARCHAR2,
          p_transaction_step_ids          OUT NOCOPY    VARCHAR2) ;

procedure process_api
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date in varchar2 DEFAULT NULL
);




-- ---------------------------------------------------------------------------
-- ---------------------- < create_add_training_tt > ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id and creates
--          a additional training record.
-- ---------------------------------------------------------------------------


procedure create_add_training_tt
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
);


-- ---------------------------------------------------------------------------
-- ---------------------- < update_add_training_tt > ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id and updates
--          corresponding additional training record.
-- ---------------------------------------------------------------------------

procedure update_add_training_tt
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
);



-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_add_training >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used by self service application to delete additional training records.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Additional Training data will be deleted.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_add_training
                  ( p_nota_history_id IN  OTA_NOTRNG_HISTORIES.NOTA_HISTORY_ID%TYPE
                  , p_trng_title 			IN 	VARCHAR2
                  , p_item_type       IN   WF_ITEMS.ITEM_TYPE%TYPE
                  , p_item_key        IN   WF_ITEMS.ITEM_TYPE%TYPE
                  , p_message         OUT NOCOPY VARCHAR2
                  );



-- ----------------------------------------------------------------------------
-- |-----------------------------< create_add_training >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used by self service application to create additional training records.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Additional Training data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


Procedure create_add_training
  (p_effective_date                in   date
  ,p_nota_history_id               out nocopy NUMBER
  ,p_person_id		                 in 	NUMBER
  ,p_contact_id		                 in 	NUMBER 	DEFAULT NULL
  ,p_trng_title 			             in 	VARCHAR2
  ,p_provider                      in 	VARCHAR2
  ,p_type           		           in 	VARCHAR2 	DEFAULT NULL
  ,p_centre          		           in 	VARCHAR2 	DEFAULT NULL
  ,p_completion_date 		           in 	date
  ,p_award            		         in 	VARCHAR2 	DEFAULT NULL
  ,p_rating          		           in 	VARCHAR2 	DEFAULT NULL
  ,p_duration       		           in 	NUMBER 	DEFAULT NULL
  ,p_duration_units                in 	VARCHAR2 	DEFAULT NULL
  ,p_activity_version_id           in 	NUMBER 	DEFAULT NULL
  ,p_status                        in 	VARCHAR2 	DEFAULT NULL
  ,p_verified_by_id                in 	NUMBER	DEFAULT NULL
  ,p_nth_information_category      in 	VARCHAR2 	DEFAULT NULL
  ,p_nth_information1              in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information2              in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information3              in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information4              in 	VARCHAR2 	DEFAULT NULL
  ,p_nth_information5              in 	VARCHAR2 	DEFAULT NULL
  ,p_nth_information6              in 	VARCHAR2 	DEFAULT NULL
  ,p_nth_information7              in	VARCHAR2 	DEFAULT NULL
  ,p_nth_information8              in 	VARCHAR2  DEFAULT NULL
  ,p_nth_information9              in 	VARCHAR2  DEFAULT NULL
  ,p_nth_information10             in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information11             in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information12             in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information13             in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information15             in 	VARCHAR2 	DEFAULT NULL
  ,p_nth_information16             in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information17             in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information18             in 	VARCHAR2 	DEFAULT NULL
  ,p_nth_information19             in 	VARCHAR2	DEFAULT NULL
  ,p_nth_information20             in 	VARCHAR2	DEFAULT NULL
  ,p_org_id                        in 	NUMBER	DEFAULT NULL
  ,p_object_version_NUMBER         out nocopy 	NUMBER
  ,p_business_group_id             in 	NUMBER
  ,p_nth_information14             in 	VARCHAR2 	DEFAULT NULL
  ,p_customer_id			             in 	NUMBER	DEFAULT NULL
  ,p_organization_id		           in 	NUMBER	DEFAULT NULL
  ,p_some_warning                  out nocopy 	NUMBER
  ,p_message out nocopy VARCHAR2
  ,p_item_type 			               IN WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key 			               IN WF_ITEMS.ITEM_TYPE%TYPE

  );



-- ----------------------------------------------------------------------------
-- |-----------------------------< update_add_training >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used by self service application to update additional training records.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Additional Training data will be updated.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure update_add_training
  (p_effective_date                in   date
  ,p_nota_history_id               in	  NUMBER
  ,p_person_id		                 in 	NUMBER
  ,p_contact_id		                 in 	NUMBER 	DEFAULT hr_api.g_NUMBER
  ,p_trng_title 			             in 	VARCHAR2
  ,p_provider                      in 	VARCHAR2
  ,p_type           		           in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_centre          		           in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_completion_date 		           in 	date
  ,p_award            		         in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_rating          		           in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_duration       		           in 	NUMBER 	DEFAULT hr_api.g_NUMBER
  ,p_duration_units                in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_activity_version_id           in 	NUMBER 	DEFAULT hr_api.g_NUMBER
  ,p_status                        in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_verified_by_id                in 	NUMBER	DEFAULT hr_api.g_NUMBER
  ,p_nth_information_category      in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information1              in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information2              in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information3              in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information4              in 	VARCHAR2  	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information5              in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information6              in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information7              in	  VARCHAR2  	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information8              in 	VARCHAR2    DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information9              in 	VARCHAR2   	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information10             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information11             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information12             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information13             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information14             in 	VARCHAR2  	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information15             in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information16             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information17             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information18             in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information19             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information20             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_org_id                        in 	NUMBER	DEFAULT hr_api.g_NUMBER
  ,p_old_object_version_NUMBER         in  NUMBER
  ,p_business_group_id             in 	NUMBER
  ,p_customer_id			             in 	NUMBER	DEFAULT hr_api.g_NUMBER
  ,p_organization_id		           in 	NUMBER	DEFAULT hr_api.g_NUMBER
  ,p_some_warning                  out nocopy 	NUMBER
  ,p_message 			 out nocopy VARCHAR2
  ,p_new_object_version_NUMBER         out nocopy  NUMBER
  ,p_item_type 			               IN WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key 			               IN WF_ITEMS.ITEM_TYPE%TYPE
  );


-- ----------------------------------------------------------------------------
-- |-----------------------------<additional_training_notify>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used by self service application to identify which notification (insert or update)
--   to send on commiting a transaction in the table.
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  Procedure additional_training_notify
          (itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout OUT NOCOPY VARCHAR2 );

-- ----------------------------------------------------------------------------
-- |-----------------------------<validate_add_training>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used by self service application to validate the data (with approval mode on)
--   entered by user.
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


  Procedure validate_add_training
           (p_item_type     in varchar2,
            p_item_key      in varchar2,
            p_message out nocopy varchar2);



-- ----------------------------------------------------------------------------
-- |-----------------------------<get_internal_contact_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function  is used by self service application to get the contact person name.
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  Function  get_internal_contact_name
          ( Person_id     IN   per_all_people_f.person_id%TYPE) RETURN per_all_people_f.full_name%TYPE;


-- ----------------------------------------------------------------------------
-- |-----------------------------< check_changes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used by self service application to find out whether in 'update'
--   mode any changes are made or not by comparing it with data from database.
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure check_changes
  (p_nota_history_id               in	  NUMBER
  ,p_contact_id		                 in 	NUMBER 	DEFAULT hr_api.g_NUMBER
  ,p_trng_title 			             in 	VARCHAR2
  ,p_provider                      in 	VARCHAR2
  ,p_type           		           in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_centre          		           in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_completion_date 		           in 	date
  ,p_award            		         in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_rating          		           in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_duration       		           in 	NUMBER 	DEFAULT hr_api.g_NUMBER
  ,p_duration_units                in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_activity_version_id           in 	NUMBER 	DEFAULT hr_api.g_NUMBER
  ,p_status                        in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information_category      in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information1              in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information2              in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information3              in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information4              in 	VARCHAR2  	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information5              in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information6              in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information7              in	  VARCHAR2  	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information8              in 	VARCHAR2    DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information9              in 	VARCHAR2   	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information10             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information11             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information12             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information13             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information14             in 	VARCHAR2  	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information15             in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information16             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information17             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information18             in 	VARCHAR2 	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information19             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_nth_information20             in 	VARCHAR2	DEFAULT hr_api.g_VARCHAR2
  ,p_result 				               out nocopy  NUMBER
  );

Procedure chk_pending_approval
  (p_nota_history_id      in VARCHAR2
   ,p_person_id 			in number );
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_learner_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--   This function is used by self service application to get the contact person name.
--   The above implementation assumes that the contact would be found in the
--   per_all_poople_f table. It is ignoring the possiblity of the contact being
--   that of a customer. This function considers that.
-- In Parameters:
--    Contact_Id - person_id/contact id of employee/customer
--    Organization_Id - this parameter is used to decide if the per_all_people_f
--    or the ra_contacts needs to be queried. If this is null, then the incoming
--    person_id belongs to a Customers' contact and ra_contacts is queried.
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  Function  get_learner_name
          ( Person_id IN   ota_notrng_histories.contact_id%TYPE
           ,Organization_id IN ota_notrng_histories.organization_id%TYPE ) RETURN VARCHAR2;


-- ----------------------------------------------------------------------------
-- |-----------------------------< get_custorg_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--   This function is used by self service application to get the name of the
--   customer or the organization depending on the not null id.
-- In Parameters:
--    Customer_Id - customer_id of the Customer
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION get_custorg_name(p_customer_id OTA_NOTRNG_HISTORIES.CUSTOMER_ID%TYPE,
                   p_organization_id OTA_NOTRNG_HISTORIES.ORGANIZATION_ID%TYPE)
  RETURN VARCHAR2;


END ota_add_training_ss ;

 

/
