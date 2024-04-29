--------------------------------------------------------
--  DDL for Package Body PAY_ASSG_COST_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASSG_COST_SS" as
/* $Header: pyacosss.pkb 120.0.12010000.3 2009/02/04 05:58:40 pgongada noship $ */
-- Package Variables
--
g_package  varchar2(33) := '  PAY_ASSG_COST_SS.';
g_debug boolean := hr_utility.debug_enabled;
PROCEDURE CREATE_ASSG_COST(
          P_ITEM_TYPE                    IN VARCHAR2
         ,P_ITEM_KEY                     IN VARCHAR2
         ,P_ACTID                        IN NUMBER
         ,P_LOGIN_PERSON_ID              IN NUMBER
         ,P_EFFECTIVE_DATE               IN DATE
         ,P_ASSIGNMENT_ID                IN NUMBER
         ,P_BUSINESS_GROUP_ID            IN NUMBER
         ,P_PROPORTION                   IN NUMBER
         ,P_COST_ALLOCATION_KEYFLEX_ID   IN NUMBER
         ,P_SEGMENT1                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT2                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT3                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT4                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT5                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT6                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT7                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT8                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT9                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT10                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT11                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT12                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT13                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT14                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT15                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT16                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT17                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT18                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT19                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT20                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT21                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT22                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT23                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT24                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT25                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT26                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT27                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT28                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT29                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT30                    IN VARCHAR2 DEFAULT NULL
         ,P_CONCATENATED_SEGMENTS        IN VARCHAR2 DEFAULT NULL
         ,P_EFFECTIVE_START_DATE         IN DATE     DEFAULT NULL
         ,P_EFFECTIVE_END_DATE           IN DATE     DEFAULT NULL
         ,P_TRANSACTION_ID               OUT NOCOPY    NUMBER
         ,P_TRANSACTION_STEP_ID          OUT NOCOPY    NUMBER
         ) is
    l_proc varchar2(100) := g_package||'CREATE_ASSG_COST';

    l_transaction_id            HR_API_TRANSACTIONS.TRANSACTION_ID%TYPE;
    l_transaction_step_id       HR_API_TRANSACTION_STEPS.TRANSACTION_STEP_ID%TYPE;
    l_trs_object_version_number HR_API_TRANSACTION_STEPS.OBJECT_VERSION_NUMBER%TYPE;
    l_transaction_table         HR_TRANSACTION_SS.TRANSACTION_TABLE;
    l_count                     NUMBER;
    l_result                    VARCHAR2(100);
    L_EFFECTIVE_DATE            DATE;
