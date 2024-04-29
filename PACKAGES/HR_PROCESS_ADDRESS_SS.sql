--------------------------------------------------------
--  DDL for Package HR_PROCESS_ADDRESS_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_ADDRESS_SS" AUTHID CURRENT_USER AS
/* $Header: hraddwrs.pkh 120.0 2005/05/30 22:34:28 appldev noship $*/

  gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';
  g_date_format  constant varchar2(10):='RRRR-MM-DD';

  /*
  ||===========================================================================
  || PROCEDURE: create_person_address
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_address_api.create_person_address()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see peaddapi.pkb file.
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
  PROCEDURE create_person_address
    (p_validate                      in     number   default 0
    ,p_effective_date                in     date
    ,p_pradd_ovlapval_override       in     number   default 0
    ,p_validate_county               in     number   default 1
    ,p_person_id                     in     number
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding address for contacts person_id is contact_person_id.
    -- Login person id is say employee who is adding the address to his contact.
    --
    ,p_login_person_id               in     number default null
    ,p_business_group_id             in     number default null
    ,p_primary_flag                  in     varchar2
    ,p_style                         in     varchar2
    ,p_date_from                     in     date
    ,p_date_to                       in     date     default null
    ,p_address_type                  in     varchar2 default hr_api.g_varchar2
    ,p_address_type_meaning          in     varchar2 default hr_api.g_varchar2
    ,p_comments                      in     long default hr_api.g_varchar2
    ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
    ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
    ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
    ,p_town_or_city                  in     varchar2 default hr_api.g_varchar2
    ,p_region_1                      in     varchar2 default hr_api.g_varchar2
    ,p_region_2                      in     varchar2 default hr_api.g_varchar2
    ,p_region_3                      in     varchar2 default hr_api.g_varchar2
    ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
    ,p_country                       in     varchar2 default hr_api.g_varchar2
    ,p_country_meaning               in     varchar2 default hr_api.g_varchar2
    ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
    ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
    ,p_telephone_number_3            in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
    ,p_add_information13             in     varchar2 default hr_api.g_varchar2
    ,p_add_information14             in     varchar2 default hr_api.g_varchar2
    ,p_add_information15             in     varchar2 default hr_api.g_varchar2
    ,p_add_information16             in     varchar2 default hr_api.g_varchar2
    ,p_add_information17             in     varchar2 default hr_api.g_varchar2
    ,p_add_information18             in     varchar2 default hr_api.g_varchar2
    ,p_add_information19             in     varchar2 default hr_api.g_varchar2
    ,p_add_information20             in     varchar2 default hr_api.g_varchar2
    ,p_address_id                       out nocopy number
    ,p_object_version_number            out nocopy number
    -- StartRegistration
    ,p_contact_or_person             in     varchar2 default null
    -- EndRegistration
    ,p_item_type                     in     varchar2
    ,p_item_key                      in     varchar2
    ,p_activity_id                   in     number
    ,p_action                        in     varchar2
    ,p_old_address_id                in     number default null
    ,p_old_object_version_number     in     number default null
    ,p_save_mode                     in     varchar2 default null
    ,p_error_message                 out nocopy    long
    ,p_contact_relationship_id       in number           default hr_api.g_number
);

  /*
  ||===========================================================================
  || PROCEDURE: update_person_address
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_address_api.update_person_address()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see peaddapi.pkb file.
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

PROCEDURE update_person_address
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_validate_county               in     number  default 1
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_address_type_meaning          in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_town_or_city                  in     varchar2 default hr_api.g_varchar2
  ,p_region_1                      in     varchar2 default hr_api.g_varchar2
  ,p_region_2                      in     varchar2 default hr_api.g_varchar2
  ,p_region_3                      in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_country_meaning               in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_3            in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_add_information13             in     varchar2 default hr_api.g_varchar2
  ,p_add_information14             in     varchar2 default hr_api.g_varchar2
  ,p_add_information15             in     varchar2 default hr_api.g_varchar2
  ,p_add_information16             in     varchar2 default hr_api.g_varchar2
  ,p_add_information17             in     varchar2 default hr_api.g_varchar2
  ,p_add_information18             in     varchar2 default hr_api.g_varchar2
  ,p_add_information19             in     varchar2 default hr_api.g_varchar2
  ,p_add_information20             in     varchar2 default hr_api.g_varchar2
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_person_id                     in     number
  --
  -- PB Add :
  -- The transaction steps have to be created by the login personid.
  -- In case of adding phones for contacts parent_is is contact_person_id.
  -- Login person id is say employee who is adding the phones to his contact.
  --
  ,p_contact_or_person             in     varchar2 default null
  ,p_login_person_id               in     number default null
  ,p_primary_flag                  in     varchar2
  ,p_style                         in     varchar2
  ,p_action                        in     varchar2
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  ,p_contact_relationship_id       in number           default hr_api.g_number
);

-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a given person id, workflow process name
--          and workflow activity name.  This is the overloaded version.
-- ---------------------------------------------------------------------------

PROCEDURE get_address_data_from_tt
   (p_item_type                       in     varchar2
   ,p_process_name                    in     varchar2
   ,p_activity_name                   in     varchar2
   ,p_current_person_id               in     varchar2
   ,p_effective_date                  out nocopy    date
   ,p_person_id                       out nocopy number
   ,p_address_id                      out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_primary_flag                    out nocopy varchar2
   ,p_style                           out nocopy varchar2
   ,p_date_from                       out nocopy date
   ,p_date_to                         out nocopy date
   ,p_address_type                    out nocopy varchar2
   ,p_address_type_meaning            out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_address_line1                   out nocopy varchar2
   ,p_address_line2                   out nocopy varchar2
   ,p_address_line3                   out nocopy varchar2
   ,p_town_or_city                    out nocopy varchar2
   ,p_region_1                        out nocopy varchar2
   ,p_region_2                        out nocopy varchar2
   ,p_region_3                        out nocopy varchar2
   ,p_postal_code                     out nocopy varchar2
   ,p_country                         out nocopy varchar2
   ,p_country_meaning                 out nocopy varchar2
   ,p_telephone_number_1              out nocopy varchar2
   ,p_telephone_number_2              out nocopy varchar2
   ,p_telephone_number_3              out nocopy varchar2
   ,p_addr_attribute_category         out nocopy varchar2
   ,p_addr_attribute1                 out nocopy varchar2
   ,p_addr_attribute2                 out nocopy varchar2
   ,p_addr_attribute3                 out nocopy varchar2
   ,p_addr_attribute4                 out nocopy varchar2
   ,p_addr_attribute5                 out nocopy varchar2
   ,p_addr_attribute6                 out nocopy varchar2
   ,p_addr_attribute7                 out nocopy varchar2
   ,p_addr_attribute8                 out nocopy varchar2
   ,p_addr_attribute9                 out nocopy varchar2
   ,p_addr_attribute10                out nocopy varchar2
   ,p_addr_attribute11                out nocopy varchar2
   ,p_addr_attribute12                out nocopy varchar2
   ,p_addr_attribute13                out nocopy varchar2
   ,p_addr_attribute14                out nocopy varchar2
   ,p_addr_attribute15                out nocopy varchar2
   ,p_addr_attribute16                out nocopy varchar2
   ,p_addr_attribute17                out nocopy varchar2
   ,p_addr_attribute18                out nocopy varchar2
   ,p_addr_attribute19                out nocopy varchar2
   ,p_addr_attribute20                out nocopy varchar2
   ,p_add_information17               out nocopy varchar2
   ,p_add_information18               out nocopy varchar2
   ,p_add_information19               out nocopy varchar2
   ,p_add_information20               out nocopy varchar2
   ,p_action                          out nocopy varchar2
   ,p_old_address_id                  out nocopy varchar2
   ,p_add_information13               out nocopy varchar2
   ,p_add_information14               out nocopy varchar2
   ,p_add_information15               out nocopy varchar2
   ,p_add_information16               out nocopy varchar2
);

-- ---------------------------------------------------------------------------
-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------

PROCEDURE get_address_data_from_tt
   (p_transaction_step_id             in  number
   ,p_effective_date                  out nocopy date
   ,p_person_id                       out nocopy number
   ,p_address_id                      out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_primary_flag                    out nocopy varchar2
   ,p_style                           out nocopy varchar2
   ,p_date_from                       out nocopy date
   ,p_date_to                         out nocopy date
   ,p_address_type                    out nocopy varchar2
   ,p_address_type_meaning            out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_address_line1                   out nocopy varchar2
   ,p_address_line2                   out nocopy varchar2
   ,p_address_line3                   out nocopy varchar2
   ,p_town_or_city                    out nocopy varchar2
   ,p_region_1                        out nocopy varchar2
   ,p_region_2                        out nocopy varchar2
   ,p_region_3                        out nocopy varchar2
   ,p_postal_code                     out nocopy varchar2
   ,p_country                         out nocopy varchar2
   ,p_country_meaning                 out nocopy varchar2
   ,p_telephone_number_1              out nocopy varchar2
   ,p_telephone_number_2              out nocopy varchar2
   ,p_telephone_number_3              out nocopy varchar2
   ,p_addr_attribute_category         out nocopy varchar2
   ,p_addr_attribute1                 out nocopy varchar2
   ,p_addr_attribute2                 out nocopy varchar2
   ,p_addr_attribute3                 out nocopy varchar2
   ,p_addr_attribute4                 out nocopy varchar2
   ,p_addr_attribute5                 out nocopy varchar2
   ,p_addr_attribute6                 out nocopy varchar2
   ,p_addr_attribute7                 out nocopy varchar2
   ,p_addr_attribute8                 out nocopy varchar2
   ,p_addr_attribute9                 out nocopy varchar2
   ,p_addr_attribute10                out nocopy varchar2
   ,p_addr_attribute11                out nocopy varchar2
   ,p_addr_attribute12                out nocopy varchar2
   ,p_addr_attribute13                out nocopy varchar2
   ,p_addr_attribute14                out nocopy varchar2
   ,p_addr_attribute15                out nocopy varchar2
   ,p_addr_attribute16                out nocopy varchar2
   ,p_addr_attribute17                out nocopy varchar2
   ,p_addr_attribute18                out nocopy varchar2
   ,p_addr_attribute19                out nocopy varchar2
   ,p_addr_attribute20                out nocopy varchar2
   ,p_add_information17               out nocopy varchar2
   ,p_add_information18               out nocopy varchar2
   ,p_add_information19               out nocopy varchar2
   ,p_add_information20               out nocopy varchar2
   ,p_action                          out nocopy varchar2
   ,p_old_address_id                  out nocopy varchar2
   ,p_add_information13               out nocopy varchar2
   ,p_add_information14               out nocopy varchar2
   ,p_add_information15               out nocopy varchar2
   ,p_add_information16               out nocopy varchar2
);

-- ---------------------------------------------------------------------------
-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_address_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_effective_date                  out nocopy    date
   ,p_person_id                       out nocopy number
   ,p_address_id                      out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_primary_flag                    out nocopy varchar2
   ,p_style                           out nocopy varchar2
   ,p_date_from                       out nocopy date
   ,p_date_to                         out nocopy date
   ,p_address_type                    out nocopy varchar2
   ,p_address_type_meaning            out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_address_line1                   out nocopy varchar2
   ,p_address_line2                   out nocopy varchar2
   ,p_address_line3                   out nocopy varchar2
   ,p_town_or_city                    out nocopy varchar2
   ,p_region_1                        out nocopy varchar2
   ,p_region_2                        out nocopy varchar2
   ,p_region_3                        out nocopy varchar2
   ,p_postal_code                     out nocopy varchar2
   ,p_country                         out nocopy varchar2
   ,p_country_meaning                 out nocopy varchar2
   ,p_telephone_number_1              out nocopy varchar2
   ,p_telephone_number_2              out nocopy varchar2
   ,p_telephone_number_3              out nocopy varchar2
   ,p_addr_attribute_category         out nocopy varchar2
   ,p_addr_attribute1                 out nocopy varchar2
   ,p_addr_attribute2                 out nocopy varchar2
   ,p_addr_attribute3                 out nocopy varchar2
   ,p_addr_attribute4                 out nocopy varchar2
   ,p_addr_attribute5                 out nocopy varchar2
   ,p_addr_attribute6                 out nocopy varchar2
   ,p_addr_attribute7                 out nocopy varchar2
   ,p_addr_attribute8                 out nocopy varchar2
   ,p_addr_attribute9                 out nocopy varchar2
   ,p_addr_attribute10                out nocopy varchar2
   ,p_addr_attribute11                out nocopy varchar2
   ,p_addr_attribute12                out nocopy varchar2
   ,p_addr_attribute13                out nocopy varchar2
   ,p_addr_attribute14                out nocopy varchar2
   ,p_addr_attribute15                out nocopy varchar2
   ,p_addr_attribute16                out nocopy varchar2
   ,p_addr_attribute17                out nocopy varchar2
   ,p_addr_attribute18                out nocopy varchar2
   ,p_addr_attribute19                out nocopy varchar2
   ,p_addr_attribute20                out nocopy varchar2
   ,p_add_information17               out nocopy varchar2
   ,p_add_information18               out nocopy varchar2
   ,p_add_information19               out nocopy varchar2
   ,p_add_information20               out nocopy varchar2
   ,p_action                          out nocopy varchar2
   ,p_old_address_id                  out nocopy varchar2
   ,p_add_information13               out nocopy varchar2
   ,p_add_information14               out nocopy varchar2
   ,p_add_information15               out nocopy varchar2
   ,p_add_information16               out nocopy varchar2
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

END hr_process_address_ss;

 

/
