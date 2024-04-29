--------------------------------------------------------
--  DDL for Package PQP_SS_VEHICLE_MILEAGE_CLAIMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SS_VEHICLE_MILEAGE_CLAIMS" AUTHID CURRENT_USER AS
/* $Header: pqpssvehmlgclm.pkh 120.2 2005/09/29 05:18:47 rrazdan noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
--

--
*/
--
--
TYPE ref_cursor IS REF CURSOR;
TYPE r_user_info IS RECORD (person_id per_all_people_f.person_id%TYPE
                           ,assignment_id per_all_assignments_f.assignment_id%TYPE
                               ,user_type VARCHAR2(10)) ;


procedure get_transaction_id
  (p_transaction_step_id in number
   ,p_transaction      out nocopy number);
--
--
--

PROCEDURE delete_validate_mileage_claim (
   p_effective_date         IN DATE
  ,p_assignment_id          IN NUMBER
  ,p_mileage_claim_element  IN NUMBER
  ,p_element_entry_id       IN OUT NOCOPY NUMBER
  ,p_element_entry_date     IN OUT NOCOPY DATE
  ,p_error_status           OUT NOCOPY VARCHAR2
   );

PROCEDURE get_dml_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 );

PROCEDURE delete_vehicle_mileage_claim(
   x_effective_date         IN DATE
  ,x_login_person_id        IN NUMBER
  ,x_person_id              IN NUMBER
  ,x_assignment_id          IN NUMBER
  ,x_business_group_id      IN NUMBER
  ,x_item_key               IN NUMBER
  ,x_item_type              IN VARCHAR2
  ,x_element_entry_id       IN NUMBER
  ,p_status                 IN VARCHAR2
  ,x_transaction_id         IN OUT NOCOPY NUMBER
  ,x_transaction_step_id    IN OUT NOCOPY NUMBER
  ,x_confirmation_number    OUT NOCOPY NUMBER
  ,x_error_status           OUT NOCOPY VARCHAR2
                      );
PROCEDURE update_transaction_itemkey (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 );


FUNCTION  get_vehicle_mileage_claim  (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor;
--
--
--
--
PROCEDURE create_vehicle_mileage_claims
         (
          p_effective_date             IN DATE,
          p_web_adi_identifier         IN VARCHAR2  ,
          p_info_id                    IN VARCHAR2  ,
          p_time_stamp                 IN VARCHAR2  ,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  default null,
          p_claimed_mileage_o          IN VARCHAR2  default null,
          p_actual_mileage_o           IN VARCHAR2  default null,
          p_registration_number        IN VARCHAR2  default null,
          p_engine_capacity            IN VARCHAR2  default null,
          p_fuel_type                  IN VARCHAR2  default null,
          p_fiscal_ratings             IN VARCHAR2  default null,
          p_no_of_passengers           IN VARCHAR2  default null,
          p_purpose                    IN VARCHAR2  default null,
          p_user_type                  IN VARCHAR2  default 'SS',
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_mode                       OUT NOCOPY VARCHAR2,
          p_return_status              OUT NOCOPY VARCHAR2

          );
PROCEDURE delete_process_api (
   p_validate                   IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id        IN NUMBER );

PROCEDURE process_api
  (p_validate             in  boolean  default false
  ,p_transaction_step_id  in  number   default null
  ,p_effective_date       in  varchar2 default null
  ) ;

/*PROCEDURE process_api (
   p_validate			IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id	IN NUMBER ); */
--
--

PROCEDURE set_vehicle_mileage_claim (
   x_p_validate                   in boolean
  ,x_effective_date              in date
  ,x_login_person_id             in number
  ,x_person_id                    in number
  ,x_assignment_id                in number
  ,x_item_type                    in varchar2
  ,x_item_key                     in number
  ,x_activity_id                  in number
  ,x_business_group_id           IN NUMBER
  ,x_legislation_code           IN VARCHAR2
  ,x_ownership                  IN VARCHAR2
  ,x_usage_type                 IN VARCHAR2
  ,x_vehicle_type               IN VARCHAR2
  ,x_start_date                 IN DATE
  ,x_end_date                   IN DATE
  ,x_claimed_mileage            IN VARCHAR2
  ,x_actual_mileage             IN VARCHAR2  default null
  ,x_claimed_mileage_o          IN VARCHAR2  default null
  ,x_actual_mileage_o           IN VARCHAR2  default null
  ,x_registration_number        IN VARCHAR2  default null
  ,x_engine_capacity            IN VARCHAR2  default null
  ,x_fuel_type                  IN VARCHAR2  default null
  ,x_fiscal_ratings             IN VARCHAR2  default null
  ,x_no_of_passengers           IN VARCHAR2  default null
  ,x_purpose                    IN VARCHAR2  default null
  ,x_element_entry_id           IN NUMBER    default NULL
  ,x_status                     IN VARCHAR2  DEFAULT NULL
  ,x_effective_date_option      IN VARCHAR2  DEFAULT NULL
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_object_version_number      IN NUMBER
  ,x_error_status               OUT NOCOPY varchar2
  ,x_transaction_id             in out nocopy NUMBER
  ,x_transaction_step_id        in out nocopy NUMBER
  ,x_confirmation_number        OUT NOCOPY    NUMBER
);
PROCEDURE rollback_transaction (
	itemType	IN VARCHAR2,
	itemKey		IN VARCHAR2,
        result	 OUT NOCOPY VARCHAR2) ;
--
--
PROCEDURE self_or_subordinate (
	itemtype   	IN VARCHAR2,
        itemkey    	IN VARCHAR2,
        actid      	IN NUMBER,
        funcmode   	IN VARCHAR2,
        resultout  	IN OUT NOCOPY VARCHAR2);
--
--
END pqp_ss_vehicle_mileage_claims;

 

/
