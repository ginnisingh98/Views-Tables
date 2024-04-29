--------------------------------------------------------
--  DDL for Package PQH_PA_WHATIF_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PA_WHATIF_PROCESS" AUTHID CURRENT_USER AS
/* $Header: pqwifswi.pkh 115.2 2003/07/01 09:54:14 kmullapu noship $ */

FUNCTION get_uom (p_uom            IN VARCHAR2
                 ,p_nnmntry_uom    IN VARCHAR2
                 ,p_effective_date IN DATE    )
RETURN VARCHAR2;
/*
||========================================================================================================
|| PROCEDURE: ss_whatif_process
||--------------------------------------------------------------------------------------------------------
||
|| Description:
||   This buids the current and whatif benefit hierarchy
||
|| Parameters
|| -------------------------------------------------------------------------------------------------------
|| Name     Description
||--------------------------------------------------------------------------------------------------------
||p_called_from              Whether whatif is being called from ssben or sshr(values :SSHR/SSBEN)
||p_login_id                 Fnd user_id of person who initiated What-If function.
||p_login_type               Whether user is using LMDA or EDA (LINE/EMP).User for role based plan restriction
||p_person_id                Person on whom what if is being performed
||p_effective_date           What if date.ystem will analyse the impact on benefits as of this date
||p_session_date             Transaction date (Since we dont have date tracking this will be sysdate)
||p_transaction_id           PK of hr_api_transactions table.Used to get data changes
||p_ler_id                   For sshr whatif this returns detected LE.For ssben whatif
||                           this specifies theoverridding LE in case of conflicting LE's
||p_whatif_results_batch_id  batch ID of pqh_pa_watif_results table containing hierarchy
||========================================================================================================
*/

PROCEDURE ss_whatif_process(
          p_called_from               IN        VARCHAR2
         ,p_login_id                  IN        NUMBER
         ,p_login_type                IN        VARCHAR2
         ,p_person_id                 IN        NUMBER
         ,p_business_group_id         IN        NUMBER
         ,p_effective_date            IN        DATE
         ,p_session_date              IN        DATE
         ,p_transaction_id            IN        NUMBER
         ,p_ler_id                IN OUT NOCOPY NUMBER
         ,p_whatif_results_batch_id  OUT NOCOPY NUMBER
         );
/*
||========================================================================================================
|| PROCEDURE: validate_data_changes
||--------------------------------------------------------------------------------------------------------
||
|| Description: Used for ssben whatif only
|| This validates the data changes by posting them and checking if conflicting LE's are triggered.
|| Conflicting LE's triggered (if any) are inserted in pah_pa_watif_results table.
||
|| Parameters
|| -------------------------------------------------------------------------------------------------------
|| Name     Description
||--------------------------------------------------------------------------------------------------------
||p_person_id                Person on whom what if is being performed
||p_effective_date           What if date.ystem will analyse the impact on benefits as of this date
||p_session_date             Transaction date (Since we dont have date tracking this will be sysdate)
||p_transaction_id           PK of hr_api_transactions table.Used to get data changes
||p_whatif_results_batch_id  batch ID of pqh_pa_watif_results table containing conflicting LE's triggered
||                           by data changes
||========================================================================================================
*/

PROCEDURE validate_data_changes(
          p_person_id                 IN        NUMBER
         ,p_business_group_id         IN        NUMBER
         ,p_effective_date            IN        DATE
         ,p_session_date              IN        DATE
         ,p_transaction_id            IN        NUMBER
         ,p_whatif_results_batch_id  OUT NOCOPY NUMBER
         );
/*
||========================================================================================================
|| PROCEDURE: prepare_transaction
||--------------------------------------------------------------------------------------------------------
||
|| Description: Used for ssben whatif only
|| This is used to create a hr_api_txn for ssben whatif.If in same txn,this will try to re-use txn_id
|| This procedure will be enhanced to purge uncessary txn's from hr_api_txn tabels
||
|| Parameters
|| -------------------------------------------------------------------------------------------------------
|| Name     Description
||--------------------------------------------------------------------------------------------------------
||p_person_id                Person on whom what if is being performed
||p_txn_id                   PK of hr_api_transactions
||========================================================================================================
*/

PROCEDURE prepare_transaction(
                              p_person_id     IN        NUMBER
                             ,p_txn_id    IN OUT NOCOPY NUMBER
                              );
/*
||========================================================================================================
|| PROCEDURE: get_user_role
||--------------------------------------------------------------------------------------------------------
||
|| Description: Used for role based plan/life event restriction
|| Given a user_Id and type this will return the role_id to be considered
||
|| Parameters
|| -------------------------------------------------------------------------------------------------------
|| Name     Description
||--------------------------------------------------------------------------------------------------------
||p_user_id                  Fnd user who initiated whatif function
||p_user_type                Whether User is accesing Employee Whatif or Manager Whatif
||p_role_id                  PK of pqh_roles, to be used in to restrict comp object access
||========================================================================================================
*/
PROCEDURE get_user_role(
                        p_user_id           IN        NUMBER
                       ,p_user_type         IN        VARCHAR2
                       ,p_business_group_id IN        NUMBER
                       ,p_role_id          OUT NOCOPY NUMBER
                       );

FUNCTION get_first_label(
                         p_ler_id         IN NUMBER
                        ,p_effective_date IN DATE
                         )
RETURN VARCHAR2;

END pqh_pa_whatif_process;

 

/
