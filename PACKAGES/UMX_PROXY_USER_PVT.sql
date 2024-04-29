--------------------------------------------------------
--  DDL for Package UMX_PROXY_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_PROXY_USER_PVT" AUTHID CURRENT_USER as
/*$Header: UMXVPRXS.pls 120.1 2005/07/02 04:25:17 appldev noship $*/

  /**
   * Function    :  GET_PERSON_ID
   * Type        :  Private
   * Description :  Retrieve person_id from party_id
   * Parameters  :
   * input parameters
   * @param
   *   p_party_id
   *     description:  Party Id of the person
   *     required   :  Y
   *     validation :  Must be a valid party_id
   *     default    :  null
   * output parameters
   * @return        : Person Id of the user
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  function GET_PERSON_ID (p_party_id  in hz_parties.party_id%type) return number;

  /**
   * Function    :  GET_PHONE_NUMBER
   * Type        :  Private
   * Description :  Retrieve phone number
   * Parameters  :
   * input parameters
   * @param
   *   p_person_id
   *     description:  Person Id of the person
   *     required   :  Y
   *     validation :  Must be a valid person_id
   *     default    :  null
   * output parameters
   * @return        : Phone Number of the person
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  function GET_PHONE_NUMBER(p_person_id  in per_all_people_f.person_id%type) return varchar2;

/**
   * Function    :  GET_PHONE_NUMBER
   * Type        :  Private
   * Description :  Retrieve phone number
   * Parameters  :
   * input parameters
   * @param
   *   p_person_id
   *     description:  Person Id of the person
   *     required   :  Y
   *     validation :  Must be a valid person_id
   *     default    :  null
   * output parameters
   * @return        : Phone Number of the person
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  procedure GET_EMP_DATA(p_person_id  in per_all_people_f.person_id%type,
                         x_phone_number out NOCOPY PER_PHONES.PHONE_NUMBER%TYPE ,
                         x_job_title out NOCOPY PER_JOBS_VL.NAME%TYPE
                         );




end UMX_PROXY_USER_PVT;

 

/
