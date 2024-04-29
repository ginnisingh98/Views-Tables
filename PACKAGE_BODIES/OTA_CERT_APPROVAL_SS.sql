--------------------------------------------------------
--  DDL for Package Body OTA_CERT_APPROVAL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERT_APPROVAL_SS" AS
 /* $Header: otcrtrev.pkb 120.4 2005/10/04 02:31 dbatra noship $*/

   g_package      varchar2(30)   := 'OTA_CERT_APPROVAL_SS';

     --  ---------------------------------------------------------------------------
--  |----------------------< get_approval_req >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE get_approval_req  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )
IS

l_item_value varchar2(200);
l_ntf_url varchar2(4000);

l_cert_id number(15);

Cursor get_cert_details (crs_certification_id number)is
select ctl.name, ctb.initial_completion_date
from ota_Certifications_tl ctl , ota_Certifications_b ctb
where ctl.certification_id = ctb.certification_id
and ctl.Language= USERENV('LANG')
and ctl.certification_id =crs_certification_id;

l_certification_name ota_certifications_tl.name%type;
l_comp_date varchar2(100);



BEGIN
hr_utility.set_location('ENTERING get_approval_req', 10);
	IF (funcmode='RUN') THEN




     l_item_value := wf_engine.getItemAttrText(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'HR_RUNTIME_APPROVAL_REQ_FLAG');



              if l_item_value = 'NO' then

        /*      l_cert_id := wf_engine.getItemAttrNumber(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'BOOKING_ID');

                open get_cert_details(l_cert_id);
                fetch get_cert_details into l_certification_name,l_comp_date;
                close get_cert_details;

                wf_engine.setItemAttrText(itemtype,itemkey,'OTA_ACTIVITY_VERSION_NAME',l_certification_name);
                wf_engine.setItemAttrText(itemtype,itemkey,'OTA_COURSE_START_DATE',l_comp_date);

*/

                   resultout:='COMPLETE:N';


               else

                   resultout:='COMPLETE:Y';


              end if;
        hr_utility.trace('l_resultout' || resultout);

                 RETURN;
	END IF; --RUN

	IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;
Exception

	when others then
hr_utility.set_location('ENTERING exception get_approval_req', 10);



