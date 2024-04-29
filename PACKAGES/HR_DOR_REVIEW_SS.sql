--------------------------------------------------------
--  DDL for Package HR_DOR_REVIEW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOR_REVIEW_SS" AUTHID CURRENT_USER As
/* $Header: hrdorrevss.pkh 120.0.12010000.4 2010/05/26 11:04:07 tkghosh noship $ */
--


--------------------------------------------------------------------------
--------------------------get_approval_req--------------------------------
--------------------------------------------------------------------------

PROCEDURE get_approval_req  (
				itemtype          IN WF_ITEMS.ITEM_TYPE%TYPE
				,itemkey          IN WF_ITEMS.ITEM_KEY%TYPE
				,actid            IN NUMBER
				,funcmode         IN VARCHAR2
				,resultout        OUT nocopy VARCHAR2 );




--------------------------------------------------------------------------
--------------------------start_transaction-------------------------------
-------This method creates record in tables hr_api_transactions and ------
-------hr_api_transaction_steps.------------------------------------------
--------------------------------------------------------------------------

PROCEDURE start_transaction(
						   p_item_type                     in varchar2
						  ,p_item_key                      in varchar2
						  ,p_act_id                        in number
						  ,p_fun_mode                      in varchar2
						  ,p_login_person_id              in number
						  ,p_product_code                 in varchar2 default 'PER'
						  ,p_url                          in varchar2 default null
						  ,p_status                       in varchar2 default 'W'
						  ,p_section_display_name         in varchar2 default null
						  ,p_function_id                  in number default null
						  ,p_transaction_ref_table        in varchar2 default 'HR_DOCUMENT_EXTRA_INFO'
						  ,p_transaction_ref_id           in number default null
						  ,p_transaction_type             in varchar2 default 'WF'
						  ,p_assignment_id                in number default null
						  ,p_api_addtnl_info              in varchar2 default null
						  ,p_selected_person_id           in number default null
						  ,p_transaction_effective_date   in date default sysdate
						  ,p_process_name                 in varchar2 default null
						  ,p_plan_id                      in number default null
						  ,p_rptg_grp_id                  in number default null
						  ,p_effective_date_option        in varchar2 default 'E'
						  ,p_save_mode                    in varchar2 default null
						  ,p_transaction_step_id          out nocopy  number
						  ,p_transaction_id               out nocopy  number
						  ,p_error_message                out nocopy  varchar2
);


--------------------------------------------------------------------------
--------------------------save_transaction_values-------------------------
-----This method stores the document information of a person in the ------
-----hr_api_transaction_values table--------------------------------------
--------------------------------------------------------------------------


