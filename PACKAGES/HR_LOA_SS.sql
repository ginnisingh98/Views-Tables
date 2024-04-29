--------------------------------------------------------
--  DDL for Package HR_LOA_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOA_SS" 
/* $Header: hrloawrs.pkh 120.0.12010000.4 2009/12/22 11:08:20 pthoonig ship $*/
AUTHID CURRENT_USER AS
   /*
  ||===========================================================================
  || PROCEDURE: create_person_absence
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_absence_api.create_person_absence()
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE create_person_absence
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date     default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     date     default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default null
  ,p_replacement_person_id         in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_period_of_incapacity_id       in     number   default null
  ,p_ssp1_issued                   in     varchar2 default 'N'
  ,p_maternity_id                  in     number   default null
  ,p_sickness_start_date           in     date     default null
  ,p_sickness_end_date             in     date     default null
  ,p_pregnancy_related_illness     in     varchar2 default 'N'
  ,p_reason_for_notification_dela  in     varchar2 default null
  ,p_accept_late_notification_fla  in     varchar2 default 'N'
  ,p_linked_absence_id             in     number   default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy   number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  );


  /*
  ||===========================================================================
  || PROCEDURE: update_person_absence
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_absence_api.update_person_absence()
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE update_person_absence
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_absence_attendance_id         in     number
  ,p_abs_attendance_reason_id      in     number   default hr_api.g_number
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_date_notification             in     date     default hr_api.g_date
  ,p_date_projected_start          in     date     default hr_api.g_date
  ,p_time_projected_start          in     varchar2 default hr_api.g_varchar2
  ,p_date_projected_end            in     date     default hr_api.g_date
  ,p_time_projected_end            in     varchar2 default hr_api.g_varchar2
  ,p_date_start                    in     date     default hr_api.g_date
  ,p_time_start                    in     varchar2 default hr_api.g_varchar2
  ,p_date_end                      in     date     default hr_api.g_date
  ,p_time_end                      in     varchar2 default hr_api.g_varchar2
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default hr_api.g_number
  ,p_replacement_person_id         in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_period_of_incapacity_id       in     number   default hr_api.g_number
  ,p_ssp1_issued                   in     varchar2 default hr_api.g_varchar2
  ,p_maternity_id                  in     number   default hr_api.g_number
  ,p_sickness_start_date           in     date     default hr_api.g_date
  ,p_sickness_end_date             in     date     default hr_api.g_date
  ,p_pregnancy_related_illness     in     varchar2 default hr_api.g_varchar2
  ,p_reason_for_notification_dela  in     varchar2 default hr_api.g_varchar2
  ,p_accept_late_notification_fla  in     varchar2 default hr_api.g_varchar2
  ,p_linked_absence_id             in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_del_element_entry_warning     out nocopy    number
  );

  /*
  ||===========================================================================
  || PROCEDURE: create_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will create a transaction for absence
  ||                hr_api_transaction and hr_api_transaction_steps
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE  create_transaction(
     p_item_type           IN WF_ITEMS.ITEM_TYPE%TYPE ,
     p_item_key            IN WF_ITEMS.ITEM_KEY%TYPE ,
     p_act_id              IN NUMBER ,
     p_activity_name       IN VARCHAR2,
     p_transaction_id      IN OUT NOCOPY NUMBER ,
     p_transaction_step_id IN OUT NOCOPY NUMBER,
     p_login_person_id     IN NUMBER,
     p_review_proc_call    IN VARCHAR2
  ) ;

  /*
  ||===========================================================================
  || PROCEDURE: write_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will store absence information into
  ||                           hr_api_transaction_values
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE write_transaction (
   p_transaction_step_id  in NUMBER
  ,p_validate           in NUMBER default 0
  ,p_effective_date     in Date
  ,p_person_id          in NUMBER default NULL
  ,p_business_group_id  in NUMBER default NULL
  ,p_absence_attendance_type_id    in NUMBER default NULL
  ,p_abs_attendance_reason_id      in NUMBER default NULL
  ,p_comments           in long
  ,p_date_notification  in Date
  ,p_projected_start_date in Date
  ,p_projected_start_time in varchar2
  ,p_projected_end_date  in Date
  ,p_projected_end_time in varchar2
  ,p_start_date         in Date
  ,p_start_time         in VARCHAR2
  ,p_end_date           in Date
  ,p_end_time           in VARCHAR2
  ,p_days               in VARCHAR2
  ,p_hours              in VARCHAR2
  ,p_authorising_id     in NUMBER default NULL
  ,p_replacement_id     in NUMBER default NULL
  ,p_attribute_category in varchar2 default null
  ,p_attribute1         in varchar2 default null
  ,p_attribute2         in varchar2 default null
  ,p_attribute3         in varchar2 default null
  ,p_attribute4         in varchar2 default null
  ,p_attribute5         in varchar2 default null
  ,p_attribute6         in varchar2 default null
  ,p_attribute7         in varchar2 default null
  ,p_attribute8         in varchar2 default null
  ,p_attribute9         in varchar2 default null
  ,p_attribute10        in varchar2 default null
  ,p_attribute11        in varchar2 default null
  ,p_attribute12        in varchar2 default null
  ,p_attribute13        in varchar2 default null
  ,p_attribute14        in varchar2 default null
  ,p_attribute15        in varchar2 default null
  ,p_attribute16        in varchar2 default null
  ,p_attribute17        in varchar2 default null
  ,p_attribute18        in varchar2 default null
  ,p_attribute19        in varchar2 default null
  ,p_attribute20        in varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  );


  /*
  ||===========================================================================
  || PROCEDURE: get_absence_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Reads Absence Transaction from transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_absence_transaction
  (p_transaction_step_id    		IN VARCHAR2,
   p_effective_date         	 OUT NOCOPY VARCHAR2,
   p_person_id           	        OUT NOCOPY VARCHAR2,
   p_absence_attendance_type_id	        OUT NOCOPY VARCHAR2,
   p_abs_attendance_reason_id 	        OUT NOCOPY VARCHAR2,
   p_comments             	        OUT NOCOPY VARCHAR2,
   p_date_notification     	        OUT NOCOPY VARCHAR2,
   p_authorising_id 		        OUT NOCOPY VARCHAR2,
   p_replacement_id 		        OUT NOCOPY VARCHAR2,
   p_projected_start_date 	        OUT NOCOPY VARCHAR2,
   p_projected_start_time 	        OUT NOCOPY VARCHAR2,
   p_projected_end_date    	        OUT NOCOPY VARCHAR2,
   p_projected_end_time   	        OUT NOCOPY VARCHAR2,
   p_start_date      		        OUT NOCOPY VARCHAR2,
   p_start_time     		        OUT NOCOPY VARCHAR2,
   p_end_date 		                OUT NOCOPY VARCHAR2,
   p_end_time 		                OUT NOCOPY VARCHAR2,
   p_days 		                OUT NOCOPY VARCHAR2,
   p_hours           		        OUT NOCOPY VARCHAR2,
   p_start_ampm       		        OUT NOCOPY VARCHAR2,
   p_end_ampm              	        OUT NOCOPY VARCHAR2,
   p_attribute_category   	        OUT NOCOPY VARCHAR2,
   p_attribute1           	        OUT NOCOPY VARCHAR2,
   p_attribute2                         OUT NOCOPY VARCHAR2,
   p_attribute3     		        OUT NOCOPY VARCHAR2,
   p_attribute4 		        OUT NOCOPY VARCHAR2,
   p_attribute5      		        OUT NOCOPY VARCHAR2,
   p_attribute6  		        OUT NOCOPY VARCHAR2,
   p_attribute7       		        OUT NOCOPY VARCHAR2,
   p_attribute8        		        OUT NOCOPY VARCHAR2,
   p_attribute9            	        OUT NOCOPY VARCHAR2,
   p_attribute10        	        OUT NOCOPY VARCHAR2,
   p_attribute11         	        OUT NOCOPY VARCHAR2,
   p_attribute12       		        OUT NOCOPY VARCHAR2,
   p_attribute13         	        OUT NOCOPY VARCHAR2,
   p_attribute14      		        OUT NOCOPY VARCHAR2,
   p_attribute15       		        OUT NOCOPY VARCHAR2,
   p_attribute16         	        OUT NOCOPY VARCHAR2,
   p_attribute17           	        OUT NOCOPY VARCHAR2,
   p_attribute18      		        OUT NOCOPY VARCHAR2,
   p_attribute19        	        OUT NOCOPY VARCHAR2,
   p_attribute20           	        OUT NOCOPY VARCHAR2,
   p_absence_attendance_id              OUT NOCOPY VARCHAR2,
   p_review_actid    		        OUT NOCOPY VARCHAR2,
   p_review_proc_call    	        OUT NOCOPY VARCHAR2,
   p_abs_information_category           OUT NOCOPY VARCHAR2,
   p_abs_information1                   OUT NOCOPY VARCHAR2,
   p_abs_information2                   OUT NOCOPY VARCHAR2,
   p_abs_information3     	        OUT NOCOPY VARCHAR2,
   p_abs_information4 		        OUT NOCOPY VARCHAR2,
   p_abs_information5      	        OUT NOCOPY VARCHAR2,
   p_abs_information6  		        OUT NOCOPY VARCHAR2,
   p_abs_information7       	        OUT NOCOPY VARCHAR2,
   p_abs_information8        	        OUT NOCOPY VARCHAR2,
   p_abs_information9                   OUT NOCOPY VARCHAR2,
   p_abs_information10        	        OUT NOCOPY VARCHAR2,
   p_abs_information11         	        OUT NOCOPY VARCHAR2,
   p_abs_information12       	        OUT NOCOPY VARCHAR2,
   p_abs_information13         	        OUT NOCOPY VARCHAR2,
   p_abs_information14      	        OUT NOCOPY VARCHAR2,
   p_abs_information15       	        OUT NOCOPY VARCHAR2,
   p_abs_information16         	        OUT NOCOPY VARCHAR2,
   p_abs_information17                  OUT NOCOPY VARCHAR2,
   p_abs_information18      	        OUT NOCOPY VARCHAR2,
   p_abs_information19        	        OUT NOCOPY VARCHAR2,
   p_abs_information20                  OUT NOCOPY VARCHAR2,
   p_abs_information21        	        OUT NOCOPY VARCHAR2,
   p_abs_information22         	        OUT NOCOPY VARCHAR2,
   p_abs_information23       	        OUT NOCOPY VARCHAR2,
   p_abs_information24         	        OUT NOCOPY VARCHAR2,
   p_abs_information25      	        OUT NOCOPY VARCHAR2,
   p_abs_information26       	        OUT NOCOPY VARCHAR2,
   p_abs_information27         	        OUT NOCOPY VARCHAR2,
   p_abs_information28                  OUT NOCOPY VARCHAR2,
   p_abs_information29      	        OUT NOCOPY VARCHAR2,
   p_abs_information30        	        OUT NOCOPY VARCHAR2,
   p_leave_status        	        OUT NOCOPY VARCHAR2,
   p_save_mode          	        OUT NOCOPY VARCHAR2,
   p_activity_name          	        OUT NOCOPY VARCHAR2,
   p_business_group_id         	        OUT NOCOPY VARCHAR2,
   p_object_version_number              OUT NOCOPY VARCHAR2  --2793220
  ) ;


/*
  ||===========================================================================
  || PROCEDURE: get_return_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will retrieve confirm return information from
  ||     trensaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_return_transaction
  (p_transaction_step_id   IN  VARCHAR2
  ,p_effective_date        OUT NOCOPY VARCHAR2
  ,p_start_date            OUT NOCOPY VARCHAR2
  ,p_start_time            OUT NOCOPY VARCHAR2
  ,p_end_date              OUT NOCOPY VARCHAR2
  ,p_end_time              OUT NOCOPY VARCHAR2
  ,p_days                  OUT NOCOPY VARCHAR2
  ,p_hours                 OUT NOCOPY VARCHAR2
  ,p_review_actid          OUT NOCOPY VARCHAR2
  ,p_review_proc_call      OUT NOCOPY VARCHAR2
  ,p_attribute_category   	        OUT NOCOPY VARCHAR2
  ,p_attribute1           	        OUT NOCOPY VARCHAR2
  ,p_attribute2                         OUT NOCOPY VARCHAR2
  ,p_attribute3     		        OUT NOCOPY VARCHAR2
  ,p_attribute4 		        OUT NOCOPY VARCHAR2
  ,p_attribute5      		        OUT NOCOPY VARCHAR2
  ,p_attribute6  		        OUT NOCOPY VARCHAR2
  ,p_attribute7       		        OUT NOCOPY VARCHAR2
  ,p_attribute8        		        OUT NOCOPY VARCHAR2
  ,p_attribute9            	        OUT NOCOPY VARCHAR2
  ,p_attribute10        	        OUT NOCOPY VARCHAR2
  ,p_attribute11         	        OUT NOCOPY VARCHAR2
  ,p_attribute12       		        OUT NOCOPY VARCHAR2
  ,p_attribute13         	        OUT NOCOPY VARCHAR2
  ,p_attribute14      		        OUT NOCOPY VARCHAR2
  ,p_attribute15       		        OUT NOCOPY VARCHAR2
  ,p_attribute16         	        OUT NOCOPY VARCHAR2
  ,p_attribute17           	        OUT NOCOPY VARCHAR2
  ,p_attribute18      		        OUT NOCOPY VARCHAR2
  ,p_attribute19        	        OUT NOCOPY VARCHAR2
  ,p_attribute20           	        OUT NOCOPY VARCHAR2
  ,p_abs_information_category           OUT NOCOPY VARCHAR2
  ,p_abs_information1                   OUT NOCOPY VARCHAR2
  ,p_abs_information2                   OUT NOCOPY VARCHAR2
  ,p_abs_information3     	        OUT NOCOPY VARCHAR2
  ,p_abs_information4 		        OUT NOCOPY VARCHAR2
  ,p_abs_information5      	        OUT NOCOPY VARCHAR2
  ,p_abs_information6  		        OUT NOCOPY VARCHAR2
  ,p_abs_information7       	        OUT NOCOPY VARCHAR2
  ,p_abs_information8        	        OUT NOCOPY VARCHAR2
  ,p_abs_information9                   OUT NOCOPY VARCHAR2
  ,p_abs_information10        	        OUT NOCOPY VARCHAR2
  ,p_abs_information11         	        OUT NOCOPY VARCHAR2
  ,p_abs_information12       	        OUT NOCOPY VARCHAR2
  ,p_abs_information13         	        OUT NOCOPY VARCHAR2
  ,p_abs_information14      	        OUT NOCOPY VARCHAR2
  ,p_abs_information15       	        OUT NOCOPY VARCHAR2
  ,p_abs_information16         	        OUT NOCOPY VARCHAR2
  ,p_abs_information17                  OUT NOCOPY VARCHAR2
  ,p_abs_information18      	        OUT NOCOPY VARCHAR2
  ,p_abs_information19        	        OUT NOCOPY VARCHAR2
  ,p_abs_information20                  OUT NOCOPY VARCHAR2
  ,p_abs_information21        	        OUT NOCOPY VARCHAR2
  ,p_abs_information22         	        OUT NOCOPY VARCHAR2
  ,p_abs_information23       	        OUT NOCOPY VARCHAR2
  ,p_abs_information24         	        OUT NOCOPY VARCHAR2
  ,p_abs_information25      	        OUT NOCOPY VARCHAR2
  ,p_abs_information26       	        OUT NOCOPY VARCHAR2
  ,p_abs_information27         	        OUT NOCOPY VARCHAR2
  ,p_abs_information28                  OUT NOCOPY VARCHAR2
  ,p_abs_information29      	        OUT NOCOPY VARCHAR2
  ,p_abs_information30        	        OUT NOCOPY VARCHAR2
  ) ;


/*
  ||===========================================================================
  || PROCEDURE: get_update_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will retrieve update information from
  ||     trensaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_update_transaction
  (p_transaction_step_id   IN  VARCHAR2
  ,p_effective_date        OUT NOCOPY VARCHAR2
  ,p_projected_start_date  OUT NOCOPY VARCHAR2
  ,p_projected_start_time  OUT NOCOPY VARCHAR2
  ,p_projected_end_date    OUT NOCOPY VARCHAR2
  ,p_projected_end_time    OUT NOCOPY VARCHAR2
  ,p_days                  OUT NOCOPY VARCHAR2
  ,p_hours                 OUT NOCOPY VARCHAR2
  ,p_review_actid          OUT NOCOPY VARCHAR2
  ,p_review_proc_call      OUT NOCOPY VARCHAR2
  ,p_attribute_category   	        OUT NOCOPY VARCHAR2
  ,p_attribute1           	        OUT NOCOPY VARCHAR2
  ,p_attribute2                         OUT NOCOPY VARCHAR2
  ,p_attribute3     		        OUT NOCOPY VARCHAR2
  ,p_attribute4 		        OUT NOCOPY VARCHAR2
  ,p_attribute5      		        OUT NOCOPY VARCHAR2
  ,p_attribute6  		        OUT NOCOPY VARCHAR2
  ,p_attribute7       		        OUT NOCOPY VARCHAR2
  ,p_attribute8        		        OUT NOCOPY VARCHAR2
  ,p_attribute9            	        OUT NOCOPY VARCHAR2
  ,p_attribute10        	        OUT NOCOPY VARCHAR2
  ,p_attribute11         	        OUT NOCOPY VARCHAR2
  ,p_attribute12       		        OUT NOCOPY VARCHAR2
  ,p_attribute13         	        OUT NOCOPY VARCHAR2
  ,p_attribute14      		        OUT NOCOPY VARCHAR2
  ,p_attribute15       		        OUT NOCOPY VARCHAR2
  ,p_attribute16         	        OUT NOCOPY VARCHAR2
  ,p_attribute17           	        OUT NOCOPY VARCHAR2
  ,p_attribute18      		        OUT NOCOPY VARCHAR2
  ,p_attribute19        	        OUT NOCOPY VARCHAR2
  ,p_attribute20           	        OUT NOCOPY VARCHAR2
  ,p_abs_information_category           OUT NOCOPY VARCHAR2
  ,p_abs_information1                   OUT NOCOPY VARCHAR2
  ,p_abs_information2                   OUT NOCOPY VARCHAR2
  ,p_abs_information3     	        OUT NOCOPY VARCHAR2
  ,p_abs_information4 		        OUT NOCOPY VARCHAR2
  ,p_abs_information5      	        OUT NOCOPY VARCHAR2
  ,p_abs_information6  		        OUT NOCOPY VARCHAR2
  ,p_abs_information7       	        OUT NOCOPY VARCHAR2
  ,p_abs_information8        	        OUT NOCOPY VARCHAR2
  ,p_abs_information9                   OUT NOCOPY VARCHAR2
  ,p_abs_information10        	        OUT NOCOPY VARCHAR2
  ,p_abs_information11         	        OUT NOCOPY VARCHAR2
  ,p_abs_information12       	        OUT NOCOPY VARCHAR2
  ,p_abs_information13         	        OUT NOCOPY VARCHAR2
  ,p_abs_information14      	        OUT NOCOPY VARCHAR2
  ,p_abs_information15       	        OUT NOCOPY VARCHAR2
  ,p_abs_information16         	        OUT NOCOPY VARCHAR2
  ,p_abs_information17                  OUT NOCOPY VARCHAR2
  ,p_abs_information18      	        OUT NOCOPY VARCHAR2
  ,p_abs_information19        	        OUT NOCOPY VARCHAR2
  ,p_abs_information20                  OUT NOCOPY VARCHAR2
  ,p_abs_information21        	        OUT NOCOPY VARCHAR2
  ,p_abs_information22         	        OUT NOCOPY VARCHAR2
  ,p_abs_information23       	        OUT NOCOPY VARCHAR2
  ,p_abs_information24         	        OUT NOCOPY VARCHAR2
  ,p_abs_information25      	        OUT NOCOPY VARCHAR2
  ,p_abs_information26       	        OUT NOCOPY VARCHAR2
  ,p_abs_information27         	        OUT NOCOPY VARCHAR2
  ,p_abs_information28                  OUT NOCOPY VARCHAR2
  ,p_abs_information29      	        OUT NOCOPY VARCHAR2
  ,p_abs_information30        	        OUT NOCOPY VARCHAR2
  ,p_comments           	        OUT NOCOPY VARCHAR2
  );

  /*
  ||===========================================================================
  || PROCEDURE: get_abs_from_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This recover absence date from transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_abs_from_tt(
   p_transaction_step_id in number
  ,p_absence_rec out nocopy per_absence_attendances%rowtype
  );

  /*
  ||===========================================================================
  || PROCEDURE: get_rtn_from_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This recover absence date from transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_rtn_from_tt(
   p_transaction_step_id in number
  ,p_absence_rec out nocopy per_absence_attendances%rowtype
  );

  /*
  ||===========================================================================
  || PROCEDURE: get_upd_from_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This recover absence date from transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_upd_from_tt(
   p_transaction_step_id in number
  ,p_absence_rec out nocopy per_absence_attendances%rowtype
  );

  /*
  ||===========================================================================
  || PROCEDURE: process_api
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This recover absence date from transaction table and
  ||     Call create_absence_person
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure process_api
   (p_validate                 in     boolean default false
   ,p_transaction_step_id      in     number
   ,p_effective_date           in     varchar2 default null
   );

  /*
  ||===========================================================================
  || PROCEDURE: validate_api
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Call create_absence_person with validate mode
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure validate_api(
   p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date     default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     date     default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
--  ,p_authorising_person_id         in     number   default null
--  ,p_replacement_person_id         in     number   default null
  ,p_authorising_person_id         in     varchar2   default null
  ,p_replacement_person_id         in     varchar2   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ) ;

  /*
  ||===========================================================================
  || PROCEDURE: process_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Save creating absence data in transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure process_save(
   p_item_type                     in     WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key                      in     WF_ITEMS.ITEM_KEY%TYPE
  ,p_act_id                        in     NUMBER
  ,p_login_person_id               in     number
  ,p_review_proc_call              in     varchar2
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date     default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default null
  ,p_replacement_person_id         in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_start_ampm                    in     varchar2 default null
  ,p_end_ampm                      in     varchar2 default null
  ,p_save_mode                     in     varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_return_on_warning             in     varchar2 default null --2713296
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_transaction_step_id           out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  ) ;

  /*
  ||===========================================================================
  || PROCEDURE: process_txn_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Save infomration on create absence to transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure process_txn_save(
   p_transaction_step_id           in     NUMBER
  ,p_login_person_id               in     number
  ,p_review_proc_call              in     varchar2
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date     default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default null
  ,p_replacement_person_id         in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_start_ampm                    in     varchar2 default null
  ,p_end_ampm                      in     varchar2 default null
  ,p_save_mode                     in     varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_return_on_warning             in     varchar2 default null  --2713296
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  ) ;

/*
  ||===========================================================================
  || PROCEDURE: process_update_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call actual API with validate mode
  ||     if there are no error, save date into transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure process_update_save(
   p_item_type                     in     WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key                      in     WF_ITEMS.ITEM_KEY%TYPE
  ,p_act_id                        in     NUMBER
  ,p_login_person_id               in     number
  ,p_review_proc_call              in     varchar2
  ,p_effective_date                in     date
  ,p_date_notification             in     date
  ,p_absence_attendance_id         in     per_absence_attendances.absence_attendance_id%type
  ,p_object_version_number         in out nocopy number
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_replacement_person_id         in     number   default null
  ,p_update_return                 in     varchar2
  ,p_save_mode                     in     varchar2
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_person_id                     in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  ,p_return_on_warning		   in     varchar2 default null --2713296
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_transaction_step_id           out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  ) ;


/*
  ||===========================================================================
  || PROCEDURE: process_update_txn_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call actual API with validate mode
  ||     if there are no error, save date into transaction table
  ||     when updating transaction table for update absence
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure process_update_txn_save(
   p_transaction_step_id           in     number
  ,p_login_person_id               in     number
  ,p_effective_date                in     date
  --2713296 changes start
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_id         in     per_absence_attendances.absence_attendance_id%type
  ,p_object_version_number         in     number
  ,p_save_mode                     in     varchar2 default null
  --2713296 changes end
  ,p_absence_attendance_type_id    in     number   --2966372
  ,p_date_notification             in     date
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_replacement_person_id         in     number   default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  --2713296 changes start
  ,p_return_on_warning             in      varchar2 default null
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  --2713296 changes end
  );


--
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration - OLD>--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_type_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--
--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure calculate_absence_duration
 (
-- p_absence_attendance_id      in  number
  p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
-- ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy number
 ,p_min_max_failure            out nocopy varchar2   -- WWBUG #2602856
 ,p_warning_or_error           out nocopy varchar2   -- WWBUG #2602856
 ,p_page_error_msg	       out nocopy varchar2   -- 2695922
);

--
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration - NEW>--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_type_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--    p_ABS_INFORMATION_CATEGORY
--    p_ABS_INFORMATION1
--    p_ABS_INFORMATION2
--    p_ABS_INFORMATION3
--    p_ABS_INFORMATION4
--    p_ABS_INFORMATION5
--    p_ABS_INFORMATION6
--
--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure calculate_absence_duration
 (
--p_absence_attendance_id      in  number
  p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
-- ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_abs_information_category   in varchar2
 ,p_abs_information1          in varchar2
 ,p_abs_information2          in varchar2
 ,p_abs_information3          in varchar2
 ,p_abs_information4          in varchar2
 ,p_abs_information5          in varchar2
 ,p_abs_information6          in varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy number
 ,p_min_max_failure  	       out nocopy varchar2
 ,p_warning_or_error           out nocopy varchar2
 ,p_page_error_msg         out nocopy varchar2 --2695922
);
  /*
   ||===========================================================================
   || PROCEDURE: delete_absence
   ||---------------------------------------------------------------------------
   ||
   || Description:
   ||     This procedure will delete absence record from
   ||     per_absence_attendances.
   ||
   || Access Status:
   ||     Public.
   ||
   ||===========================================================================
   */
   procedure delete_absence(
    p_absence_attendance_id           IN NUMBER
    ,p_page_error_msg         OUT NOCOPY VARCHAR2 --2782075
   );

  /*
   ||===========================================================================
   || FUNCTION: chk_overlap
   ||---------------------------------------------------------------------------
   ||
   || Description:
   ||     This function will check overlap absence in transaction table
   ||
   || Access Status:
   ||     Public.
   ||
   ||===========================================================================
   */
   function chk_overlap(
     p_person_id           IN NUMBER
    ,p_business_group_id   IN NUMBER
    ,p_date_start          IN DATE
   ,p_date_end            IN DATE
   ,p_time_start          IN VARCHAR2 default null
   ,p_time_end            IN VARCHAR2 default null
   ) return boolean;

  /*
   ||===========================================================================
   || FUNCTION: is_gb_leg_and_category_s
   ||---------------------------------------------------------------------------
   ||
   || Description:
   ||     This function will return true if the absence category is 'Sickness'
   ||     and the legislation is 'GB' , else will return false.
   ||
   || Access Status:
   ||     Public.
   ||
   ||===========================================================================
   */
  function is_gb_leg_and_category_s(p_absence_attendance_type_id IN NUMBER ,
                                    p_business_group_id IN NUMBER)
  return boolean;
END HR_LOA_SS;

/