end get_approval_req;


  procedure save_cert_enroll_detail(
  p_login_person_id               in   number,
  p_item_type                     in     varchar2,
  p_item_key                      in     varchar2,
  p_activity_id                   in     number,
  p_certification_id             in varchar2,
  p_person_id                    in number,
  p_certification_status_code    in varchar2,
  p_completion_date              in varchar2             default null,
  p_UNENROLLMENT_DATE            in varchar2             default null,
  p_EXPIRATION_DATE              in varchar2             default null,
  p_EARLIEST_ENROLL_DATE         in varchar2            default null,
  p_IS_HISTORY_FLAG              in varchar2,
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
  )
  as

  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table          hr_transaction_ss.transaction_table;
  l_review_item_name           varchar2(50);
  l_message_number             VARCHAR2(10);
  l_result                     varchar2(100) default null;
  l_old_transaction_step_id    number;
  l_old_object_version_number  number;

  begin

  -- First, check if transaction id exists or not
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);

  --
  IF l_transaction_id is null THEN
     -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           ,p_login_person_id => p_login_person_id
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
  END IF;

  --
  -- Delete transaction step if exist
  --

  if (hr_transaction_api.transaction_step_exist  (p_item_type => p_item_type
			     			 ,p_item_key => p_item_key
			     			 ,p_activity_id => p_activity_id) )  then

      hr_transaction_api.get_transaction_step_info(p_item_type             => p_item_type
						  ,p_item_key              => p_item_key
 						  ,p_activity_id           => p_activity_id
 						  ,p_transaction_step_id   => l_old_transaction_step_id
 						  ,p_object_version_number => l_old_object_version_number);


      hr_transaction_api.delete_transaction_step(p_validate                    => false
        					,p_transaction_step_id         => l_old_transaction_step_id
        					,p_person_id                   => p_login_person_id
       						,p_object_version_number       => l_old_object_version_number);

  end if;

  --
  -- Create a transaction step
  --
  hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || '.PROCESS_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_activity_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);


  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_CERTIFICATIONID';
  l_transaction_table(l_count).param_value := p_certification_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 /* l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CERTIFICATIONCODE';
  l_transaction_table(l_count).param_value := p_certification_status_code;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
*/

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HISTORYFLAG';
  l_transaction_table(l_count).param_value := nvl(p_is_history_flag, 'N');
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_activity_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSONID';
  l_transaction_table(l_count).param_value := p_person_Id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESSGROUPID';
  l_transaction_table(l_count).param_value := ota_general.get_business_group_id();
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';



  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FROM';
  l_transaction_table(l_count).param_value := p_from;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTECATEGORY';
  l_transaction_table(l_count).param_value := p_attribute_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
  l_transaction_table(l_count).param_value := p_attribute1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
  l_transaction_table(l_count).param_value := p_attribute2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
  l_transaction_table(l_count).param_value := p_attribute3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
  l_transaction_table(l_count).param_value := p_attribute4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
  l_transaction_table(l_count).param_value := p_attribute5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
  l_transaction_table(l_count).param_value := p_attribute6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
  l_transaction_table(l_count).param_value := p_attribute7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
  l_transaction_table(l_count).param_value := p_attribute8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
  l_transaction_table(l_count).param_value := p_attribute9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
  l_transaction_table(l_count).param_value := p_attribute10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
  l_transaction_table(l_count).param_value := p_attribute11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
  l_transaction_table(l_count).param_value := p_attribute12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
  l_transaction_table(l_count).param_value := p_attribute13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
  l_transaction_table(l_count).param_value := p_attribute14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
  l_transaction_table(l_count).param_value := p_attribute15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
  l_transaction_table(l_count).param_value := p_attribute16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
  l_transaction_table(l_count).param_value := p_attribute17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
  l_transaction_table(l_count).param_value := p_attribute18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
  l_transaction_table(l_count).param_value := p_attribute19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
  l_transaction_table(l_count).param_value := p_attribute20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COMPLETION_DATE';
  l_transaction_table(l_count).param_value := p_completion_date;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_UNENROLLMENTDATE';
  l_transaction_table(l_count).param_value := p_unenrollment_date;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EXPIRATIONDATE';
  l_transaction_table(l_count).param_value := p_expiration_date;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EARLIESTENROLLDATE';
  l_transaction_table(l_count).param_value := p_earliest_enroll_date;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LOGINPERSONID';
  l_transaction_table(l_count).param_value := p_login_person_Id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => p_item_type
      ,p_item_key   => p_item_key
      ,p_name   => 'OTA_TRANSACTION_STEP_ID');

  WF_ENGINE.setitemattrnumber(p_item_type,
                              p_item_key,
                              'OTA_TRANSACTION_STEP_ID',
                              l_transaction_step_id);


  If p_from='REVIEW' Then
      hr_approval_wf.create_item_attrib_if_notexist
		      (p_item_type  => p_item_type
		      ,p_item_key   => p_item_key
		      ,p_name       => 'OTA_CERTIFICATION_ID');

      WF_ENGINE.setitemattrnumber(p_item_type,
  			          p_item_key,
			          'OTA_CERTIFICATION_ID',
				  p_certification_id);

-- bug 4146681
WF_ENGINE.setitemattrtext(p_item_type,
                              p_item_key,
                              'HR_RESTRICT_EDIT_ATTR',
                              'Y');
--bug 4146681

  End If;

  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_activity_id
                ,p_login_person_id => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API'
                ,p_transaction_data => l_transaction_table);


  EXCEPTION
  WHEN hr_utility.hr_error THEN
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_message.provide_error;
         l_message_number := hr_message.last_message_number;
         IF l_message_number = 'APP-7165' OR
            l_message_number = 'APP-7155' THEN
   --populate the p_error_message out variable
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name => 'Page',
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_UPDATE_NOT_ALLOWED');
         ELSE
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
         END IF;
  WHEN OTHERS THEN
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

 end save_cert_enroll_detail;




PROCEDURE get_add_enr_dtl_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
  -- ,p_trans_rec_count                 out nocopy number
  -- ,p_person_id                       out nocopy number
   ,p_add_enroll_detail_data          out nocopy varchar2
) is



   l_add_enroll_detail_data           varchar2(4000);
