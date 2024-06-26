--------------------------------------------------------
--  DDL for Package Body PQH_PROCESS_TENURE_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PROCESS_TENURE_STATUS" AS
/* $Header: pqhusten.pkb 120.0 2005/05/29 02:08:35 appldev noship $*/

PROCEDURE rollback_transaction(
	itemType	IN VARCHAR2,
	itemKey		IN VARCHAR2,
        result	 OUT NOCOPY VARCHAR2) IS
BEGIN
--
   savepoint rollback_transaction;
   --
   wf_engine.setItemAttrNumber (
      itemType	=> itemType,
      itemKey   => itemKey,
      aname     => 'TRANSACTION_ID',
      avalue    => null );
   --
   --
   hr_transaction_ss.rollback_transaction (
      itemType	=> itemType,
      itemKey   => itemKey,
      actid     => 0,
      funmode   => 'RUN',
      result    => result );
   --
   --
   result := 'SUCCESS';
   --
   --
EXCEPTION
   --
   WHEN Others THEN
	rollback to rollback_transaction;
	result := 'FAILURE';
   --
END;

--
--
FUNCTION  get_tenure_status  (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor IS
  csr ref_cursor;
BEGIN
  OPEN csr FOR
    select
       tenure.person_id,
       'PQH_TENURE_STATUS' pei_information_category,
       tenure.pei_information1,
       fnd_date.canonical_to_date(tenure.pei_information2)  pei_information2,
       fnd_date.canonical_to_date(tenure.pei_information3)  pei_information3,
       fnd_date.canonical_to_date(tenure.pei_information4)  pei_information4,
       tenure.pei_information5,
       to_number(tenure.person_extra_info_id ) person_extra_info_id,
       to_number(tenure.object_version_number) object_version_number,
       hl.meaning Tenure_desc,
       tenure.pei_information6
    from (
      Select max(person_id) person_id ,
             max(pei_information1) pei_information1,
             max(person_extra_info_id) person_extra_info_id,
             max(object_version_number) object_version_number,
             max(pei_information2) pei_information2,
             max(pei_information3) pei_information3,
             max(pei_information4) pei_information4,
             max(pei_information5) pei_information5,
             max(pei_information6) pei_information6
      from (
          SELECT decode(a.name, 'P_PERSON_ID'            , a.varchar2_value, null) person_id,
                 decode(a.name, 'P_TENURE_STATUS'        , a.varchar2_value,null)  pei_information1,
                 decode(a.name, 'P_DATE_DETERMINE'       , a.varchar2_value,null)  pei_information2,
                 decode(a.name, 'P_PROJECTED_TENURE_DATE', a.varchar2_value ,null) pei_information3,
                 decode(a.name, 'P_ADJUSTED_DATE'        , a.varchar2_value ,null) pei_information4,
                 decode(a.name, 'P_REASON_ADJUSTED'      , a.varchar2_value ,null) pei_information5,
                 decode(a.name, 'P_PERSON_EXTRA_INFO_ID' , a.varchar2_value ,null) person_extra_info_id,
                 decode(a.name, 'P_OBJECT_VERSION_NUMBER', a.varchar2_value ,null) object_version_number,
                 decode(a.name, 'P_SUBJECT_TO_QUOTA'     , a.varchar2_value ,null) pei_information6
                FROM hr_api_transaction_steps s,
                     hr_api_transaction_values a
                WHERE s.transaction_step_id = a.transaction_step_id
                and s.transaction_step_id = p_transaction_step_id
                AND s.api_name = 'PQH_PROCESS_TENURE_STATUS.PROCESS_API'
                )
          )  tenure ,
             hr_lookups hl
      where  hl.lookup_type  = 'PQH_TENURE_STATUS'
      AND    hl.lookup_code  = tenure.pei_information1;

  RETURN csr;
END get_tenure_status;

--
--

PROCEDURE get_tenure_details (
  x_transaction_step_id   in     varchar2
 ,x_pei_information1 out nocopy varchar2
 ,x_pei_information2 out nocopy varchar2
 ,x_pei_information3 out nocopy varchar2
 ,x_pei_information4 out nocopy varchar2
 ,x_pei_information5 out nocopy varchar2
 ,x_pei_information6 out nocopy varchar2
 ,x_person_extra_info_id out nocopy varchar2 ) IS

l_transaction_step_id  number;
l_api_name             hr_api_transaction_steps.api_name%TYPE;

BEGIN
  hr_utility.set_location('Entering: PQH_PROCESS_TENURE.get_tenure_details',5);
  --
  l_transaction_step_id := to_number(x_transaction_step_id);
  --

  if l_transaction_step_id is null then
    return;
  end if;
  --

  x_pei_information1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_TENURE_STATUS');
  --
  x_pei_information2 :=
	REPLACE(SUBSTR(
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DATE_DETERMINE')
    ,1,10),'/','-');
  --
  x_pei_information3 :=
	REPLACE(SUBSTR(
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PROJECTED_TENURE_DATE')
    ,1,10),'/','-');
  --
  x_pei_information4 :=
	REPLACE(SUBSTR(
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ADJUSTED_DATE')
    ,1,10),'/','-');
  --
  x_pei_information5 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_REASON_ADJUSTED');
  --
  x_pei_information6 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SUBJECT_TO_QUOTA');
  --
  x_person_extra_info_id :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PERSON_EXTRA_INFO_ID');
  --
  hr_utility.set_location('Leaving: PQH_PROCESS_TENURE.get_tenure_details',10);
EXCEPTION
  WHEN hr_utility.hr_error THEN
	hr_utility.raise_error;
  WHEN OTHERS THEN
x_pei_information1 := null;
x_pei_information2 := null;
x_pei_information3 := null;
x_pei_information4 := null;
x_pei_information5 := null;
x_pei_information6 := null;
x_person_extra_info_id := null;
      RAISE;  -- Raise error here relevant to the new tech stack.
END get_tenure_details;

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
  x_pei_information6	IN VARCHAR2 )  IS