BEGIN
    IF g_debug THEN
      hr_utility.set_location('Entering '||l_proc, 10);
      hr_utility.set_location('Calling hr_transaction_ss.create_transaction_step', 100);
    END IF;

    IF P_EFFECTIVE_DATE IS NULL THEN
      L_EFFECTIVE_DATE := SYSDATE;
    ELSE
      L_EFFECTIVE_DATE := P_EFFECTIVE_DATE;
    END IF;
    hr_transaction_ss.create_transaction_step(
                      p_item_type             => p_item_type
                     ,p_item_key              => p_item_key
                     ,p_actid                 => 0 --p_actid
                     ,p_login_person_id       => p_login_person_id
                     ,p_api_name              => g_package||'CREATE_DATA'
                     ,p_transaction_step_id   => l_transaction_step_id
                     ,p_object_version_number => l_trs_object_version_number);
    l_transaction_id:= hr_transaction_ss.get_transaction_id
                         (p_item_type   =>   p_item_type
                         ,p_item_key    =>   p_item_key);
    IF g_debug THEN
      hr_utility.set_location('Populating the user defined table structure hr_transaction_ss.transaction_table', 110);
    END IF;

    /*Populating the table structure HR_TRANSACTION_SS.TRANSACTION_TABLE with
    the user specified values. This data will be used to populate the trasaction
    tables and subsequently into the base tables once approved.*/
  --
    --TRANSACTION_ID
  --
    l_count := 1;
    l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
    l_transaction_table(l_count).param_value := p_item_type;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
    l_transaction_table(l_count).param_value := p_item_key;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ACTIVITY_ID';
    l_transaction_table(l_count).param_value := p_actid;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
    l_transaction_table(l_count).param_value := P_LOGIN_PERSON_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
    l_transaction_table(l_count).param_value := to_char(L_effective_date,
                                              hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
    l_transaction_table(l_count).param_value := NULL;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
    l_transaction_table(l_count).param_value := P_ASSIGNMENT_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_COST_ALLOCATION_ID';
    l_transaction_table(l_count).param_value := NULL;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
    l_transaction_table(l_count).param_value := P_BUSINESS_GROUP_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_COST_ALLOCATION_KEYFLEX_ID';
    l_transaction_table(l_count).param_value := P_COST_ALLOCATION_KEYFLEX_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_PROPORTION';
    l_transaction_table(l_count).param_value := P_PROPORTION;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT1';
    l_transaction_table(l_count).param_value := P_SEGMENT1;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT2';
    l_transaction_table(l_count).param_value := P_SEGMENT2;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT3';
    l_transaction_table(l_count).param_value := P_SEGMENT3;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT4';
    l_transaction_table(l_count).param_value := P_SEGMENT4;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT5';
    l_transaction_table(l_count).param_value := P_SEGMENT5;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT6';
    l_transaction_table(l_count).param_value := P_SEGMENT6;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT7';
    l_transaction_table(l_count).param_value := P_SEGMENT7;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT8';
    l_transaction_table(l_count).param_value := P_SEGMENT8;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT9';
    l_transaction_table(l_count).param_value := P_SEGMENT9;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT10';
    l_transaction_table(l_count).param_value := P_SEGMENT10;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT11';
    l_transaction_table(l_count).param_value := P_SEGMENT11;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT12';
    l_transaction_table(l_count).param_value := P_SEGMENT12;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT13';
    l_transaction_table(l_count).param_value := P_SEGMENT13;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT14';
    l_transaction_table(l_count).param_value := P_SEGMENT14;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT15';
    l_transaction_table(l_count).param_value := P_SEGMENT15;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT16';
    l_transaction_table(l_count).param_value := P_SEGMENT16;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT17';
    l_transaction_table(l_count).param_value := P_SEGMENT17;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT18';
    l_transaction_table(l_count).param_value := P_SEGMENT18;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT19';
    l_transaction_table(l_count).param_value := P_SEGMENT19;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT20';
    l_transaction_table(l_count).param_value := P_SEGMENT20;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT21';
    l_transaction_table(l_count).param_value := P_SEGMENT21;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT22';
    l_transaction_table(l_count).param_value := P_SEGMENT22;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT23';
    l_transaction_table(l_count).param_value := P_SEGMENT23;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT24';
    l_transaction_table(l_count).param_value := P_SEGMENT24;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT25';
    l_transaction_table(l_count).param_value := P_SEGMENT25;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT26';
    l_transaction_table(l_count).param_value := P_SEGMENT26;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT27';
    l_transaction_table(l_count).param_value := P_SEGMENT27;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT28';
    l_transaction_table(l_count).param_value := P_SEGMENT28;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT29';
    l_transaction_table(l_count).param_value := P_SEGMENT29;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT30';
    l_transaction_table(l_count).param_value := P_SEGMENT30;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_CONCATENATED_SEGMENTS';
    l_transaction_table(l_count).param_value := P_CONCATENATED_SEGMENTS;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_START_DATE';
    if P_EFFECTIVE_START_DATE IS NULL THEN
        l_transaction_table(l_count).param_value := NULL;
    else
	l_transaction_table(l_count).param_value := to_char(P_EFFECTIVE_START_DATE,
							    hr_transaction_ss.g_date_format);
    end if;
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_END_DATE';
    if P_EFFECTIVE_END_DATE IS NULL THEN
    	l_transaction_table(l_count).param_value := NULL;
    else
	l_transaction_table(l_count).param_value := to_char(P_EFFECTIVE_END_DATE,
							    hr_transaction_ss.g_date_format);
    end if;
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
    IF g_debug THEN
      hr_utility.set_location('Calling HR_TRANSACTION_SS.SAVE_TRANSACTION_STEP', 120);
    END IF;
    /*Save data into transaction tables*/
    hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => 0 --p_actid
                ,p_login_person_id     => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || 'CREATE_DATA'
                ,p_transaction_data => l_transaction_table);
    IF g_debug THEN
      hr_utility.set_location('After Calling HR_TRANSACTION_SS.SAVE_TRANSACTION_STEP', 130);
      hr_utility.set_location('Leaving '||l_proc, 1000);
    END IF;
    p_transaction_id := l_transaction_id;
    p_transaction_step_id := l_transaction_step_id;
END CREATE_ASSG_COST;