l_trans_step_id number;



 BEGIN

        l_trans_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');


              get_add_enr_dtl_data_from_tt(
                 p_transaction_step_id            => l_trans_step_id
--                 p_transaction_step_id            => l_trans_step_id
                ,p_add_enroll_detail_data         => l_add_enroll_detail_data);


              p_add_enroll_detail_data := l_add_enroll_detail_data;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_add_enr_dtl_data_from_tt;


procedure get_add_enr_dtl_data_from_tt
   (p_transaction_step_id             in  number
   ,p_add_enroll_detail_data          out nocopy varchar2
)
is


l_certification_id     ota_cert_enrollments.certification_id%type;

l_attribute_category  ota_cert_enrollments.attribute_category%type;
l_attribute1  ota_cert_enrollments.attribute1%type;
l_attribute2  ota_cert_enrollments.attribute1%type;
l_attribute3 ota_cert_enrollments.attribute1%type;
l_attribute4 ota_cert_enrollments.attribute1%type;
l_attribute5 ota_cert_enrollments.attribute1%type;
l_attribute6 ota_cert_enrollments.attribute1%type;
l_attribute7 ota_cert_enrollments.attribute1%type;
l_attribute8 ota_cert_enrollments.attribute1%type;
l_attribute9 ota_cert_enrollments.attribute1%type;
l_attribute10 ota_cert_enrollments.attribute1%type;
l_attribute11 ota_cert_enrollments.attribute1%type;
l_attribute12 ota_cert_enrollments.attribute1%type;
l_attribute13  ota_cert_enrollments.attribute1%type;
l_attribute14 ota_cert_enrollments.attribute1%type;
l_attribute15 ota_cert_enrollments.attribute1%type;
l_attribute16 ota_cert_enrollments.attribute1%type;
l_attribute17 ota_cert_enrollments.attribute1%type;
l_attribute18 ota_cert_enrollments.attribute1%type;
l_attribute19 ota_cert_enrollments.attribute1%type;
l_attribute20 ota_cert_enrollments.attribute1%type;

begin


  l_certification_id := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CERTIFICATIONID');

   l_attribute_category := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTECATEGORY');
 l_attribute1 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE1');
 l_attribute2 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE2');
 l_attribute3 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE3');
 l_attribute4 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE4');
 l_attribute5 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE5');
 l_attribute6 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE6');
 l_attribute7 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE7');
 l_attribute8 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE8');
 l_attribute9 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE9');
 l_attribute10 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE10');
 l_attribute11 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE11');
 l_attribute12 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE12');
 l_attribute13 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE13');
 l_attribute14 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE14');
 l_attribute15 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE15');
 l_attribute16 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE16');
 l_attribute17 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE17');
 l_attribute18 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE18');
 l_attribute19 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE19');
 l_attribute20 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE20');

--
-- Now string all the retreived items into p_add_enroll_detail_data

--

p_add_enroll_detail_data := nvl(l_certification_id,0)
                           ||'^'||nvl(l_attribute_category,'null')
                           ||'^'||nvl(l_attribute1,'null')
                           ||'^'||nvl(l_attribute2,'null')
                           ||'^'||nvl(l_attribute3,'null')
                           ||'^'||nvl(l_attribute4,'null')
                           ||'^'||nvl(l_attribute5,'null')
                           ||'^'||nvl(l_attribute6,'null')
                           ||'^'||nvl(l_attribute7,'null')
                           ||'^'||nvl(l_attribute8,'null')
                           ||'^'||nvl(l_attribute9,'null')
                           ||'^'||nvl(l_attribute10,'null')
                           ||'^'||nvl(l_attribute11,'null')
                           ||'^'||nvl(l_attribute12,'null')
                           ||'^'||nvl(l_attribute13,'null')
                           ||'^'||nvl(l_attribute14,'null')
                           ||'^'||nvl(l_attribute15,'null')
                           ||'^'||nvl(l_attribute16,'null')
                           ||'^'||nvl(l_attribute17,'null')
                           ||'^'||nvl(l_attribute18,'null')
                           ||'^'||nvl(l_attribute19,'null')
                           ||'^'||nvl(l_attribute20,'null');


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_add_enr_dtl_data_from_tt;