PROCEDURE save_transaction_values(
   p_transaction_step_id          in     varchar2
  ,p_login_person_id              in     varchar2
  ,p_person_id                    in     number
  ,p_document_extra_info_id       in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date      default null
  ,p_document_number              in     varchar2
  ,p_issued_by                    in     varchar2  default null
  ,p_issued_at                    in     varchar2  default null
  ,p_issued_date                  in     date      default null
  ,p_issuing_authority            in     varchar2  default null
  ,p_verified_by                  in     number    default null
  ,p_verified_date                in     date      default null
  ,p_related_object_name          in     varchar2  default null
  ,p_related_object_id_col        in     varchar2  default null
  ,p_related_object_id            in     number    default null
  ,p_dei_attribute_category       in     varchar2  default null
  ,p_dei_attribute1               in     varchar2  default null
  ,p_dei_attribute2               in     varchar2  default null
  ,p_dei_attribute3               in     varchar2  default null
  ,p_dei_attribute4               in     varchar2  default null
  ,p_dei_attribute5               in     varchar2  default null
  ,p_dei_attribute6               in     varchar2  default null
  ,p_dei_attribute7               in     varchar2  default null
  ,p_dei_attribute8               in     varchar2  default null
  ,p_dei_attribute9               in     varchar2  default null
  ,p_dei_attribute10              in     varchar2  default null
  ,p_dei_attribute11              in     varchar2  default null
  ,p_dei_attribute12              in     varchar2  default null
  ,p_dei_attribute13              in     varchar2  default null
  ,p_dei_attribute14              in     varchar2  default null
  ,p_dei_attribute15              in     varchar2  default null
  ,p_dei_attribute16              in     varchar2  default null
  ,p_dei_attribute17              in     varchar2  default null
  ,p_dei_attribute18              in     varchar2  default null
  ,p_dei_attribute19              in     varchar2  default null
  ,p_dei_attribute20              in     varchar2  default null
  ,p_dei_attribute21              in     varchar2  default null
  ,p_dei_attribute22              in     varchar2  default null
  ,p_dei_attribute23              in     varchar2  default null
  ,p_dei_attribute24              in     varchar2  default null
  ,p_dei_attribute25              in     varchar2  default null
  ,p_dei_attribute26              in     varchar2  default null
  ,p_dei_attribute27              in     varchar2  default null
  ,p_dei_attribute28              in     varchar2  default null
  ,p_dei_attribute29              in     varchar2  default null
  ,p_dei_attribute30              in     varchar2  default null
  ,p_dei_information_category     in     varchar2  default null
  ,p_dei_information1             in     varchar2  default null
  ,p_dei_information2             in     varchar2  default null
  ,p_dei_information3             in     varchar2  default null
  ,p_dei_information4             in     varchar2  default null
  ,p_dei_information5             in     varchar2  default null
  ,p_dei_information6             in     varchar2  default null
  ,p_dei_information7             in     varchar2  default null
  ,p_dei_information8             in     varchar2  default null
  ,p_dei_information9             in     varchar2  default null
  ,p_dei_information10            in     varchar2  default null
  ,p_dei_information11            in     varchar2  default null
  ,p_dei_information12            in     varchar2  default null
  ,p_dei_information13            in     varchar2  default null
  ,p_dei_information14            in     varchar2  default null
  ,p_dei_information15            in     varchar2  default null
  ,p_dei_information16            in     varchar2  default null
  ,p_dei_information17            in     varchar2  default null
  ,p_dei_information18            in     varchar2  default null
  ,p_dei_information19            in     varchar2  default null
  ,p_dei_information20            in     varchar2  default null
  ,p_dei_information21            in     varchar2  default null
  ,p_dei_information22            in     varchar2  default null
  ,p_dei_information23            in     varchar2  default null
  ,p_dei_information24            in     varchar2  default null
  ,p_dei_information25            in     varchar2  default null
  ,p_dei_information26            in     varchar2  default null
  ,p_dei_information27            in     varchar2  default null
  ,p_dei_information28            in     varchar2  default null
  ,p_dei_information29            in     varchar2  default null
  ,p_dei_information30            in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );

--------------------------------------------------------------------------
--------------------------Process_api-------------------------------------
------This method is called from commit_transaction ----------------------
--------------------------------------------------------------------------

  procedure process_api
   (p_validate                 in     boolean default false
   ,p_transaction_step_id      in     number
   ,p_effective_date           in     varchar2 default null
   );




--------------------------------------------------------------------------
--------------------------validate_dor------------------------------------
------This method validate the api of documents of records----------------
--------------------------------------------------------------------------