/*Once the WF is approved then we have to call this to insert the data into actual table*/
PROCEDURE CREATE_DATA(
P_VALIDATE                  IN     BOOLEAN DEFAULT FALSE
,P_TRANSACTION_STEP_ID      IN     NUMBER
)
IS
  l_proc                             varchar2(100) := g_package||'CREATE_DATA';
  l_effective_date                   date;
  l_effective_start_date             date;
  l_effective_end_date               date;
  l_cost_allocation_keyflex_id       PAY_COST_ALLOCATION_KEYFLEX.COST_ALLOCATION_KEYFLEX_ID%TYPE;
  l_object_version_number            PAY_COST_ALLOCATIONS_F.OBJECT_VERSION_NUMBER%TYPE;
  l_combination_name                 PAY_COST_ALLOCATION_KEYFLEX.CONCATENATED_SEGMENTS%TYPE;
  l_cost_allocation_id               PAY_COST_ALLOCATIONS_F.COST_ALLOCATION_ID%TYPE;
  l_login_person_id                  HR_API_TRANSACTIONS.CREATOR_PERSON_ID%TYPE;

BEGIN
  IF g_debug THEN
      hr_utility.set_location('Entering '||l_proc,10);
  END IF;
  /*Create save point before starting database operation*/
  SAVEPOINT create_date;

  if p_validate = false then
  --
    l_effective_date := hr_transaction_api.get_date_value(p_transaction_step_id,'P_EFFECTIVE_DATE');
    if l_effective_date is null then
	l_effective_date := sysdate;
    end if;
    if g_debug then
        hr_utility.set_location('Get P_COST_ALLOCATION_KEYFLEX_ID and P_OBJECT_VERSION_NUMBER', 20);
    end if;
    /*Get the parameters to be used in the API call*/
    l_cost_allocation_keyflex_id := hr_transaction_api.get_number_value
                                    (p_transaction_step_id => p_transaction_step_id
                                    ,p_name => 'P_COST_ALLOCATION_KEYFLEX_ID');
    l_object_version_number := hr_transaction_api.get_number_value
                               (p_transaction_step_id => p_transaction_step_id
                               ,p_name => 'P_OBJECT_VERSION_NUMBER');
    if g_debug then
      hr_utility.set_location('P_COST_ALLOCATION_KEYFLEX_ID => '||NVL(l_cost_allocation_keyflex_id,-1), 30);
      hr_utility.set_location('P_OBJECT_VERSION_NUMBER => '||NVL(l_object_version_number,-1), 40);
    end if;

    if g_debug then
      hr_utility.set_location('Calling PAY_COST_ALLOCATION_API.CREATE_COST_ALLOCATION', 50);
    end if;
    /*Now call the API to create cost allocations*/
    PAY_COST_ALLOCATION_API.CREATE_COST_ALLOCATION
    (p_validate                => p_validate
    ,p_effective_date          => l_effective_date
    ,p_assignment_id           => hr_transaction_api.get_number_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_ASSIGNMENT_ID')
    ,p_proportion              => hr_transaction_api.get_number_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_PROPORTION')/100
    ,p_business_group_id       => hr_transaction_api.get_number_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_BUSINESS_GROUP_ID')
    ,p_segment1                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT1')
    ,p_segment2                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT2')
    ,p_segment3                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT3')
    ,p_segment4                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT4')
    ,p_segment5                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT5')
    ,p_segment6                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT6')
    ,p_segment7                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT7')
    ,p_segment8                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT8')
    ,p_segment9                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT9')
    ,p_segment10               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT10')
    ,p_segment11               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT11')
    ,p_segment12               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT12')
    ,p_segment13               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT13')
    ,p_segment14               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT14')
    ,p_segment15               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT15')
    ,p_segment16               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT16')
    ,p_segment17               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT17')
    ,p_segment18               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT18')
    ,p_segment19               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT19')
    ,p_segment20               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT20')
    ,p_segment21               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT21')
    ,p_segment22               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT22')
    ,p_segment23               => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                 ,p_name => 'P_SEGMENT23')
    ,p_segment24               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT24')
    ,p_segment25               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT25')
    ,p_segment26               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT26')
    ,p_segment27               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT27')
    ,p_segment28               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT28')
    ,p_segment29               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT29')
    ,p_segment30               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT30')
    ,p_combination_name        => l_combination_name
    ,p_cost_allocation_id      => l_cost_allocation_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id
    ,p_object_version_number   => l_object_version_number);

    if g_debug then
      hr_utility.set_location('After Calling PAY_COST_ALLOCATION_API.CREATE_COST_ALLOCATION', 60);
    end if;


  end if;
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,1000);
  end if;
  --
  EXCEPTION
    WHEN hr_utility.hr_error THEN
    -- -----------------------------------------------------------------
    -- An application error has been raised by the API so we must set
    -- the error.
    -- -----------------------------------------------------------------
        hr_utility.set_location('Exception:hr_utility.hr_error THEN'||l_proc,555);
        hr_utility.set_location('Rolling back the data',666);
        ROLLBACK TO CREATE_DATA;
        hr_utility.set_location('Leaving '||l_proc,1000);
        RAISE;
    WHEN OTHERS THEN
        hr_utility.set_location('Unknown error occurred....Rolling back the data',777);
        ROLLBACK TO CREATE_DATA;
        hr_utility.set_location('Leaving '||l_proc,1000);