PROCEDURE get_review_data
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_review_data                     out nocopy varchar2
) is



   l_review_data                      varchar2(4000);
   l_trans_step_id number;


 BEGIN


--added new
l_trans_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');
    get_review_data(
                 p_transaction_step_id            => l_trans_step_id
                ,p_review_data                    => l_review_data);


              p_review_data := l_review_data;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_review_data;



procedure get_review_data
   (p_transaction_step_id             in  number
   ,p_review_data                     out nocopy varchar2
)
is

 l_name ota_certifications_vl.name%type;
 l_description ota_certifications_vl.description%type;
 l_objectives ota_certifications_vl.objectives%type;
 l_purpose ota_certifications_vl.purpose%type;
 l_init_comp_date ota_certifications_vl.initial_completion_date%type;
 l_init_comp_dur  varchar2(100);
 l_renewal_dur    varchar2(100);
 l_notif_days varchar2(100);
 l_initial_comments ota_certifications_vl.initial_period_comments%type;
 l_certification_id     ota_cert_enrollments.certification_id%type;

/* cursor get_certification_info(crs_Certification_id number)
 is
 Select name,description,objectives,purpose,
 to_char(initial_completion_date, fnd_profile.value('ICX_DATE_FORMAT_MASK')),
 initial_completion_duration || initial_compl_duration_units,
 renewal_duration || renewal_duration_units,
 notify_days_before_expire,initial_period_comments
 from ota_certifications_vl
 where certification_id = crs_certification_id;
 */

begin


  l_certification_id := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CERTIFICATIONID');

/*
open get_certification_info(l_certification_id);
fetch get_certification_info into l_name,l_description,
l_objectives,l_purpose,l_init_comp_date,
l_init_comp_dur,l_renewal_dur,l_notif_days,l_initial_comments;
close get_certification_info;
*/

  p_review_data := nvl(l_certification_id,'0') ;
  /*||'^'||nvl(l_name,'null')
                           ||'^'||nvl(l_description,'null')
                           ||'^'||nvl(l_objectives,'null')
                           ||'^'||nvl(l_purpose,'null')
                           ||'^'||nvl(l_init_comp_date,'null')
                           ||'^'||nvl(l_init_comp_dur,'null')
                           ||'^'||nvl(l_renewal_dur,'null')
                           ||'^'||nvl(l_notif_days,'null')
                           ||'^'||nvl(l_initial_comments,'null');*/



EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_review_data;

procedure create_cert_enrollment_tt
(p_validate IN BOOLEAN, p_transaction_step_id IN NUMBER)
  is

l_item_type                HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE;
 l_item_key                 HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE;
 l_activity_id              HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;
l_cert_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date := trunc(sysdate);

l_certification_id     ota_cert_enrollments.certification_id%type;
l_certification_status_code ota_cert_enrollments.certification_status_code%type;
l_IS_HISTORY_FLAG  ota_cert_enrollments.is_history_flag%type;
l_person_id  ota_cert_enrollments.person_id%type;
--l_contact_id
l_completion_date  varchar2(100);
l_business_group_id  ota_cert_enrollments.business_group_id%type;
l_UNENROLLMENT_DATE  varchar2(100);
l_EXPIRATION_DATE   varchar2(100);
l_EARLIEST_ENROLL_DATE  varchar2(100);
l_attribute_category  ota_cert_enrollments.attribute_category%type;
l_attribute1  ota_cert_enrollments.attribute1%type;
l_attribute2  ota_cert_enrollments.attribute1%type;
l_attribute3 ota_cert_enrollments.attribute1%type;
l_attribute4 ota_cert_enrollments.attribute1%type;
l_attribute5 ota_cert_enrollments.attribute1%type;
l_attribute6 ota_cert_enrollments.attribute1%type;
l_attribute7 ota_cert_enrollments.attribute1%type;
l_attribute8 ota_cert_enrollments.attribute1%type;
l_attribute9 ota_cert_enrollments.attribute1%type;
l_attribute10 ota_cert_enrollments.attribute1%type;
l_attribute11 ota_cert_enrollments.attribute1%type;
l_attribute12 ota_cert_enrollments.attribute1%type;
l_attribute13  ota_cert_enrollments.attribute1%type;
l_attribute14 ota_cert_enrollments.attribute1%type;
l_attribute15 ota_cert_enrollments.attribute1%type;
l_attribute16 ota_cert_enrollments.attribute1%type;
l_attribute17 ota_cert_enrollments.attribute1%type;
l_attribute18 ota_cert_enrollments.attribute1%type;
l_attribute19 ota_cert_enrollments.attribute1%type;
l_attribute20 ota_cert_enrollments.attribute1%type;