l_transaction_id        number;
l_trans_tbl            	hr_transaction_ss.transaction_table;
l_count		        number;
l_transaction_step_id   number;
l_api_name   constant  	hr_api_transaction_steps.api_name%TYPE := 'PQH_PROCESS_TENURE_STATUS.PROCESS_API';
l_result               	varchar2(100);
l_trns_object_version_number    number;
l_review_proc_call      VARCHAR2(30);
l_effective_date      	DATE 	;

BEGIN
  hr_utility.set_location('Entering: PQH_PROCESS_TENURE.set_tenure_details',5);
  l_review_proc_call    := 'PqhTenureStatusReview';
  l_effective_date      := SYSDATE;
    --
  hr_transaction_api.get_transaction_step_info
       (p_item_type             => x_item_type
       ,p_item_key              => x_item_key
       ,p_activity_id           => x_activity_id
       ,p_transaction_step_id   => l_transaction_step_id
       ,p_object_version_number => l_trns_object_version_number);
    --
  l_count:=1;
  l_trans_tbl(l_count).param_name      := 'P_OBJECT_VERSION_NUMBER';
  l_trans_tbl(l_count).param_value     :=  x_object_version_number;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL';
  l_trans_tbl(l_count).param_value     :=  l_review_proc_call;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID';
  l_trans_tbl(l_count).param_value     :=  x_activity_id;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_TENURE_STATUS';
  l_trans_tbl(l_count).param_value     :=  x_pei_information1;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DATE_DETERMINE';
  l_trans_tbl(l_count).param_value     :=  x_pei_information2;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PROJECTED_TENURE_DATE';
  l_trans_tbl(l_count).param_value     :=  x_pei_information3;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ADJUSTED_DATE';
  l_trans_tbl(l_count).param_value     :=  x_pei_information4;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REASON_ADJUSTED';
  l_trans_tbl(l_count).param_value     :=  x_pei_information5;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SUBJECT_TO_QUOTA';
  l_trans_tbl(l_count).param_value     :=  x_pei_information6;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  x_person_id;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PERSON_EXTRA_INFO_ID';
  l_trans_tbl(l_count).param_value     :=  x_person_extra_info_id;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  hr_transaction_ss.save_transaction_step
    (p_item_type             => x_item_type
    ,p_item_key              => x_item_key
    ,p_actid                 => x_activity_id
    ,p_login_person_id       => x_login_person_id
    ,p_transaction_step_id   => l_transaction_step_id
    ,p_api_name		     => l_api_name
    ,p_transaction_data      => l_trans_tbl  );
  hr_utility.set_location('Leaving: PQH_PROCESS_TENURE.set_tenure_details',10);
commit;
EXCEPTION
  WHEN hr_utility.hr_error THEN
	hr_utility.raise_error;
  WHEN OTHERS THEN
      RAISE;  -- Raise error here relevant to the new tech stack.
END set_tenure_details;
--
--
PROCEDURE process_api (
   p_validate			IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id	IN NUMBER ) IS