END CREATE_DATA;

PROCEDURE UPDATE_ASSG_COST(
          P_ITEM_TYPE                    IN VARCHAR2
         ,P_ITEM_KEY                     IN VARCHAR2
         ,P_ACTID                        IN NUMBER
         ,P_LOGIN_PERSON_ID              IN NUMBER
         ,P_UPDATE_MODE                  IN VARCHAR2 DEFAULT 'UPDATE'
         ,P_EFFECTIVE_DATE               IN DATE     DEFAULT SYSDATE
         ,P_ASSIGNMENT_ID                IN NUMBER
         ,P_COST_ALLOCATION_ID           IN NUMBER
         ,P_BUSINESS_GROUP_ID            IN NUMBER
         ,P_COST_ALLOCATION_KEYFLEX_ID   IN NUMBER
         ,P_OBJECT_VERSION_NUMBER        IN NUMBER
         ,P_PROPORTION                   IN NUMBER   default hr_api.g_number
         ,P_SEGMENT1                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT2                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT3                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT4                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT5                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT6                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT7                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT8                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT9                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT10                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT11                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT12                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT13                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT14                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT15                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT16                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT17                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT18                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT19                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT20                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT21                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT22                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT23                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT24                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT25                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT26                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT27                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT28                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT29                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT30                    IN VARCHAR2 default hr_api.g_varchar2
	 ,P_CONCATENATED_SEGMENTS        IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2
         ,P_EFFECTIVE_START_DATE         IN DATE     DEFAULT NULL
         ,P_EFFECTIVE_END_DATE           IN DATE     DEFAULT NULL
         ,P_TRANSACTION_ID               OUT NOCOPY    NUMBER
         ,P_TRANSACTION_STEP_ID          OUT NOCOPY    NUMBER
         ) as
    l_proc varchar2(100) := g_package||'UPDATE_ASSG_COST';

    l_transaction_id            HR_API_TRANSACTIONS.TRANSACTION_ID%TYPE;
    l_transaction_step_id       HR_API_TRANSACTION_STEPS.TRANSACTION_STEP_ID%TYPE;
    l_trs_object_version_number HR_API_TRANSACTION_STEPS.OBJECT_VERSION_NUMBER%TYPE;
    l_transaction_table         HR_TRANSACTION_SS.TRANSACTION_TABLE;
    l_count                     NUMBER;
    l_effective_date date;
    l_result                    varchar2(2000);