Cursor get_cert_name (crs_certification_id number)is
select ctl.name
from ota_Certifications_tl ctl , ota_Certifications_b ctb
where ctl.certification_id = ctb.certification_id
and ctl.Language= USERENV('LANG')
and ctl.certification_id =crs_certification_id;

l_certification_name ota_certifications_tl.name%type;

l_approval_req_flag varchar2(1);

begin
-- bug 4636199
if p_validate then
l_approval_req_flag := 'N';
else
l_approval_req_flag :='A';

end if;

  l_certification_id := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CERTIFICATIONID');
 /*l_certification_status_code := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CERTIFICATIONCODE');*/
 l_IS_HISTORY_FLAG := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_HISTORYFLAG');
 l_person_id := hr_transaction_api.get_Number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_PERSONID');
 l_business_group_id := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_BUSINESSGROUPID');
 l_attribute_category := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTECATEGORY');
 l_attribute1 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE1');
 l_attribute2 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE2');
 l_attribute3 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE3');
 l_attribute4 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE4');
 l_attribute5 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE5');
 l_attribute6 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE6');
 l_attribute7 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE7');
 l_attribute8 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE8');
 l_attribute9 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE9');
 l_attribute10 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE10');
 l_attribute11 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE11');
 l_attribute12 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE12');
 l_attribute13 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE13');
 l_attribute14 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE14');
 l_attribute15 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE15');
 l_attribute16 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE16');
 l_attribute17 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE17');
 l_attribute18 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE18');
 l_attribute19 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE19');
 l_attribute20 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE20');
 l_completion_date := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_COMPLETIONDATE');
l_UNENROLLMENT_DATE := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_UNENROLLMENTDATE');

l_EXPIRATION_DATE := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_EXPIRATIONDATE');
l_EARLIEST_ENROLL_DATE := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_EARLIESTENROLLDATE');

hr_utility.trace ('Before create ' ||'10');

  ota_cert_enrollment_api.subscribe_to_certification
  (
  -- p_effective_date                 =>   l_effective_date
 --  p_validate                       => p_validate,
  p_certification_id               =>   l_certification_id
  ,p_certification_status_code      =>   l_certification_status_code
  ,p_IS_HISTORY_FLAG                =>   l_IS_HISTORY_FLAG
  ,p_person_id                      =>   l_person_id
,p_approval_flag => l_approval_req_flag
  ,p_completion_date                =>   to_date(l_completion_date,g_date_format)
  ,p_business_group_id              =>   l_business_group_id
  ,p_UNENROLLMENT_DATE              =>   to_date(l_UNENROLLMENT_DATE,g_date_format)
  ,p_EXPIRATION_DATE                =>   to_date(l_EXPIRATION_DATE,g_date_format)
  ,p_EARLIEST_ENROLL_DATE           =>   to_date(l_EARLIEST_ENROLL_DATE,g_date_format)
  ,p_attribute_category             =>   l_attribute_category
  ,p_attribute1                     =>   l_attribute1
  ,p_attribute2                     =>   l_attribute2
  ,p_attribute3                     =>   l_attribute3
  ,p_attribute4                     =>   l_attribute4
  ,p_attribute5                     =>   l_attribute5
  ,p_attribute6                     =>   l_attribute6
  ,p_attribute7                     =>   l_attribute7
  ,p_attribute8                     =>   l_attribute8
  ,p_attribute9                     =>   l_attribute9
  ,p_attribute10                    =>   l_attribute10
  ,p_attribute11                    =>   l_attribute11
  ,p_attribute12                    =>   l_attribute12
  ,p_attribute13                    =>   l_attribute13
  ,p_attribute14                    =>   l_attribute14
  ,p_attribute15                    =>   l_attribute15
  ,p_attribute16                    =>   l_attribute16
  ,p_attribute17                    =>   l_attribute17
  ,p_attribute18                    =>   l_attribute18
  ,p_attribute19                    =>   l_attribute19
  ,p_attribute20                    =>   l_attribute20
  ,p_cert_enrollment_id             =>   l_cert_enrollment_id
,p_enroll_from          =>   'LRNR');

