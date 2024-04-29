--------------------------------------------------------
--  DDL for Package PQH_PROCESS_TENURE_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PROCESS_TENURE_STATUS" AUTHID CURRENT_USER AS
/* $Header: pqhusten.pkh 115.6 2004/02/11 12:12:18 nsanghal noship $*/
--
--
TYPE ref_cursor IS REF CURSOR;
--
FUNCTION  get_tenure_status  (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor ;
--
--

PROCEDURE  get_tenure_details (
 x_transaction_step_id   in     varchar2
,x_pei_information1 out nocopy varchar2
,x_pei_information2 out nocopy varchar2
,x_pei_information3 out nocopy varchar2
,x_pei_information4 out nocopy varchar2
,x_pei_information5 out nocopy varchar2
,x_pei_information6 out nocopy varchar2
,x_person_extra_info_id out nocopy varchar2 );
--
--
PROCEDURE set_tenure_details (
  x_login_person_id     IN NUMBER,
  x_person_id           IN NUMBER,
  x_item_type           IN VARCHAR2,
  x_item_key            IN NUMBER,
  x_activity_id         IN NUMBER,
  x_object_version_number IN NUMBER,
  x_person_extra_info_id IN NUMBER,
  x_pei_information1	IN VARCHAR2,
  x_pei_information2	IN VARCHAR2,
  x_pei_information3	IN VARCHAR2,
  x_pei_information4	IN VARCHAR2,
  x_pei_information5	IN VARCHAR2,
  x_pei_information6	IN VARCHAR2 );
--
--
PROCEDURE process_api (
   p_validate			IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id	IN NUMBER );
--
--
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
END pqh_process_tenure_status;

 

/