BEGIN
    IF g_debug THEN
      hr_utility.set_location('Entering '||l_proc, 10);
    END IF;
    IF P_EFFECTIVE_DATE IS NULL THEN
      l_EFFECTIVE_DATE := SYSDATE;
    else
      l_EFFECTIVE_DATE := P_EFFECTIVE_DATE;
    END IF;
    IF g_debug THEN
      hr_utility.set_location('Calling hr_transaction_ss.create_transaction_step', 100);
    END IF;
    /*This CREATE_TRANSACTION_STEP() find out of any transaction created with
    the given ITEM TYPE and ITEM KEY. If exists then it creates transaction
    step if not it creates a transactions and transaction step as well.*/
    hr_transaction_ss.create_transaction_step(
                      p_item_type             => p_item_type
                     ,p_item_key              => p_item_key
                     ,p_actid                 => 0 --p_actid
                     ,p_login_person_id       => p_login_person_id
                     ,p_api_name              => g_package||'UPDATE_DATA'
                     ,p_transaction_step_id   => l_transaction_step_id
                     ,p_object_version_number => l_trs_object_version_number);
    IF g_debug THEN
      hr_utility.set_location('Populating the user defined table structure hr_transaction_ss.transaction_table', 100);
    END IF;
    /*Populating the table structure HR_TRANSACTION_SS.TRANSACTION_TABLE with
    the user specified values. This data will be used to populate the trasaction
    tables and subsequently into the base tables.
    */
    l_count := 1;
    l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
    l_transaction_table(l_count).param_value := p_item_type;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';

    --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
    l_transaction_table(l_count).param_value := p_item_key;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ACTIVITY_ID';
    l_transaction_table(l_count).param_value := p_actid;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
    l_transaction_table(l_count).param_value := P_LOGIN_PERSON_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_UPDATE_MODE';
    l_transaction_table(l_count).param_value := P_UPDATE_MODE;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
    l_transaction_table(l_count).param_value := to_char(l_effective_date,
                                              hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
    l_transaction_table(l_count).param_value := P_OBJECT_VERSION_NUMBER;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
    l_transaction_table(l_count).param_value := P_ASSIGNMENT_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_COST_ALLOCATION_ID';
    l_transaction_table(l_count).param_value := P_COST_ALLOCATION_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
    l_transaction_table(l_count).param_value := P_BUSINESS_GROUP_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_COST_ALLOCATION_KEYFLEX_ID';
    l_transaction_table(l_count).param_value := P_COST_ALLOCATION_KEYFLEX_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_PROPORTION';
    l_transaction_table(l_count).param_value := P_PROPORTION;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT1';
    l_transaction_table(l_count).param_value := P_SEGMENT1;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT2';
    l_transaction_table(l_count).param_value := P_SEGMENT2;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT3';
    l_transaction_table(l_count).param_value := P_SEGMENT3;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT4';
    l_transaction_table(l_count).param_value := P_SEGMENT4;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT5';
    l_transaction_table(l_count).param_value := P_SEGMENT5;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT6';
    l_transaction_table(l_count).param_value := P_SEGMENT6;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT7';
    l_transaction_table(l_count).param_value := P_SEGMENT7;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT8';
    l_transaction_table(l_count).param_value := P_SEGMENT8;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT9';
    l_transaction_table(l_count).param_value := P_SEGMENT9;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT10';
    l_transaction_table(l_count).param_value := P_SEGMENT10;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT11';
    l_transaction_table(l_count).param_value := P_SEGMENT11;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT12';
    l_transaction_table(l_count).param_value := P_SEGMENT12;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT13';
    l_transaction_table(l_count).param_value := P_SEGMENT13;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT14';
    l_transaction_table(l_count).param_value := P_SEGMENT14;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT15';
    l_transaction_table(l_count).param_value := P_SEGMENT15;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT16';
    l_transaction_table(l_count).param_value := P_SEGMENT16;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT17';
    l_transaction_table(l_count).param_value := P_SEGMENT17;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT18';
    l_transaction_table(l_count).param_value := P_SEGMENT18;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT19';
    l_transaction_table(l_count).param_value := P_SEGMENT19;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT20';
    l_transaction_table(l_count).param_value := P_SEGMENT20;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT21';
    l_transaction_table(l_count).param_value := P_SEGMENT21;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT22';
    l_transaction_table(l_count).param_value := P_SEGMENT22;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT23';
    l_transaction_table(l_count).param_value := P_SEGMENT23;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT24';
    l_transaction_table(l_count).param_value := P_SEGMENT24;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT25';
    l_transaction_table(l_count).param_value := P_SEGMENT25;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT26';
    l_transaction_table(l_count).param_value := P_SEGMENT26;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT27';
    l_transaction_table(l_count).param_value := P_SEGMENT27;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT28';
    l_transaction_table(l_count).param_value := P_SEGMENT28;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT29';
    l_transaction_table(l_count).param_value := P_SEGMENT29;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_SEGMENT30';
    l_transaction_table(l_count).param_value := P_SEGMENT30;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_CONCATENATED_SEGMENTS';
    l_transaction_table(l_count).param_value := P_CONCATENATED_SEGMENTS;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_START_DATE';
    if P_EFFECTIVE_START_DATE IS NULL THEN
        l_transaction_table(l_count).param_value := NULL;
    else
	l_transaction_table(l_count).param_value := to_char(P_EFFECTIVE_START_DATE,
							    hr_transaction_ss.g_date_format);
    end if;
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_END_DATE';
    if P_EFFECTIVE_END_DATE IS NULL THEN
    	l_transaction_table(l_count).param_value := NULL;
    else
	l_transaction_table(l_count).param_value := to_char(P_EFFECTIVE_END_DATE,
							    hr_transaction_ss.g_date_format);
    end if;
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
  /*Save data into transaction tables*/
  if g_debug then
      hr_utility.set_location('Calling HR_TRANSACTION_SS.SAVE_TRANSACTION_STEP', 110);
  end if;
  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => 0 --p_actid
                ,p_login_person_id     => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || 'UPDATE_DATA'
                ,p_transaction_data => l_transaction_table);
  p_transaction_id := l_transaction_id;
  p_transaction_step_id := l_transaction_step_id;
  if g_debug then
      hr_utility.set_location('After Calling HR_TRANSACTION_SS.SAVE_TRANSACTION_STEP', 110);
      hr_utility.set_location('Leaving '||l_proc,1000);
  end if;
END UPDATE_ASSG_COST;