hr_utility.trace ('AFTER create ' ||'10');
--Put certification enrollment id in wf attributes
--req during update
  hr_transaction_api.get_transaction_step_info
         (p_transaction_step_id  => p_transaction_step_id
         ,p_item_type            => l_item_type
         ,p_item_key             => l_item_key
         ,p_activity_id          => l_activity_id);

wf_engine.setItemAttrNumber(l_item_type, l_item_key, 'EVENT_ID',l_cert_enrollment_id );

--set certification name
--moved to java layer for approval mode off convenience
/*
open get_cert_name(l_certification_id);
fetch get_cert_name into l_certification_name;
close get_cert_name;

wf_engine.setItemAttrText(l_item_type, l_item_key, 'OTA_ACTIVITY_VERSION_NAME',l_certification_name);
*/
hr_utility.trace ('AFTER EVENT_ID ' ||'10');
end create_cert_enrollment_tt;




procedure update_cert_enrollment_tt
(p_validate IN BOOLEAN,
p_transaction_step_id IN NUMBER,
p_trans_mode in varchar2 default null,
p_cert_enroll_id in number default null,
itemtype     in varchar2 default null,
  itemkey      in varchar2 default null)
  is

l_cert_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date := trunc(sysdate);
  l_certification_status varchar2(100);

l_certification_id     ota_cert_enrollments.certification_id%type;
l_item_type                HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE := itemtype;
 l_item_key                 HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE := itemkey;
 l_activity_id              HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;

l_IS_HISTORY_FLAG  ota_cert_enrollments.is_history_flag%type;
l_person_id  ota_cert_enrollments.person_id%type;
l_certification_status_code varchar2(100);
l_completion_date  varchar2(100);
l_business_group_id  ota_cert_enrollments.business_group_id%type;
l_UNENROLLMENT_DATE  varchar2(100);
l_EXPIRATION_DATE   varchar2(100);
l_EARLIEST_ENROLL_DATE  varchar2(100);
l_attribute_category  ota_cert_enrollments.attribute_category%type;
l_attribute1  ota_cert_enrollments.attribute1%type;
l_attribute2  ota_cert_enrollments.attribute1%type;
l_attribute3 ota_cert_enrollments.attribute1%type;
l_attribute4 ota_cert_enrollments.attribute1%type;
l_attribute5 ota_cert_enrollments.attribute1%type;
l_attribute6 ota_cert_enrollments.attribute1%type;
l_attribute7 ota_cert_enrollments.attribute1%type;
l_attribute8 ota_cert_enrollments.attribute1%type;
l_attribute9 ota_cert_enrollments.attribute1%type;
l_attribute10 ota_cert_enrollments.attribute1%type;
l_attribute11 ota_cert_enrollments.attribute1%type;
l_attribute12 ota_cert_enrollments.attribute1%type;
l_attribute13  ota_cert_enrollments.attribute1%type;
l_attribute14 ota_cert_enrollments.attribute1%type;
l_attribute15 ota_cert_enrollments.attribute1%type;
l_attribute16 ota_cert_enrollments.attribute1%type;
l_attribute17 ota_cert_enrollments.attribute1%type;
l_attribute18 ota_cert_enrollments.attribute1%type;
l_attribute19 ota_cert_enrollments.attribute1%type;
l_attribute20 ota_cert_enrollments.attribute1%type;




Cursor get_cert_info(crs_Cert_enrollment_id number)
is
select certification_id, object_version_number
from ota_cert_enrollments
where cert_enrollment_id = crs_cert_enrollment_id;

begin