PROCEDURE validate_dor(
   p_validate                     in     number    default hr_api.g_true_num
  ,p_person_id                    in     number
  ,p_document_extra_info_id       in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date      default null
  ,p_document_number              in     varchar2
  ,p_issued_by                    in     varchar2  default null
  ,p_issued_at                    in     varchar2  default null
  ,p_issued_date                  in     date      default null
  ,p_issuing_authority            in     varchar2  default null
  ,p_verified_by                  in     number    default null
  ,p_verified_date                in     date      default null
  ,p_related_object_name          in     varchar2  default null
  ,p_related_object_id_col        in     varchar2  default null
  ,p_related_object_id            in     number    default null
  ,p_dei_attribute_category       in     varchar2  default null
  ,p_dei_attribute1               in     varchar2  default null
  ,p_dei_attribute2               in     varchar2  default null
  ,p_dei_attribute3               in     varchar2  default null
  ,p_dei_attribute4               in     varchar2  default null
  ,p_dei_attribute5               in     varchar2  default null
  ,p_dei_attribute6               in     varchar2  default null
  ,p_dei_attribute7               in     varchar2  default null
  ,p_dei_attribute8               in     varchar2  default null
  ,p_dei_attribute9               in     varchar2  default null
  ,p_dei_attribute10              in     varchar2  default null
  ,p_dei_attribute11              in     varchar2  default null
  ,p_dei_attribute12              in     varchar2  default null
  ,p_dei_attribute13              in     varchar2  default null
  ,p_dei_attribute14              in     varchar2  default null
  ,p_dei_attribute15              in     varchar2  default null
  ,p_dei_attribute16              in     varchar2  default null
  ,p_dei_attribute17              in     varchar2  default null
  ,p_dei_attribute18              in     varchar2  default null
  ,p_dei_attribute19              in     varchar2  default null
  ,p_dei_attribute20              in     varchar2  default null
  ,p_dei_attribute21              in     varchar2  default null
  ,p_dei_attribute22              in     varchar2  default null
  ,p_dei_attribute23              in     varchar2  default null
  ,p_dei_attribute24              in     varchar2  default null
  ,p_dei_attribute25              in     varchar2  default null
  ,p_dei_attribute26              in     varchar2  default null
  ,p_dei_attribute27              in     varchar2  default null
  ,p_dei_attribute28              in     varchar2  default null
  ,p_dei_attribute29              in     varchar2  default null
  ,p_dei_attribute30              in     varchar2  default null
  ,p_dei_information_category     in     varchar2  default null
  ,p_dei_information1             in     varchar2  default null
  ,p_dei_information2             in     varchar2  default null
  ,p_dei_information3             in     varchar2  default null
  ,p_dei_information4             in     varchar2  default null
  ,p_dei_information5             in     varchar2  default null
  ,p_dei_information6             in     varchar2  default null
  ,p_dei_information7             in     varchar2  default null
  ,p_dei_information8             in     varchar2  default null
  ,p_dei_information9             in     varchar2  default null
  ,p_dei_information10            in     varchar2  default null
  ,p_dei_information11            in     varchar2  default null
  ,p_dei_information12            in     varchar2  default null
  ,p_dei_information13            in     varchar2  default null
  ,p_dei_information14            in     varchar2  default null
  ,p_dei_information15            in     varchar2  default null
  ,p_dei_information16            in     varchar2  default null
  ,p_dei_information17            in     varchar2  default null
  ,p_dei_information18            in     varchar2  default null
  ,p_dei_information19            in     varchar2  default null
  ,p_dei_information20            in     varchar2  default null
  ,p_dei_information21            in     varchar2  default null
  ,p_dei_information22            in     varchar2  default null
  ,p_dei_information23            in     varchar2  default null
  ,p_dei_information24            in     varchar2  default null
  ,p_dei_information25            in     varchar2  default null
  ,p_dei_information26            in     varchar2  default null
  ,p_dei_information27            in     varchar2  default null
  ,p_dei_information28            in     varchar2  default null
  ,p_dei_information29            in     varchar2  default null
  ,p_dei_information30            in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_action_mode                  in     varchar2  default null
  ,p_object_version_number        in out    nocopy number
  ,p_return_status                   out    nocopy varchar2
);



--------------------------------------------------------------------------
--------------------------get_review_data_from_tt-------------------------
------This method retrieve the documents of records data from the --------
------transaction table---------------------------------------------------
--------------------------------------------------------------------------


PROCEDURE get_review_data_from_tt(
          p_transaction_step_id in number
         ,p_dor_rec out nocopy HR_DOCUMENT_EXTRA_INFO%rowtype);


--------------------------------------------------------------------------
--------------------------get_transaction_values--------------------------
------This method retrieve the documents of records data from the --------
------transaction table and return back the values.-----------------------
--------------------------------------------------------------------------