PROCEDURE UPDATE_DATA(
P_VALIDATE                  IN     BOOLEAN DEFAULT FALSE
,P_TRANSACTION_STEP_ID      IN     NUMBER
)
IS
  l_proc                             varchar2(100) := g_package||'UPDATE_DATA';
  l_effective_date                   date;
  l_effective_start_date             date default null;
  l_effective_end_date               date default null;
  l_cost_allocation_keyflex_id       PAY_COST_ALLOCATION_KEYFLEX.COST_ALLOCATION_KEYFLEX_ID%TYPE;
  l_object_version_number            PAY_COST_ALLOCATIONS_F.OBJECT_VERSION_NUMBER%TYPE;
  l_combination_name                 PAY_COST_ALLOCATION_KEYFLEX.CONCATENATED_SEGMENTS%TYPE;
  l_cost_allocation_id               PAY_COST_ALLOCATIONS_F.COST_ALLOCATION_ID%TYPE;
  l_login_person_id                  HR_API_TRANSACTIONS.CREATOR_PERSON_ID%TYPE;
  l_update_datetrack_mode            VARCHAR2(20);
BEGIN

  if g_debug then
      hr_utility.set_location('Entering '||l_proc, 10);
  end if;

  SAVEPOINT UPDATE_DATA;
  if p_validate = false then
    l_effective_date := hr_transaction_api.get_date_value(p_transaction_step_id,'P_EFFECTIVE_DATE');
    if l_effective_date is null then
	l_effective_date := sysdate;
    end if;
    if g_debug then
        hr_utility.set_location('Get P_COST_ALLOCATION_KEYFLEX_ID and P_OBJECT_VERSION_NUMBER', 20);
    end if;
    l_cost_allocation_keyflex_id := hr_transaction_api.get_number_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_COST_ALLOCATION_KEYFLEX_ID');
    l_object_version_number := hr_transaction_api.get_number_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_OBJECT_VERSION_NUMBER');
    l_update_datetrack_mode := hr_transaction_api.get_varchar2_value(
				  p_transaction_step_id => p_transaction_step_id,
				  p_name => 'P_UPDATE_MODE');
    if g_debug then
        hr_utility.set_location('P_COST_ALLOCATION_KEYFLEX_ID => '||NVL(l_cost_allocation_keyflex_id,-1), 30);
        hr_utility.set_location('P_OBJECT_VERSION_NUMBER => '||NVL(l_object_version_number,-1), 40);
    end if;
  --

    if g_debug then
        hr_utility.set_location('Calling PAY_COST_ALLOCATION_API.UPDATE_COST_ALLOCATION', 50);
    end if;

    BEGIN
    PAY_COST_ALLOCATION_API.UPDATE_COST_ALLOCATION
    (p_validate                => p_validate
    ,p_effective_date          => l_effective_date
    ,p_datetrack_update_mode   => nvl(l_update_datetrack_mode,'UPDATE')
    ,p_cost_allocation_id      => hr_transaction_api.get_number_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_COST_ALLOCATION_ID')
    ,p_object_version_number   => l_object_version_number
    ,p_proportion              => hr_transaction_api.get_number_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_PROPORTION')/100
    ,p_segment1                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT1')
    ,p_segment2                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT2')
    ,p_segment3                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT3')
    ,p_segment4                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT4')
    ,p_segment5                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT5')
    ,p_segment6                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT6')
    ,p_segment7                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT7')
    ,p_segment8                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT8')
    ,p_segment9                => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT9')
    ,p_segment10               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT10')
    ,p_segment11               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT11')
    ,p_segment12               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT12')
    ,p_segment13               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT13')
    ,p_segment14               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT14')
    ,p_segment15               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT15')
    ,p_segment16               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT16')
    ,p_segment17               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT17')
    ,p_segment18               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT18')
    ,p_segment19               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT19')
    ,p_segment20               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT20')
    ,p_segment21               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT21')
    ,p_segment22               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT22')
    ,p_segment23               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT23')
    ,p_segment24               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT24')
    ,p_segment25               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT25')
    ,p_segment26               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT26')
    ,p_segment27               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT27')
    ,p_segment28               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT28')
    ,p_segment29               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT29')
    ,p_segment30               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_SEGMENT30')
    ,p_combination_name        => l_combination_name
    ,p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date);
    end;
    if g_debug then
        hr_utility.set_location('After Calling PAY_COST_ALLOCATION_API.UPDATE_COST_ALLOCATION', 60);
    end if;
  else
    hr_utility.set_location('p_validate is true...so nothing to do',120);
  end if;
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,1000);
  end if;
  EXCEPTION
    WHEN hr_utility.hr_error THEN
    -- -----------------------------------------------------------------
    -- An application error has been raised by the API so we must set
    -- the error.
    -- -----------------------------------------------------------------
        hr_utility.set_location('Exception:hr_utility.hr_error THEN'||l_proc,555);
        hr_utility.set_location('Rolling back the data',666);
        ROLLBACK TO UPDATE_DATA;
        hr_utility.set_location('Leaving '||l_proc,1000);
        RAISE;
    WHEN OTHERS THEN
        hr_utility.set_location('Unknown error occurred....Rolling back the data',777);
        ROLLBACK TO UPDATE_DATA;
        hr_utility.set_location('Leaving '||l_proc,1000);