if l_item_key is null then
 hr_transaction_api.get_transaction_step_info
         (p_transaction_step_id  => p_transaction_step_id
         ,p_item_type            => l_item_type
         ,p_item_key             => l_item_key
         ,p_activity_id          => l_activity_id);
end if;

 if p_cert_enroll_id is null then
  l_Cert_enrollment_id := wf_engine.GetItemAttrNumber(itemtype => l_item_type
                                         ,itemkey  => l_item_key
                                            ,aname    => 'EVENT_ID');

 else
    l_Cert_enrollment_id := p_cert_enroll_id;
 end if;

  open get_cert_info(l_Cert_enrollment_id);
  fetch get_cert_info into l_certification_id,l_object_version_number;
  close get_cert_info;

    if p_trans_mode is not null then
    -- implies approver rejected
        l_certification_status := 'REJECTED';
    else
        --if p_cert_enroll_id is null then
        -- enrollment is approved
            l_certification_status := 'ENROLLED';
       /* else
        -- reenrolling into a certification
            l_certification_status := 'AWAITING_APPROVAL';
        end if;*/
    end if;

 if l_certification_status = 'REJECTED' then
  ota_cert_enrollment_api.update_cert_enrollment
  (
   p_effective_date                 =>   l_effective_date
  ,p_validate                       =>      p_validate
  ,p_certification_id               =>   l_certification_id
  ,p_certification_status_code      =>   l_certification_status
  ,p_cert_enrollment_id             =>   l_cert_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  );
 else
 -- call subscribe to create child objects as well

 --really req or not ??

 l_IS_HISTORY_FLAG := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_HISTORYFLAG');
 l_person_id := hr_transaction_api.get_Number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_PERSONID');
 l_business_group_id := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_BUSINESSGROUPID');
 l_attribute_category := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTECATEGORY');
 l_attribute1 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE1');
 l_attribute2 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE2');
 l_attribute3 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE3');
 l_attribute4 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE4');
 l_attribute5 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE5');
 l_attribute6 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE6');
 l_attribute7 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE7');
 l_attribute8 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE8');
 l_attribute9 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE9');
 l_attribute10 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE10');
 l_attribute11 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE11');
 l_attribute12 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE12');
 l_attribute13 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE13');
 l_attribute14 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE14');
 l_attribute15 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE15');
 l_attribute16 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE16');
 l_attribute17 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE17');
 l_attribute18 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE18');
 l_attribute19 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE19');
 l_attribute20 := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ATTRIBUTE20');
 l_completion_date := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_COMPLETIONDATE');
l_UNENROLLMENT_DATE := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_UNENROLLMENTDATE');

l_EXPIRATION_DATE := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_EXPIRATIONDATE');
l_EARLIEST_ENROLL_DATE := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_EARLIESTENROLLDATE');




     ota_cert_enrollment_api.subscribe_to_certification(
      p_validate => p_validate
     ,p_certification_id => l_certification_id
     ,p_person_id => l_person_id
    -- ,p_contact_id => p_contact_id
     ,p_business_group_id => l_business_group_id
     ,p_approval_flag => 'S'
     ,p_completion_date                =>   to_date(l_completion_date,g_date_format)
     ,p_UNENROLLMENT_DATE              =>   to_date(l_UNENROLLMENT_DATE,g_date_format)
     ,p_EXPIRATION_DATE                =>   to_date(l_EXPIRATION_DATE,g_date_format)
     ,p_EARLIEST_ENROLL_DATE           =>   to_date(l_EARLIEST_ENROLL_DATE,g_date_format)
     ,p_is_history_flag              => l_is_history_flag
     ,p_attribute_category           => l_attribute_category
     ,p_attribute1                     =>   l_attribute1
  ,p_attribute2                     =>   l_attribute2
  ,p_attribute3                     =>   l_attribute3
  ,p_attribute4                     =>   l_attribute4
  ,p_attribute5                     =>   l_attribute5
  ,p_attribute6                     =>   l_attribute6
  ,p_attribute7                     =>   l_attribute7
  ,p_attribute8                     =>   l_attribute8
  ,p_attribute9                     =>   l_attribute9
  ,p_attribute10                    =>   l_attribute10
  ,p_attribute11                    =>   l_attribute11
  ,p_attribute12                    =>   l_attribute12
  ,p_attribute13                    =>   l_attribute13
  ,p_attribute14                    =>   l_attribute14
  ,p_attribute15                    =>   l_attribute15
  ,p_attribute16                    =>   l_attribute16
  ,p_attribute17                    =>   l_attribute17
  ,p_attribute18                    =>   l_attribute18
  ,p_attribute19                    =>   l_attribute19
  ,p_attribute20                    =>   l_attribute20
     ,p_cert_enrollment_id => l_cert_enrollment_id
     ,p_certification_status_code => l_certification_status_code
     ,p_enroll_from          =>   'LRNR');


 end if;


