--------------------------------------------------------
--  DDL for Package PQH_PROCESS_ACADEMIC_RANK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PROCESS_ACADEMIC_RANK" AUTHID CURRENT_USER AS
/* $Header: pqhusark.pkh 120.1 2006/07/18 19:42:13 nsanghal noship $*/
--
--
TYPE ref_cursor IS REF CURSOR;
--
FUNCTION  get_academic_rank (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor ;
--
--

PROCEDURE  get_academic_rank_details (
 x_transaction_step_id   in     varchar2
,x_pei_information1 out nocopy varchar2
,x_pei_information2 out nocopy varchar2
,x_pei_information3 out nocopy varchar2
,x_pei_information4 out nocopy varchar2
,x_pei_information5 out nocopy varchar2
,x_person_extra_info_id out nocopy varchar2 );

PROCEDURE set_academic_rank_details (
  x_login_person_id     IN NUMBER,
  x_person_id     	IN NUMBER,
  x_item_type           IN VARCHAR2,
  x_item_key            IN NUMBER,
  x_activity_id         IN NUMBER,
  x_object_version_number IN NUMBER,
  x_person_extra_info_id IN NUMBER,
  x_pei_information1	IN VARCHAR2,
  x_pei_information2	IN VARCHAR2,
  x_pei_information3	IN VARCHAR2,
  x_pei_information4	IN VARCHAR2,
  x_pei_information5	IN VARCHAR2 );

PROCEDURE process_api (
   p_validate			IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id	IN NUMBER,
   p_effective_date             IN VARCHAR2 DEFAULT NULL );

END;

 

/