END UPDATE_DATA;

PROCEDURE DELETE_ASSG_COST(
          P_ITEM_TYPE                    IN VARCHAR2
         ,P_ITEM_KEY                     IN VARCHAR2
         ,P_ACTID                        IN NUMBER
         ,P_LOGIN_PERSON_ID              IN NUMBER
         ,P_DELETE_MODE                  IN VARCHAR2 DEFAULT 'DELETE'
         ,P_EFFECTIVE_DATE               IN DATE
         ,P_ASSIGNMENT_ID                IN NUMBER
         ,P_BUSINESS_GROUP_ID            IN NUMBER
         ,P_COST_ALLOCATION_ID           IN NUMBER
         ,P_OBJECT_VERSION_NUMBER        IN NUMBER
	 ,P_CONCATENATED_SEGMENTS        IN VARCHAR2 DEFAULT NULL
         ,P_EFFECTIVE_START_DATE         IN DATE     DEFAULT NULL
         ,P_EFFECTIVE_END_DATE           IN DATE     DEFAULT NULL
         ,P_TRANSACTION_ID               OUT NOCOPY    NUMBER
         ,P_TRANSACTION_STEP_ID          OUT NOCOPY    NUMBER
         ) is
    l_proc varchar2(100) := g_package||'DELETE_ASSG_COST';

    l_transaction_id            HR_API_TRANSACTIONS.TRANSACTION_ID%TYPE;
    l_transaction_step_id       HR_API_TRANSACTION_STEPS.TRANSACTION_STEP_ID%TYPE;
    l_trs_object_version_number HR_API_TRANSACTION_STEPS.OBJECT_VERSION_NUMBER%TYPE;
    l_transaction_table         HR_TRANSACTION_SS.TRANSACTION_TABLE;
    l_count                     NUMBER;
    l_result                    VARCHAR2(100);
    L_EFFECTIVE_DATE            DATE;
BEGIN
    IF g_debug THEN
      hr_utility.set_location('Entering '||l_proc, 10);
      hr_utility.set_location('Calling hr_transaction_ss.create_transaction_step', 100);
    END IF;

    IF P_EFFECTIVE_DATE IS NULL THEN
      L_EFFECTIVE_DATE := SYSDATE;
    ELSE
      L_EFFECTIVE_DATE := P_EFFECTIVE_DATE;
    END IF;

    /*This CREATE_TRANSACTION_STEP() find out of any transaction created with
    the given ITEM TYPE and ITEM KEY. If exists then it creates transaction
    step if not it creates a transactions and transaction step as well.*/

    hr_transaction_ss.create_transaction_step(
                      p_item_type             => p_item_type
                     ,p_item_key              => p_item_key
                     ,p_actid                 => 0 --p_actid
                     ,p_login_person_id       => p_login_person_id
                     ,p_api_name              => g_package||'DELETE_DATA'
                     ,p_transaction_step_id   => l_transaction_step_id
                     ,p_object_version_number => l_trs_object_version_number);
    IF g_debug THEN
      hr_utility.set_location('After Calling HR_TRANSACTION_SS.SAVE_TRANSACTION_STEP', 130);
      hr_utility.set_location('Leaving '||l_proc, 1000);
    END IF;

    /*Populating the table structure HR_TRANSACTION_SS.TRANSACTION_TABLE with
    the user specified values. This data will be used to populate the trasaction
    tables and subsequently into the base tables.
    */
    l_count := 1;
    l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
    l_transaction_table(l_count).param_value := p_item_type;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';

    --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
    l_transaction_table(l_count).param_value := p_item_key;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ACTIVITY_ID';
    l_transaction_table(l_count).param_value := p_actid;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
    l_transaction_table(l_count).param_value := P_LOGIN_PERSON_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_DELETE_MODE';
    l_transaction_table(l_count).param_value := P_DELETE_MODE;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
    l_transaction_table(l_count).param_value := to_char(l_effective_date,
                                              hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
    l_transaction_table(l_count).param_value := P_OBJECT_VERSION_NUMBER;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
    l_transaction_table(l_count).param_value := P_ASSIGNMENT_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_COST_ALLOCATION_ID';
    l_transaction_table(l_count).param_value := P_COST_ALLOCATION_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
    l_transaction_table(l_count).param_value := P_BUSINESS_GROUP_ID;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_START_DATE';
    if P_EFFECTIVE_START_DATE IS NULL THEN
        l_transaction_table(l_count).param_value := NULL;
    else
	l_transaction_table(l_count).param_value := to_char(P_EFFECTIVE_START_DATE,
							    hr_transaction_ss.g_date_format);
    end if;
    l_transaction_table(l_count).param_data_type := 'DATE';
  --
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_EFFECTIVE_END_DATE';
    if P_EFFECTIVE_END_DATE IS NULL THEN
    	l_transaction_table(l_count).param_value := NULL;
    else
	l_transaction_table(l_count).param_value := to_char(P_EFFECTIVE_END_DATE,
							    hr_transaction_ss.g_date_format);
    end if;
    l_transaction_table(l_count).param_data_type := 'DATE';
    /*Save data into transaction tables*/
    if g_debug then
      hr_utility.set_location('Calling HR_TRANSACTION_SS.SAVE_TRANSACTION_STEP', 110);
    end if;
    hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => 0 --p_actid
                ,p_login_person_id     => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || 'DELETE_DATA'
                ,p_transaction_data => l_transaction_table);

    p_transaction_id := l_transaction_id;
    p_transaction_step_id := l_transaction_step_id;
