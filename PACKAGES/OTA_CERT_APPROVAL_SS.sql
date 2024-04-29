--------------------------------------------------------
--  DDL for Package OTA_CERT_APPROVAL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_APPROVAL_SS" AUTHID CURRENT_USER AS
 /* $Header: otcrtrev.pkh 120.1 2005/07/11 05:49 dbatra noship $*/


 -- Global variables
   g_date_format varchar2(10) := 'RRRR/MM/DD';

  procedure save_cert_enroll_detail(
  p_login_person_id               in   number,
  p_item_type                     in     varchar2,
  p_item_key                      in     varchar2,
  p_activity_id                   in     number,
  p_certification_id             in varchar2,
  p_person_id                    in number,
  p_certification_status_code    in varchar2 default null,
  p_completion_date              in varchar2             default null,
  p_UNENROLLMENT_DATE            in varchar2             default null,
  p_EXPIRATION_DATE              in varchar2             default null,
  p_EARLIEST_ENROLL_DATE         in varchar2            default null,
  p_IS_HISTORY_FLAG              in varchar2 default 'N',
  p_business_group_id            in varchar2 default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_from                         in varchar2,
  p_error_message                 OUT NOCOPY    VARCHAR2
  );





PROCEDURE get_add_enr_dtl_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
  -- ,p_trans_rec_count                 out nocopy number
 --  ,p_person_id                       out nocopy number
   ,p_add_enroll_detail_data          out nocopy varchar2
);



procedure get_add_enr_dtl_data_from_tt
   (p_transaction_step_id             in  number
   ,p_add_enroll_detail_data          out nocopy varchar2
);

PROCEDURE get_review_data
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_review_data                     out nocopy varchar2
);

procedure get_review_data
   (p_transaction_step_id             in  number
   ,p_review_data                     out nocopy varchar2
);


procedure process_api
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
  p_message out nocopy varchar2) ;





Procedure APPROVED ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout	OUT nocopy VARCHAR2 );



--  ---------------------------------------------------------------------------
--  |----------------------< get_approval_req >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE get_approval_req  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 );


end OTA_CERT_APPROVAL_SS;


 

/
