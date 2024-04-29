--------------------------------------------------------
--  DDL for Package HR_TIPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIPS_API" AUTHID CURRENT_USER as
/* $Header: hrtipapi.pkh 115.2 99/10/05 17:58:34 porting ship $ */
--
TYPE TipRecType is RECORD (
   TipField    HR_TIPS.FIELD%TYPE,
   TipText     varchar2 (32000) );
--
TYPE TipRecTable is TABLE of TipRecType INDEX BY BINARY_INTEGER;
--
function getTip(p_screen    		   varchar2
               ,p_field     		   varchar2
               ,p_language  		   varchar2
               ,p_business_group_id        number    default null
               ,p_default                  boolean   default true
               ) return varchar2;
--
function getAllTips(p_screen    	         varchar2
                   ,p_language  	         varchar2
                   ,p_business_group_id	         number	    default null
                   ,p_default                    boolean    default true
                   ) return TipRecTable;
--
function getInstruction(p_screen              varchar2
                       ,p_language            varchar2
                       ,p_business_group_id   number    default null
                       ,p_instruction_name    varchar2  default 'INSTRUCTIONS'
                       ,p_default             boolean   default true
                       ) return varchar2;
--
function getDisclaimer(p_screen               varchar2
                      ,p_language             varchar2
                      ,p_business_group_id    number    default null
                      ,p_default              boolean   default true
                      ) return varchar2;
--
end hr_tips_api;

 

/