PROCEDURE get_transaction_values(
   p_transaction_step_id          in              varchar2
  ,p_person_id                    out  nocopy     varchar2
  ,p_document_extra_info_id       out  nocopy     varchar2
  ,p_document_type_id             out  nocopy     varchar2
  ,p_date_from                    out  nocopy     varchar2
  ,p_date_to                      out  nocopy     varchar2
  ,p_document_number              out  nocopy     varchar2
  ,p_issued_by                    out  nocopy     varchar2
  ,p_issued_at                    out  nocopy     varchar2
  ,p_issued_date                  out  nocopy     varchar2
  ,p_issuing_authority            out  nocopy     varchar2
  ,p_verified_by                  out  nocopy     varchar2
  ,p_verified_date                out  nocopy     varchar2
  ,p_related_object_name          out  nocopy     varchar2
  ,p_related_object_id_col        out  nocopy     varchar2
  ,p_related_object_id            out  nocopy     varchar2
  ,p_dei_attribute_category       out  nocopy     varchar2
  ,p_dei_attribute1               out  nocopy     varchar2
  ,p_dei_attribute2               out  nocopy     varchar2
  ,p_dei_attribute3               out  nocopy     varchar2
  ,p_dei_attribute4               out  nocopy     varchar2
  ,p_dei_attribute5               out  nocopy     varchar2
  ,p_dei_attribute6               out  nocopy     varchar2
  ,p_dei_attribute7               out  nocopy     varchar2
  ,p_dei_attribute8               out  nocopy     varchar2
  ,p_dei_attribute9               out  nocopy     varchar2
  ,p_dei_attribute10              out  nocopy     varchar2
  ,p_dei_attribute11              out  nocopy     varchar2
  ,p_dei_attribute12              out  nocopy     varchar2
  ,p_dei_attribute13              out  nocopy     varchar2
  ,p_dei_attribute14              out  nocopy     varchar2
  ,p_dei_attribute15              out  nocopy     varchar2
  ,p_dei_attribute16              out  nocopy     varchar2
  ,p_dei_attribute17              out  nocopy     varchar2
  ,p_dei_attribute18              out  nocopy     varchar2
  ,p_dei_attribute19              out  nocopy     varchar2
  ,p_dei_attribute20              out  nocopy     varchar2
  ,p_dei_attribute21              out  nocopy     varchar2
  ,p_dei_attribute22              out  nocopy     varchar2
  ,p_dei_attribute23              out  nocopy     varchar2
  ,p_dei_attribute24              out  nocopy     varchar2
  ,p_dei_attribute25              out  nocopy     varchar2
  ,p_dei_attribute26              out  nocopy     varchar2
  ,p_dei_attribute27              out  nocopy     varchar2
  ,p_dei_attribute28              out  nocopy     varchar2
  ,p_dei_attribute29              out  nocopy     varchar2
  ,p_dei_attribute30              out  nocopy     varchar2
  ,p_dei_information_category     out  nocopy     varchar2
  ,p_dei_information1             out  nocopy     varchar2
  ,p_dei_information2             out  nocopy     varchar2
  ,p_dei_information3             out  nocopy     varchar2
  ,p_dei_information4             out  nocopy     varchar2
  ,p_dei_information5             out  nocopy     varchar2
  ,p_dei_information6             out  nocopy     varchar2
  ,p_dei_information7             out  nocopy     varchar2
  ,p_dei_information8             out  nocopy     varchar2
  ,p_dei_information9             out  nocopy     varchar2
  ,p_dei_information10            out  nocopy     varchar2
  ,p_dei_information11            out  nocopy     varchar2
  ,p_dei_information12            out  nocopy     varchar2
  ,p_dei_information13            out  nocopy     varchar2
  ,p_dei_information14            out  nocopy     varchar2
  ,p_dei_information15            out  nocopy     varchar2
  ,p_dei_information16            out  nocopy     varchar2
  ,p_dei_information17            out  nocopy     varchar2
  ,p_dei_information18            out  nocopy     varchar2
  ,p_dei_information19            out  nocopy     varchar2
  ,p_dei_information20            out  nocopy     varchar2
  ,p_dei_information21            out  nocopy     varchar2
  ,p_dei_information22            out  nocopy     varchar2
  ,p_dei_information23            out  nocopy     varchar2
  ,p_dei_information24            out  nocopy     varchar2
  ,p_dei_information25            out  nocopy     varchar2
  ,p_dei_information26            out  nocopy     varchar2
  ,p_dei_information27            out  nocopy     varchar2
  ,p_dei_information28            out  nocopy     varchar2
  ,p_dei_information29            out  nocopy     varchar2
  ,p_dei_information30            out  nocopy     varchar2
  ,p_request_id                   out  nocopy     varchar2
  ,p_program_application_id       out  nocopy     varchar2
  ,p_program_id                   out  nocopy     varchar2
  ,p_program_update_date          out  nocopy     varchar2
  ,p_object_version_number        out  nocopy     varchar2
  ,p_return_status                out  nocopy     varchar2
  ,p_document_type                out  nocopy     varchar2
  ,p_category_name                out  nocopy     varchar2
  ,p_sub_category_name            out  nocopy     varchar2
  ,p_country_name                 out  nocopy     varchar2
  ,p_system_doc_type              out  nocopy     varchar2
  );

PROCEDURE save_attachments(
   p_transaction_id              in               number
  ,p_document_extra_info_id      in               number
  ,p_flip_flag                   in               varchar2
  ,p_return_status               out nocopy       varchar2);


/*===========================================================================
This procedure calls the fnd api to update the attachments
===========================================================================*/

procedure update_attachment
          (p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_rowid              in varchar2 );


procedure delete_transaction(p_transaction_id in number);


function isUpdateAllowed(p_transaction_id in number default null,
                         p_transaction_status in varchar2 default null,
                         p_document_extra_info_id in number default null) return varchar2;

function isDeleteAllowed(p_transaction_id in number,
                         p_transaction_status in varchar2) return varchar2;

function isAttachAllowed(p_transaction_id in number,
                         p_transaction_status in varchar2) return varchar2;

function isTxnOwner(p_transaction_id in number,
                    p_person_id in number) return boolean;

function getActionMode(p_transaction_id in number) return varchar2;

function get_transaction_id(p_transaction_step_id in number) return number;



END HR_DOR_REVIEW_SS;


/