end update_cert_enrollment_tt;



PROCEDURE process_api
        (p_validate IN BOOLEAN,p_transaction_step_id IN NUMBER
,p_effective_date in varchar2) IS

 l_from                        VARCHAR2(20);
 l_certification_id     varchar2(20);
 l_person_id number(15);
 l_cert_enroll_id number(15) :=0;

 /*cursor get_exist_cert_enroll
 is
 Select cert_enrollment_id
 from ota_cert_enrollments
 where certification_id = l_certification_id
 and person_id = l_person_id
 and business_group_id = ota_general.get_business_group_id();*/

begin

 l_from  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_FROM');


/*l_certification_id := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CERTIFICATIONID');

l_person_id := hr_transaction_api.get_Number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_PERSONID'); */

  If (l_from = 'REVIEW') Then

    -- establish Savepoint
         SAVEPOINT validate_enrollment;


        create_cert_enrollment_tt(p_validate => p_validate, p_transaction_step_id => p_transaction_step_id);

        if (p_validate = true) then
                 rollback to validate_enrollment;
          else
-- update p_from in transaction table
                    update hr_api_transaction_values
                    set varchar2_value = 'APPROVE'
                    where transaction_step_id = p_transaction_step_id
                    and name = 'P_FROM';
        end if;

  ELSE -- on approval

   update_cert_enrollment_tt(p_validate => p_validate, p_transaction_step_id => p_transaction_step_id);
  end if;

        EXCEPTION

		WHEN OTHERS THEN
                      RAISE;

END process_api;



procedure create_enrollment
 (itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is

   l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
   l_trans_step_rows                  NUMBER  ;
   l_trans_step_id number;

begin

    l_trans_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');

  if ( funmode = 'RUN' ) then

       process_api (false,l_trans_step_id);
       result := 'COMPLETE:SUCCESS';

  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
  end if;

end create_enrollment;


procedure cancel_enrollment
 (itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is

  l_trans_step_id 	number;






begin

l_trans_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');

  if ( funmode = 'RUN' ) then

       update_cert_enrollment_tt(p_validate => false,
                            p_transaction_step_id => l_trans_step_id,
                                 p_trans_mode => 'CANCEL',
                                 itemtype => itemtype,
                                 itemkey  => itemkey);
       result := 'COMPLETE:SUCCESS';

  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
  end if;
end cancel_enrollment;


procedure validate_enrollment
 (p_item_type     in varchar2,
  p_item_key      in varchar2,
  p_message out nocopy varchar2) is

  l_transaction_step_id 	number;
begin

   l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');
   process_api(true,l_transaction_step_id);
   p_message := 'S' ;
EXCEPTION
    When OTHERS Then
         p_message := fnd_message.get();
         If p_message is NULL then
            p_message := substr(SQLERRM,11,(length(SQLERRM)-10));
         End If;

end validate_enrollment;


--
-- ------------------------------------------------------------------
--  PROCEDURE Approved
-- ------------------------------------------------------------------
--
Procedure Approved  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )  IS

BEGIN

	IF (funcmode='RUN') THEN
		wf_engine.setItemAttrText (itemtype => itemtype
			 	  ,itemkey  => itemkey
			  	  ,aname    => 'APPROVAL_RESULT'
			  	  ,avalue   => 'ACCEPTED');
                   resultout:='COMPLETE';
                 RETURN;
	END IF;

	IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;

END Approved;



end OTA_CERT_APPROVAL_SS;



/