--
--
l_person_id		NUMBER;
l_person_extra_info_id	NUMBER;
l_ovn			NUMBER;
--
--
l_pei_information1	VARCHAR2(255);
l_pei_information2	VARCHAR2(255);
l_pei_information3	VARCHAR2(255);
l_pei_information4	VARCHAR2(255);
l_pei_information5	VARCHAR2(255);
l_pei_information6	VARCHAR2(255);
--
--
BEGIN
  hr_utility.set_location('Entering: PQH_PROCESS_TENURE.process_api',5);
  --
  savepoint  process_tenure_details;
  --
  get_tenure_details (
	 x_transaction_step_id  => p_transaction_step_id
	,x_pei_information1	=> l_pei_information1
	,x_pei_information2	=> l_pei_information2
	,x_pei_information3	=> l_pei_information3
	,x_pei_information4	=> l_pei_information4
	,x_pei_information5	=> l_pei_information5
	,x_pei_information6	=> l_pei_information6
	,x_person_extra_info_id	=> l_person_extra_info_id);

  l_person_id 		:=  hr_transaction_api.get_varchar2_value (
				p_transaction_step_id	=> p_transaction_step_id,
				p_name			=> 'P_PERSON_ID');
  --
  --
  l_ovn			:= hr_transaction_api.get_varchar2_value (
				p_transaction_step_id	=> p_transaction_step_id,
				p_name			=> 'P_OBJECT_VERSION_NUMBER');
  --

  IF l_pei_information2 IS NOT NULL THEN
     l_pei_information2 := TO_CHAR(TO_DATE(l_pei_information2,'RRRR-MM-DD'),'RRRR/MM/DD HH24:MI:SS');
  END IF;

  IF l_pei_information3 IS NOT NULL THEN
     l_pei_information3 := TO_CHAR(TO_DATE(l_pei_information3,'RRRR-MM-DD'),'RRRR/MM/DD HH24:MI:SS');
  END IF;

  IF l_pei_information4 IS NOT NULL THEN
     l_pei_information4 := TO_CHAR(TO_DATE(l_pei_information4,'RRRR-MM-DD'),'RRRR/MM/DD HH24:MI:SS');
  END IF;


  IF l_person_extra_info_id IS NOT NULL THEN
  --
     HR_PERSON_EXTRA_INFO_API.update_person_extra_info (
	p_person_extra_info_id		=> l_person_extra_info_id,
	p_pei_information1		=> l_pei_information1 ,
	p_pei_information2		=> l_pei_information2 ,
	p_pei_information3		=> l_pei_information3 ,
	p_pei_information4		=> l_pei_information4 ,
	p_pei_information5		=> l_pei_information5 ,
	p_pei_information6		=> l_pei_information6 ,
	p_object_version_number		=> l_ovn  );
  --
  ELSE
  --
    HR_PERSON_EXTRA_INFO_API.create_person_extra_info (
	p_information_type		=> 'PQH_TENURE_STATUS',
	p_pei_information_category	=> 'PQH_TENURE_STATUS',
	p_person_id			=> l_person_id ,
	p_pei_information1		=> l_pei_information1 ,
	p_pei_information2		=> l_pei_information2 ,
	p_pei_information3		=> l_pei_information3 ,
	p_pei_information4		=> l_pei_information4 ,
	p_pei_information5		=> l_pei_information5 ,
	p_pei_information6		=> l_pei_information6 ,
	p_person_extra_info_id		=> l_person_extra_info_id,
	p_object_version_number		=> l_ovn );
  --
  END IF;
  --
  -- ns 5/19/2005: BUG 4381336: commenting commit as it is called while
  -- resurrecting the transaction (via update action link), it is then
  -- attempted to rollback which would fail if committed here.
  -- commit;
  --
  hr_utility.set_location('Leaving: PQH_PROCESS_TENURE.process_api',10);
EXCEPTION
  WHEN hr_utility.hr_error THEN
	ROLLBACK TO process_tenure_details;
	RAISE;
  WHEN OTHERS THEN
      RAISE;  -- Raise error here relevant to the new tech stack.
END process_api;

PROCEDURE self_or_subordinate (
	itemtype   	IN VARCHAR2,
        itemkey    	IN VARCHAR2,
        actid      	IN NUMBER,
        funcmode   	IN VARCHAR2,
        resultout  	IN OUT NOCOPY VARCHAR2) IS
--
nval1    number;
nval2    number;
l_resultout varchar2(200);
--
BEGIN
  l_resultout  := resultout;
--
    nval1 := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'VALUE1');
    nval2 := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'VALUE2');

    IF nval1 = nval2 THEN
	resultout := 'SELF';
    ELSE
	resultout := 'SUBORDINATE';
    END IF;
EXCEPTION
  WHEN OTHERS THEN
  resultout := l_resultout;
      RAISE;
--
END self_or_subordinate;
--

END pqh_process_tenure_status;

/
