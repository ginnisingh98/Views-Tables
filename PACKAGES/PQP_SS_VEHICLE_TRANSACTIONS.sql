--------------------------------------------------------
--  DDL for Package PQP_SS_VEHICLE_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SS_VEHICLE_TRANSACTIONS" AUTHID CURRENT_USER AS
/* $Header: pqpssvehinfo.pkh 120.0 2005/05/29 02:22:24 appldev noship $*/
--
--
TYPE ref_cursor IS REF CURSOR;
TYPE r_user_info IS RECORD (person_id per_all_people_f.person_id%TYPE
                           ,assignment_id per_all_assignments_f.assignment_id%TYPE
                               ,user_type VARCHAR2(10)) ;

TYPE t_user_info IS TABLE OF r_user_info
     INDEX BY BINARY_INTEGER;

g_user_info t_user_info;

PROCEDURE IS_EXTRA_INFO_EXISTS (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 );
--
PROCEDURE SET_EXTRA_INFO_VAL  (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 );
FUNCTION  get_vehicle_usr_details  (
                p_transaction_step_id   IN VARCHAR2 )
RETURN ref_cursor;

FUNCTION  get_vehicle_details  (
                p_transaction_step_id   IN VARCHAR2 )
RETURN ref_cursor ;
--
--
PROCEDURE delete_process_api (
   p_validate                   IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id        IN NUMBER,
   p_effective_date             IN VARCHAR2 DEFAULT NULL );


FUNCTION  get_vehicle_details_hgrid  (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor ;


PROCEDURE delete_vehicle_details(
   x_p_validate             IN BOOLEAN
  ,x_effective_date         IN DATE
  ,x_login_person_id        IN NUMBER
  ,x_person_id              IN NUMBER
  ,x_assignment_id          IN NUMBER
  ,x_business_group_id      IN NUMBER
  ,x_item_key               IN NUMBER
  ,x_item_type              IN VARCHAR2
  ,x_activity_id            IN NUMBER
  ,x_vehicle_allocation_id  IN NUMBER
  ,x_status                 IN VARCHAR2
  ,x_transaction_id         IN OUT NOCOPY NUMBER
  ,x_error_status           OUT NOCOPY VARCHAR2
                      );



PROCEDURE set_vehicle_details (
   x_p_validate                   IN     BOOLEAN DEFAULT false
  ,x_effective_date               IN     DATE    DEFAULT SYSDATE
  ,x_login_person_id              IN     NUMBER
  ,x_person_id                    IN     NUMBER
  ,x_assignment_id                IN     NUMBER
  ,x_item_type                    IN     VARCHAR2
  ,x_item_key                     IN     NUMBER
  ,x_activity_id                  IN     NUMBER
  ,x_registration_number          IN     VARCHAR2
  ,x_vehicle_ownership            IN     VARCHAR2 DEFAULT 'P'
  ,x_vehicle_type                 IN     VARCHAR2
  ,x_vehicle_id_number            IN     VARCHAR2
  ,x_business_group_id            IN     NUMBER
  ,x_make                         IN     VARCHAR2
  ,x_engine_capacity_in_cc        IN     NUMBER
  ,x_fuel_type                    IN     VARCHAR2
  ,x_currency_code                IN     VARCHAR2
  ,x_model                        IN     VARCHAR2
  ,x_initial_registration         IN     DATE
  ,x_last_registration_renew_date IN     DATE
  ,x_fiscal_ratings               IN     NUMBER
  ,x_shared_vehicle               IN     VARCHAR2
  ,x_color                        IN     VARCHAR2
  ,x_seating_capacity             IN     NUMBER
  ,x_weight                       IN     NUMBER
  ,x_weight_uom                   IN     VARCHAR2
  ,x_model_year                   IN     NUMBER
  ,x_insurance_number             IN     VARCHAR2
  ,x_insurance_expiry_date        IN     DATE
  ,x_taxation_method              IN     VARCHAR2
  ,x_comments                     IN     VARCHAR2
  ,x_vre_attribute_category       IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute1               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute2               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute3               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute4               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute5               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute6               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute7               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute8               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute9               IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute10              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute11              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute12              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute13              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute14              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute15              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute16              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute17              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute18              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute19              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_attribute20              IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information_category     IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information1             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information2             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information3             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information4             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information5             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information6             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information7             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information8             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information9             IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information10            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information11            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information12            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information13            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information14            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information15            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information16            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information17            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information18            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information19            IN     VARCHAR2 DEFAULT NULL
  ,x_vre_information20            IN     VARCHAR2 DEFAULT NULL
  ,x_across_assignments           IN     VARCHAR2 DEFAULT NULL
  ,x_usage_type                   IN     VARCHAR2 DEFAULT NULL
  ,x_default_vehicle              IN     VARCHAR2 DEFAULT NULL
  ,x_fuel_card                    IN     VARCHAR2 DEFAULT NULL
  ,x_fuel_card_number             IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute_category       IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute1               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute2               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute3               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute4               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute5               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute6               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute7               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute8               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute9               IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute10              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute11              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute12              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute13              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute14              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute15              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute16              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute17              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute18              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute19              IN     VARCHAR2 DEFAULT NULL
  ,x_val_attribute20              IN     VARCHAR2 DEFAULT NULL
  ,x_val_information_category     IN     VARCHAR2 DEFAULT NULL
  ,x_val_information1             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information2             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information3             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information4             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information5             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information6             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information7             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information8             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information9             IN     VARCHAR2 DEFAULT NULL
  ,x_val_information10            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information11            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information12            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information13            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information14            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information15            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information16            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information17            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information18            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information19            IN     VARCHAR2 DEFAULT NULL
  ,x_val_information20            IN     VARCHAR2 DEFAULT NULL
  ,x_fuel_benefit                 IN     VARCHAR2 DEFAULT NULL
  ,x_user_info                    IN     t_user_info
  ,x_status                       IN     VARCHAR2  DEFAULT NULL
  ,x_effective_date_option        IN VARCHAR2  DEFAULT NULL
  ,x_vehicle_repository_id        IN     NUMBER   DEFAULT NULL
  ,x_vehicle_allocation_id        IN     NUMBER   DEFAULT NULL
  ,x_object_version_number        IN     NUMBER   DEFAULT NULL
  ,x_error_status                 OUT    NOCOPY VARCHAR2
   ,x_transaction_id              IN OUT NOCOPY NUMBER
);
PROCEDURE update_transaction_itemkey (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT     NOCOPY  VARCHAR2 );


--
--
--
--
PROCEDURE process_api (
   p_validate			IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id	IN NUMBER,
   p_effective_date             IN VARCHAR2 DEFAULT NULL);

PROCEDURE delete_allocation(
   p_validate             IN BOOLEAN DEFAULT FALSE
  ,p_effective_date         IN DATE
  ,p_assignment_id          IN NUMBER
  ,p_vehicle_allocation_id  IN NUMBER
  ,p_business_group_id      IN NUMBER
  ,p_error_status           OUT NOCOPY VARCHAR2
                      );
--
--
--
--
--
--
END PQP_SS_VEHICLE_TRANSACTIONS;


 

/
