--------------------------------------------------------
--  DDL for Package AME_SEED_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_SEED_UTILITY" AUTHID CURRENT_USER as
/* $Header: ameseedutility.pkh 120.4 2006/03/10 07:19 pvelugul noship $ */
  AME_INSTALLATION_LEVEL varchar2(255) := null;

  END_OF_TIME constant date := to_date('31-12-4712 00:00:00','DD-MM-YYYY HH24:MI:SS');

  procedure INIT_AME_INSTALLATION_LEVEL;

  function OWNER_AS_STRING
    (X_LAST_UPDATED_BY   in number
    ) return varchar2;

  function DATE_AS_STRING
    (X_LAST_UPDATE_DATE  in date
    ) return varchar2;

  function OWNER_AS_INTEGER
    (X_LAST_UPDATED_BY   in varchar2
    ) return number;

  function DATE_AS_DATE
    (X_LAST_UPDATE_DATE  in varchar2
    ) return date;

  function IS_SEED_USER
    (X_USER    in VARCHAR2
    ) return boolean;

  function SEED_USER_ID return integer;

  function SEED_USER_NAME return varchar2;

  function MERGE_ROW_TEST
    (X_CURRENT_OWNER              in number
    ,X_CURRENT_LAST_UPDATE_DATE   in varchar2
    ,X_OWNER                      in number
    ,X_LAST_UPDATE_DATE           in varchar2
    ,X_CUSTOM_MODE                in varchar2
    ) return boolean;

  function TL_MERGE_ROW_TEST
    (X_CURRENT_OWNER              in number
    ,X_CURRENT_LAST_UPDATE_DATE   in varchar2
    ,X_OWNER                      in number
    ,X_LAST_UPDATE_DATE           in varchar2
    ,X_CUSTOM_MODE                in varchar2
    ) return boolean;

  function GET_DEFAULT_END_DATE return date;

  function MLS_ENABLED return boolean;

  function CALCULATE_USE_COUNT(X_ATTRIBUTE_ID ame_attribute_usages.attribute_id%type
                              ,X_APPLICATION_ID ame_attribute_usages.application_id%type) return integer;

  function USER_ID_OF_SEED_USER return integer;

  procedure create_parallel_config
    (x_action_type_id in integer
    ,x_action_type_name in varchar2
    ,x_action_id in integer
    ,x_approval_group_id in integer
    );

  procedure CHANGE_ATTRIBUTE_USAGES_COUNT(X_RULE_ID ame_rule_usages.rule_id%type
                                       ,X_APPLICATION_ID ame_rule_usages.item_id%type);

end AME_SEED_UTILITY;

 

/
