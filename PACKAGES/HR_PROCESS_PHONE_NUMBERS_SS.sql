--------------------------------------------------------
--  DDL for Package HR_PROCESS_PHONE_NUMBERS_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_PHONE_NUMBERS_SS" AUTHID CURRENT_USER AS
 /* $Header: hrphnwrs.pkh 120.0 2005/05/31 02:10:40 appldev noship $*/

  gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';
  g_date_format  constant varchar2(10):='RRRR-MM-DD';

  /*
  ||===========================================================================
  || PROCEDURE: create_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.create_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
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

  procedure create_phone(p_date_from  date
    , p_date_to  date default null
    , p_phone_type  VARCHAR2
    , p_phone_number  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table  VARCHAR2
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding phones for contacts parent_is is contact_person_id.
    -- Login person id is say employee who is adding the phones to his contact.
    --
    , p_login_person_id     NUMBER default null
    , p_business_group_id   number default null
    , p_attribute_category  VARCHAR2 default hr_api.g_varchar2
    , p_attribute1  VARCHAR2 default hr_api.g_varchar2
    , p_attribute2  VARCHAR2 default hr_api.g_varchar2
    , p_attribute3  VARCHAR2 default hr_api.g_varchar2
    , p_attribute4  VARCHAR2 default hr_api.g_varchar2
    , p_attribute5  VARCHAR2 default hr_api.g_varchar2
    , p_attribute6  VARCHAR2 default hr_api.g_varchar2
    , p_attribute7  VARCHAR2 default hr_api.g_varchar2
    , p_attribute8  VARCHAR2 default hr_api.g_varchar2
    , p_attribute9  VARCHAR2 default hr_api.g_varchar2
    , p_attribute10  VARCHAR2 default hr_api.g_varchar2
    , p_attribute11  VARCHAR2 default hr_api.g_varchar2
    , p_attribute12  VARCHAR2 default hr_api.g_varchar2
    , p_attribute13  VARCHAR2 default hr_api.g_varchar2
    , p_attribute14  VARCHAR2 default hr_api.g_varchar2
    , p_attribute15  VARCHAR2 default hr_api.g_varchar2
    , p_attribute16  VARCHAR2 default hr_api.g_varchar2
    , p_attribute17  VARCHAR2 default hr_api.g_varchar2
    , p_attribute18  VARCHAR2 default hr_api.g_varchar2
    , p_attribute19  VARCHAR2 default hr_api.g_varchar2
    , p_attribute20  VARCHAR2 default hr_api.g_varchar2
    , p_attribute21  VARCHAR2 default hr_api.g_varchar2
    , p_attribute22  VARCHAR2 default hr_api.g_varchar2
    , p_attribute23  VARCHAR2 default hr_api.g_varchar2
    , p_attribute24  VARCHAR2 default hr_api.g_varchar2
    , p_attribute25  VARCHAR2 default hr_api.g_varchar2
    , p_attribute26  VARCHAR2 default hr_api.g_varchar2
    , p_attribute27  VARCHAR2 default hr_api.g_varchar2
    , p_attribute28  VARCHAR2 default hr_api.g_varchar2
    , p_attribute29  VARCHAR2 default hr_api.g_varchar2
    , p_attribute30  VARCHAR2 default hr_api.g_varchar2
  -- StartRegistration
    ,p_per_or_contact varchar2 default null
  -- EndRegistration
    , p_validate  number default 0
    , p_effective_date  date
    , p_object_version_number out nocopy  NUMBER
    , p_phone_id out nocopy  NUMBER
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_contact_relationship_id       in number           default hr_api.g_number
  );

   /*
  ||===========================================================================
  || PROCEDURE: update_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.update_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
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

 procedure update_phone(p_phone_id  NUMBER
    , p_date_from  date default hr_api.g_date
    , p_date_to  date default hr_api.g_date
    , p_phone_type  VARCHAR2 default hr_api.g_varchar2
    , p_phone_number  VARCHAR2 default hr_api.g_number
    , p_per_or_contact varchar2 default null
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding phones for contacts parent_is is contact_person_id.
    -- Login person id is say employee who is adding the phones to his contact.
    --
    , p_login_person_id     NUMBER default hr_api.g_number
    , p_attribute_category  VARCHAR2 default hr_api.g_varchar2
    , p_attribute1  VARCHAR2 default hr_api.g_varchar2
    , p_attribute2  VARCHAR2 default hr_api.g_varchar2
    , p_attribute3  VARCHAR2 default hr_api.g_varchar2
    , p_attribute4  VARCHAR2 default hr_api.g_varchar2
    , p_attribute5  VARCHAR2 default hr_api.g_varchar2
    , p_attribute6  VARCHAR2 default hr_api.g_varchar2
    , p_attribute7  VARCHAR2 default hr_api.g_varchar2
    , p_attribute8  VARCHAR2 default hr_api.g_varchar2
    , p_attribute9  VARCHAR2 default hr_api.g_varchar2
    , p_attribute10  VARCHAR2 default hr_api.g_varchar2
    , p_attribute11  VARCHAR2 default hr_api.g_varchar2
    , p_attribute12  VARCHAR2 default hr_api.g_varchar2
    , p_attribute13  VARCHAR2 default hr_api.g_varchar2
    , p_attribute14  VARCHAR2 default hr_api.g_varchar2
    , p_attribute15  VARCHAR2 default hr_api.g_varchar2
    , p_attribute16  VARCHAR2 default hr_api.g_varchar2
    , p_attribute17  VARCHAR2 default hr_api.g_varchar2
    , p_attribute18  VARCHAR2 default hr_api.g_varchar2
    , p_attribute19  VARCHAR2 default hr_api.g_varchar2
    , p_attribute20  VARCHAR2 default hr_api.g_varchar2
    , p_attribute21  VARCHAR2 default hr_api.g_varchar2
    , p_attribute22  VARCHAR2 default hr_api.g_varchar2
    , p_attribute23  VARCHAR2 default hr_api.g_varchar2
    , p_attribute24  VARCHAR2 default hr_api.g_varchar2
    , p_attribute25  VARCHAR2 default hr_api.g_varchar2
    , p_attribute26  VARCHAR2 default hr_api.g_varchar2
    , p_attribute27  VARCHAR2 default hr_api.g_varchar2
    , p_attribute28  VARCHAR2 default hr_api.g_varchar2
    , p_attribute29  VARCHAR2 default hr_api.g_varchar2
    , p_attribute30  VARCHAR2 default hr_api.g_varchar2
    , p_object_version_number in out nocopy  NUMBER
    , p_validate  number default 0
    , p_effective_date  date
    , p_parent_id  NUMBER
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_contact_relationship_id       in number           default hr_api.g_number
  );

   /*
  ||===========================================================================
  || PROCEDURE: delete_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.delete_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
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

  procedure delete_phone(p_validate  number default 0
    , p_phone_id  in NUMBER
    , p_object_version_number  in NUMBER
    , p_parent_id                     in     number
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding phones for contacts parent_is is contact_person_id.
    -- Login person id is say employee who is adding the phones to his contact.
    --
    , p_login_person_id     NUMBER default hr_api.g_number
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_per_or_contact varchar2 default null
  );

   /*
  ||===========================================================================
  || PROCEDURE: create_or_update_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.create_or_update_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
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

  procedure create_or_update_phone(p_update_mode  VARCHAR2
    , p_phone_id in out nocopy  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_date_from  date
    , p_date_to  date
    , p_phone_type  VARCHAR2
    , p_phone_number  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2 default hr_api.g_varchar2
    , p_attribute2  VARCHAR2 default hr_api.g_varchar2
    , p_attribute3  VARCHAR2 default hr_api.g_varchar2
    , p_attribute4  VARCHAR2 default hr_api.g_varchar2
    , p_attribute5  VARCHAR2 default hr_api.g_varchar2
    , p_attribute6  VARCHAR2 default hr_api.g_varchar2
    , p_attribute7  VARCHAR2 default hr_api.g_varchar2
    , p_attribute8  VARCHAR2 default hr_api.g_varchar2
    , p_attribute9  VARCHAR2 default hr_api.g_varchar2
    , p_attribute10  VARCHAR2 default hr_api.g_varchar2
    , p_attribute11  VARCHAR2 default hr_api.g_varchar2
    , p_attribute12  VARCHAR2 default hr_api.g_varchar2
    , p_attribute13  VARCHAR2 default hr_api.g_varchar2
    , p_attribute14  VARCHAR2 default hr_api.g_varchar2
    , p_attribute15  VARCHAR2 default hr_api.g_varchar2
    , p_attribute16  VARCHAR2 default hr_api.g_varchar2
    , p_attribute17  VARCHAR2 default hr_api.g_varchar2
    , p_attribute18  VARCHAR2 default hr_api.g_varchar2
    , p_attribute19  VARCHAR2 default hr_api.g_varchar2
    , p_attribute20  VARCHAR2 default hr_api.g_varchar2
    , p_attribute21  VARCHAR2 default hr_api.g_varchar2
    , p_attribute22  VARCHAR2 default hr_api.g_varchar2
    , p_attribute23  VARCHAR2 default hr_api.g_varchar2
    , p_attribute24  VARCHAR2 default hr_api.g_varchar2
    , p_attribute25  VARCHAR2 default hr_api.g_varchar2
    , p_attribute26  VARCHAR2 default hr_api.g_varchar2
    , p_attribute27  VARCHAR2 default hr_api.g_varchar2
    , p_attribute28  VARCHAR2 default hr_api.g_varchar2
    , p_attribute29  VARCHAR2 default hr_api.g_varchar2
    , p_attribute30  VARCHAR2 default hr_api.g_varchar2
    , p_validate  number
    , p_effective_date  date
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
  );

-- ---------------------------------------------------------------------------
-- ---------------------- < get_phone_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes or vice-versa.  Hence, we need to use
--          the item_type item_key passed in to retrieve the transaction record.
-- ---------------------------------------------------------------------------
PROCEDURE get_phone_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_phone_numbers_data              out nocopy varchar2
);

-- ---------------------------------------------------------------------------
-- ---------------------- < get_phone_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is a overloaded version
-- ---------------------------------------------------------------------------
procedure get_phone_data_from_tt
   (p_transaction_step_id             in  number
   ,p_person_id                       out nocopy number
   ,p_phone_data                      out nocopy varchar2
);

/*---------------------------------------------------------------------------+
|                                                                            |
|       Name           : process_api                                         |
|                                                                            |
|       Purpose        : This will procedure is invoked whenever approver    |
|                        approves the address change.                        |
|                                                                            |
+-----------------------------------------------------------------------------*/
procedure process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
);

procedure get_transaction_details
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_phone_numbers_details           in out nocopy sshr_phone_details_tab_typ
);

PROCEDURE get_transaction_details
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_con_phone_numbers_details       in out nocopy sshr_con_phone_details_tab_typ
);


end hr_process_phone_numbers_ss;

 

/