END DELETE_ASSG_COST;

PROCEDURE DELETE_DATA(
P_VALIDATE                  IN     BOOLEAN DEFAULT FALSE
,P_TRANSACTION_STEP_ID      IN     NUMBER
)
IS
  l_proc                             varchar2(100) := g_package||'DELETE_DATA';
  l_effective_date                   date;
  l_effective_start_date             date;
  l_effective_end_date               date;
  l_object_version_number            PAY_COST_ALLOCATIONS_F.OBJECT_VERSION_NUMBER%TYPE;
  l_combination_name                 PAY_COST_ALLOCATION_KEYFLEX.CONCATENATED_SEGMENTS%TYPE;
  l_cost_allocation_id               PAY_COST_ALLOCATIONS_F.COST_ALLOCATION_ID%TYPE;
  l_login_person_id                  HR_API_TRANSACTIONS.CREATOR_PERSON_ID%TYPE;
  l_datetrack_delete_mode            VARCHAR2(20);

BEGIN
  IF g_debug THEN
      hr_utility.set_location('Entering '||l_proc,10);
  END IF;
  /*Create save point before starting database operation*/
  SAVEPOINT create_date;
  if p_validate = false then
  --
   l_effective_date := hr_transaction_api.get_date_value(p_transaction_step_id,'P_EFFECTIVE_DATE');
    if l_effective_date is null then
	l_effective_date := sysdate;
    end if;

    if g_debug then
        hr_utility.set_location('Get P_COST_ALLOCATION_KEYFLEX_ID and P_OBJECT_VERSION_NUMBER', 20);
    end if;

    /*Get the values used to call the API*/
    l_cost_allocation_id    := hr_transaction_api.get_number_value
                               (p_transaction_step_id => p_transaction_step_id
                               ,p_name => 'P_COST_ALLOCATION_ID');
    l_object_version_number := hr_transaction_api.get_number_value
                               (p_transaction_step_id => p_transaction_step_id
                               ,p_name => 'P_OBJECT_VERSION_NUMBER');
    l_datetrack_delete_mode := hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                 ,p_name => 'P_DELETE_MODE');

    /*Now Call the API to delete the cost allocations.*/
    PAY_COST_ALLOCATION_API.DELETE_COST_ALLOCATION
    (p_validate                    => P_VALIDATE
    ,p_effective_date              => l_effective_date
    ,p_datetrack_delete_mode       => nvl(l_datetrack_delete_mode,'DELETE')
    ,p_cost_allocation_id          => hr_transaction_api.get_number_value
                                      (p_transaction_step_id => p_transaction_step_id
                                      ,p_name => 'P_COST_ALLOCATION_ID')
    ,p_object_version_number       => l_object_version_number
    ,p_effective_start_date        => l_effective_start_date
    ,p_effective_end_date          => l_effective_end_date);

    if g_debug then
        hr_utility.set_location('After Calling PAY_COST_ALLOCATION_API.UPDATE_COST_ALLOCATION', 60);
    end if;
  end if;
    IF g_debug THEN
      hr_utility.set_location('Leaving '||l_proc,10);
  END IF;
END DELETE_DATA;

END PAY_ASSG_COST_SS;

/
