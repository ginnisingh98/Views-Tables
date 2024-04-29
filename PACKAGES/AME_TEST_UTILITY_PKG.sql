--------------------------------------------------------
--  DDL for Package AME_TEST_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_TEST_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: ametestutility.pkh 120.0.12010000.1 2008/07/28 06:23:32 appldev ship $ */
procedure populateRealTransAttributes(applicationIdIn in number
                                     ,transactionIdIn in varchar2
                                     ,errString out nocopy varchar2);

procedure getApplicableRules(applicationIdIn      in        number
                            ,transactionIdIn      in        varchar2
                            ,isRealTransaction    in        varchar2 -- 'Y' for a real transaction
                                                                     -- 'N' for a test transaction
                            ,processPriorities    in        varchar2
                            ,rulesOut            out nocopy ame_rules_list
                            ,errString           out nocopy varchar2);


procedure getApprovers(applicationIdIn      in        number
                      ,transactionIdIn      in        varchar2
                      ,isRealTransaction    in        varchar2 -- 'Y' for a real transaction
                                                               -- 'N' for a test transaction
                      ,approverListStageIn  in        integer
                      ,approversOut        out nocopy ame_approvers_list
                      ,errString           out nocopy varchar2);

procedure getTransactionProductions(applicationIdIn      in        number
                                   ,transactionIdIn      in        varchar2
                                   ,isRealTransaction    in        varchar2 -- 'Y' for a real transaction
                                                                            -- 'N' for a test transaction
                                   ,processPriorities    in        varchar2
                                   ,productionsOut      out nocopy ame_productions_list
                                   ,errString           out nocopy varchar2);
function isAttributesExist(applicationIdIn      in        number
                          ,itemClassIdIn        in        number)
  return varchar2;
end ame_test_utility_pkg;

/
